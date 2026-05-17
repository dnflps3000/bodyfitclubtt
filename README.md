# bodyfitclubtt
BodyFit Club TT – Mobilná aplikácia

Mobilná aplikácia pre fitness centrum BodyFit Club Trnava vytvorená pomocou Flutter a Firebase. 
Aplikácia umožňuje používateľom rezervovať si tréningy, spravovať svoj profil a sledovať dostupné termíny.

---

## Autori
- Adrián Tóth
- Filip Sokol

---

## Funkcionalita

- Používateľská registrácia a prihlásenie
- Správa používateľského profilu
- Prehľad dostupných tréningov a termínov
- Rezervácia tréningov
- Správa členstiev, permanentiek a vstupov
- QR kódy pre kontrolu rezervácií
- Oznamy a verejné správy pre používateľov
- Push notifikácie
- Rozhranie pre používateľov, trénerov a administrátorov
- Automatizované spracovanie vybraných dát
- Podpora svetlého a tmavého režimu
- Jednotný vizuálny štýl aplikácie

---

## Použité technológie

- Flutter
  - Dart
  - Material Design
  - Flutter Local Notifications
  - QR Flutter
  - Mobile Scanner

- Firebase
  - Firebase Authentication
  - Cloud Firestore
  - Firebase Storage
  - Firebase Cloud Messaging
  - Firebase Functions

- Platobné služby
  - Stripe

- Verzionovanie projektu
  - Git
  - GitHubI

- AI asistencia
  - ChatGPT
  - Genie AI

- Dizajn
  - Figma
  - Canva
  - Flutter Design

---

## Štruktúra projektu

bodyfitclubtt/
├── .dart_tool/
├── .idea/
├── .vscode/
├── android/
├── assets/
├── bodyfitclub_app/
├── build/
├── functions/
├── ios/
├── lib/
├── linux/
├── macos/
├── test/
│   └── widget_test.dart
├── web/
├── windows/
├── .firebaserc
├── .flutter-plugins-dependencies
├── .gitignore
├── .metadata
├── analysis_options.yaml
├── bodyfitclubtt.iml
├── delete.html
├── firebase.json
├── firestore.rules
├── privacy.html
├── pubspec.lock
├── pubspec.yaml
├── README.md
└── storage.rules

---

## Inštalácia

1. Naklonuj repozitár:

git clone https://github.com/dnflps3000/bodyfitclubtt.git


2. Prejdi do priečinka:

cd bodyfitclubtt


3. Nainštaluj závislosti:

flutter pub get


4. Spusti aplikáciu:

flutter run


---

## Firebase konfigurácia

Projekt využíva Firebase pre autentifikáciu, databázu, notifikácie, cloud funkcie a ukladanie dát.

Pre správne fungovanie projektu je potrebné doplniť konfiguračné súbory:

android/app/google-services.json
ios/Runner/GoogleService-Info.plist
lib/firebase_options.dart
firebase.json
.firebaserc
firestore.rules
storage.rules
analysis_options.yaml
pubspec.yaml

Súbor android/local.properties obsahuje lokálne konfiguračné hodnoty a API kľúče. Tento súbor sa nemá odosielať na GitHub.

Backend časť aplikácie využíva Firebase Functions. Funkcie zabezpečujú napríklad:

- správu push notifikácií
- spracovanie Firebase Cloud Messaging tokenov
- automatické odosielanie notifikácií
- automatizované databázové operácie
- správu rezervácií a tréningov
- generovanie tréningov zo šablón
- validáciu a spracovanie dát
- komunikáciu s externými službami
- správu používateľských udalostí
- server-side logiku aplikácie

---

## Stav projektu
Projekt je dokončený

---

## Náhľad aplikácie
Pre náhlad aplikácie a jej fungovania možno použiť tento Figma link:
https://www.figma.com/design/wnmbq6eeMzprgkjo7iQgJs/BodyFitClubTT?node-id=0-1&t=wXHttLAI2BEZ2ZT9-1

---
## Reflexia využitia LLM nástrojov

Pri vývoji aplikácie boli využité LLM nástroje (ChatGPT, Genie AI) ako podpora pri programovaní, návrhu UI, riešení technických problémov a tvorbe dokumentácie. Všetky vygenerované návrhy a úpravy boli následne manuálne overené, testované a prispôsobené požiadavkám projektu. Ale opäť sa potvrdilo pravidlo LLM je dobrý sluha ale zlý pán, častokrát sa riešenie, začínajúce vetou "poďme na to, spravíme rýchly fix",  ktoré bolo možno vyriešiť jednoduchým príkazom (napr. flutter clean, flutter pub get), zmenilo na niekoľko hodinový boj a opravovanie odporúčaných zmien. ChatGPT po pár promptoch zabúda riešiť úlohu ako celok, často bolo potrebné pripomenúť to, že daná úloha je súčasťou komplexného systému viacerých funkcií, pretože "rýchly fix" jedného problému spôsobilo XY problémov u iných funkicií. Niekoľkokrát riešenie jedného, možno menšieho problému docielilo pridanie ďalších, omnoho komplexnejších problémov, ktorých riešením bolo obnovenie zálohy kódu pred úpravou a potrebná zmena "chatovacieho" okna s LLM, akoby daný LLM začal myslieť iným, triezvejším smerom. Veľmi vítanou funkciou by bolo umožnenie prístupu umelej inteligencie priamo do priečinku aplikácie, pri každej pridanej funkcii bolo potrebné niekoľkokrát vložiť hlavnú zložku aplikácie do LLM. Taktiež nastával problém pri úprave celkového kódu zo súboru, LLM "zabúdal" doplniť všetky funkcie ktoré boli v kóde definované. Na druhú stranu musíme zhodnotiť, že bez použitia LLM by vývoj našej aplikácie trval omnoho dlhšie a nemožno stopercentne povedať, či by bola požadovaná funkčnosť aspoň z polovice dosiahnuteľná. Môžme skonštatovať, že spojenie LLM nástroja ChatGPT a doplnku Genie AI je výborná kombinácia pri tvorbe aplikácie, často bolo potrebné pozmeniť funkciu a takto nám bolo umožnené vykonať zmenu priamo v kóde.

---

## 📄 Licencia
Tento projekt je vytvorený pre študijné účely.
