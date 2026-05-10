import {onSchedule} from "firebase-functions/v2/scheduler";
import * as logger from "firebase-functions/logger";
import {initializeApp} from "firebase-admin/app";
import {
  FieldValue,
  Timestamp,
  getFirestore,
} from "firebase-admin/firestore";
import * as functions from "firebase-functions";
import Stripe from "stripe";
import {onDocumentCreated} from "firebase-functions/v2/firestore";
import {getMessaging} from "firebase-admin/messaging";

initializeApp();

/* Každý deň o 03:00 podľa času Europe/Bratislava načíta aktívne scheduleTemplates
 a vytvorí konkrétne trainingSessions na najbližších 14 dní.*/

const db = getFirestore();
const APP_TIME_ZONE = "Europe/Bratislava";

function getStripe() {
  const stripeSecretKey = process.env.STRIPE_SECRET_KEY;

  if (!stripeSecretKey) {
    throw new Error("Missing STRIPE_SECRET_KEY environment variable.");
  }

  return new Stripe(stripeSecretKey, {
    apiVersion: "2026-04-22.dahlia",
  });
}

export const createPaymentIntent = functions.https.onRequest(
  async (req, res) => {
    try {
      const planId = req.body?.planId as string | undefined;

      if (!planId) {
        res.status(400).send({error: "Missing planId"});
        return;
      }

      const planSnapshot = await db
        .collection("membershipPlans")
        .doc(planId)
        .get();

      if (!planSnapshot.exists) {
        res.status(404).send({error: "Membership plan not found"});
        return;
      }

      const plan = planSnapshot.data();

      if (!plan || plan.isActive !== true) {
        res.status(400).send({error: "Membership plan is not active"});
        return;
      }

      const price = Number(plan.price);
      const currency = String(plan.currency ?? "EUR").toLowerCase();

      if (!Number.isFinite(price) || price <= 0) {
        res.status(400).send({error: "Invalid membership plan price"});
        return;
      }

      const stripe = getStripe();
      const paymentIntent = await stripe.paymentIntents.create({
        amount: Math.round(price * 100),
        currency,
        metadata: {
          planId,
        },
      });

      res.status(200).send({
        clientSecret: paymentIntent.client_secret,
      });
    } catch (error) {
      console.error(error);
      res.status(500).send({error: "Payment failed"});
    }
  }
);

type ScheduleTemplate = {
  trainingTypeId: string;
  trainerId: string;
  weekday: number;
  startHour: number;
  startMinute: number;
  durationMinutes: number;
  capacity: number;
  isActive: boolean;
  validFrom?: Timestamp | null;
  validUntil?: Timestamp | null;
};

/**
 * Vráti začiatok dňa pre zadaný dátum.
 */
function startOfDay(date: Date): Date {
  return new Date(date.getFullYear(), date.getMonth(), date.getDate());
}

/**
 * Pridá k dátumu zadaný počet dní.
 */
function addDays(date: Date, days: number): Date {
  const result = new Date(date);
  result.setDate(result.getDate() + days);

  return result;
}

/**
 * Vráti deň v týždni v ISO formáte: pondelok = 1, nedeľa = 7.
 */
function getIsoWeekday(date: Date): number {
  const day = date.getDay();

  if (day === 0) {
    return 7;
  }

  return day;
}

/**
 * Vytvorí textový dátum použiteľný v ID dokumentu.
 */
function formatDateId(date: Date): string {
  const year = date.getFullYear().toString();
  const month = (date.getMonth() + 1).toString().padStart(2, "0");
  const day = date.getDate().toString().padStart(2, "0");

  return `${year}-${month}-${day}`;
}

/**
 * Vráti časový posun zadanej časovej zóny voči UTC.
 */
function getTimeZoneOffsetMilliseconds(
  date: Date,
  timeZone: string,
): number {
  const parts = new Intl.DateTimeFormat("en-US", {
    timeZone,
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
    hour: "2-digit",
    minute: "2-digit",
    second: "2-digit",
    hourCycle: "h23",
  }).formatToParts(date);

  const values: Record<string, string> = {};

  for (const part of parts) {
    if (part.type !== "literal") {
      values[part.type] = part.value;
    }
  }

  const localAsUtc = Date.UTC(
    Number(values.year),
    Number(values.month) - 1,
    Number(values.day),
    Number(values.hour),
    Number(values.minute),
    Number(values.second),
  );

  return localAsUtc - date.getTime();
}

/**
 * Vytvorí UTC Date z dátumu a času zadaného v lokálnej časovej zóne appky.
 */
function createDateInAppTimeZone(
  year: number,
  month: number,
  day: number,
  hour: number,
  minute: number,
): Date {
  const utcGuess = new Date(Date.UTC(year, month, day, hour, minute));
  const offset = getTimeZoneOffsetMilliseconds(utcGuess, APP_TIME_ZONE);

  return new Date(utcGuess.getTime() - offset);
}

/**
 * Overí, či je šablóna platná pre konkrétny deň.
 */
function isTemplateValidForDate(
  template: ScheduleTemplate,
  date: Date,
): boolean {
  const dayStart = startOfDay(date);

  if (template.validFrom) {
    const validFrom = startOfDay(template.validFrom.toDate());

    if (dayStart < validFrom) {
      return false;
    }
  }

  if (template.validUntil) {
    const validUntil = startOfDay(template.validUntil.toDate());

    if (dayStart > validUntil) {
      return false;
    }
  }

  return true;
}

