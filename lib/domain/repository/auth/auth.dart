import 'package:dartz/dartz.dart';
import 'package:spotify_app_clone/data/models/auth/create_user_req.dart';
import 'package:spotify_app_clone/data/models/auth/google_user_req.dart';
import 'package:spotify_app_clone/data/models/auth/signin_user_req.dart';

abstract class AuthRepository {
  Future<Either<dynamic, dynamic>> signup(CreateUserReq createUserReq);
  Future<Either<dynamic, dynamic>> signin(SigninUserReq signinUserReq);
  Future<Either<dynamic, dynamic>> signInWithGoogle(
    GoogleUserReq googleUserReq,
  );
  Future<Either<dynamic, dynamic>> getUser();
}
