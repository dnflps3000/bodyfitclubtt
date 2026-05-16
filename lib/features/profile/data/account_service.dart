import 'package:cloud_functions/cloud_functions.dart';

class AccountService {
  Future<void> requestAccountDeletion({String? reason}) async {
    final callable = FirebaseFunctions.instanceFor(
      region: 'europe-west1',
    ).httpsCallable('requestAccountDeletion');

    await callable.call({
      if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
    });
  }
}
