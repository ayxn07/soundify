import 'package:spotify_app_clone/core/usecase/usecase.dart';
import 'package:spotify_app_clone/data/sources/local/local_storage_service.dart';
import 'package:spotify_app_clone/service_locator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignoutUseCase implements UseCase<void, void> {
  @override
  Future<void> call({params}) async {
    await sl<LocalStorageService>().clearUid();
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
    await FirebaseAuth.instance.signOut();
  }
}
