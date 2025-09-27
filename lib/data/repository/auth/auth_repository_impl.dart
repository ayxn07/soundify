import 'package:dartz/dartz.dart';
import 'package:spotify_app_clone/data/models/auth/create_user_req.dart';
import 'package:spotify_app_clone/data/models/auth/google_user_req.dart';
import 'package:spotify_app_clone/data/models/auth/signin_user_req.dart';
import 'package:spotify_app_clone/data/sources/auth/auth_firebase_service.dart';
import '../../../domain/repository/auth/auth.dart';
import 'package:spotify_app_clone/service_locator.dart';

class AuthRepositoryImpl extends AuthRepository {
  @override
  Future<Either<dynamic, dynamic>> signin(SigninUserReq signinUserReq) async {
    return await sl<AuthFirebaseService>().signin(signinUserReq);
  }

  @override
  Future<Either<dynamic, dynamic>> signup(CreateUserReq createUserReq) async {
    return await sl<AuthFirebaseService>().signup(createUserReq);
  }

  @override
  Future<Either<dynamic, dynamic>> signInWithGoogle(
    GoogleUserReq googleUserReq,
  ) async {
    return await sl<AuthFirebaseService>().signInWithGoogle(googleUserReq);
  }

  @override
  Future<Either> getUser() async {
    return await sl<AuthFirebaseService>().getUser();
  }
}