/**
 * Overí, či sa nový termín časovo neprekrýva s existujúcim tréningom.
 */
async function hasOverlappingSession(
  startTime: Date,
  endTime: Date,
): Promise<boolean> {
  const snapshot = await db
    .collection("trainingSessions")
    .where("startTime", "<", Timestamp.fromDate(endTime))
    .get();

  return snapshot.docs.some((doc) => {
    const data = doc.data();

    const isActive = data.isActive === true;
    const status = data.status;
    const existingEndTime = data.endTime as Timestamp | undefined;

    if (!isActive || status !== "scheduled" || !existingEndTime) {
      return false;
    }

    return existingEndTime.toDate() > startTime;
  });
}

export const generateTrainingSessions = onSchedule(
  {
    schedule: "every day 03:00",
    timeZone: "Europe/Bratislava",
    region: "europe-west1",
  },
  async () => {
    const daysAhead = 14;
    const today = startOfDay(new Date());

    const templatesSnapshot = await db
      .collection("scheduleTemplates")
      .where("isActive", "==", true)
      .get();

    logger.info(
      `Found ${templatesSnapshot.size} active schedule templates.`,
    );

    let createdCount = 0;
    let skippedCount = 0;

    for (const templateDocument of templatesSnapshot.docs) {
      const template = templateDocument.data() as ScheduleTemplate;
      const templateId = templateDocument.id;

      for (let index = 0; index < daysAhead; index++) {
        const currentDate = addDays(today, index);

        if (getIsoWeekday(currentDate) !== template.weekday) {
          continue;
        }

        if (!isTemplateValidForDate(template, currentDate)) {
          continue;
        }

        const startTime = createDateInAppTimeZone(
          currentDate.getFullYear(),
          currentDate.getMonth(),
          currentDate.getDate(),
          template.startHour,
          template.startMinute,
        );

        const endTime = new Date(startTime);
        endTime.setMinutes(
          endTime.getMinutes() + template.durationMinutes,
        );

        const dateId = formatDateId(currentDate);
        const sessionId = `${templateId}_${dateId}`;

        const sessionRef = db
          .collection("trainingSessions")
          .doc(sessionId);

        const existingSession = await sessionRef.get();

        if (existingSession.exists) {
          skippedCount++;
          continue;
        }

        const hasOverlap = await hasOverlappingSession(
          startTime,
          endTime,
        );

        if (hasOverlap) {
          logger.warn(
            `Skipped ${sessionId}, another session overlaps.`,
          );
          skippedCount++;
          continue;
        }

        const trainingTypeRef = db
          .collection("trainingTypes")
          .doc(template.trainingTypeId);

        const trainerRef = db
          .collection("users")
          .doc(template.trainerId);

        const templateRef = db
          .collection("scheduleTemplates")
          .doc(templateId);

        await sessionRef.set({
          trainingTypeId: template.trainingTypeId,
          trainingTypeRef,
          trainerId: template.trainerId,
          trainerRef,
          createdBy: template.trainerId,
          createdByRef: trainerRef,
          startTime: Timestamp.fromDate(startTime),
          endTime: Timestamp.fromDate(endTime),
          capacity: template.capacity,
          reservedCount: 0,
          status: "scheduled",
          isActive: true,
          source: "template",
          templateId,
          templateRef,
          createdAt: FieldValue.serverTimestamp(),
          updatedAt: FieldValue.serverTimestamp(),
        });

        createdCount++;
      }
    }

    logger.info(
      "Training session generation finished. " +
        `Created: ${createdCount}, skipped: ${skippedCount}.`,
    );
  },
);

export const sendNotificationOnPublicMessageCreate = onDocumentCreated(
  {
    document: "public_messages/{messageId}",
    region: "europe-west1",
  },
  async (event) => {
    const messageData = event.data?.data();

    if (!messageData) {
      logger.info("Message data is empty, notification skipped.");
      return;
    }

    const text = messageData.text as string | undefined;
    const authorName = messageData.authorName as string | undefined;

    if (!text) {
      logger.info("Message text is empty, notification skipped.");
      return;
    }

    const tokensSnapshot = await db.collection("fcmTokens").get();

    const tokens = tokensSnapshot.docs
      .map((doc) => doc.data().token as string | undefined)
      .filter((token): token is string => Boolean(token));

    if (tokens.length === 0) {
      logger.info("No FCM tokens found.");
      return;
    }

    const title = "Nová správa";
    const body = authorName ? `${authorName}: ${text}` : text;

    const chunks: string[][] = [];

    for (let i = 0; i < tokens.length; i += 500) {
      chunks.push(tokens.slice(i, i + 500));
    }

    for (const chunk of chunks) {
      const response = await getMessaging().sendEachForMulticast({
        tokens: chunk,
        notification: {
          title,
          body,
        },
        data: {
          type: "public_message",
          messageId: event.params.messageId,
        },
      });

      logger.info(
        `Notifications sent: ${response.successCount}, failed: ${response.failureCount}`,
      );
    }
  },
);
