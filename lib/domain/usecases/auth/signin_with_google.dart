import 'package:dartz/dartz.dart';
import 'package:spotify_app_clone/core/usecase/usecase.dart';
import 'package:spotify_app_clone/data/models/auth/google_user_req.dart';
import 'package:spotify_app_clone/domain/repository/auth/auth.dart';

import '../../../service_locator.dart';

class NoParams {}

class SigninWithGoogleUsecase implements UseCase<Either, GoogleUserReq> {
  @override
  Future<Either> call({GoogleUserReq? params}) {
    // TODO: implement call
    return sl<AuthRepository>().signInWithGoogle(params!);
  }
}
