import 'package:dartz/dartz.dart';
import 'package:spotify_app_clone/core/usecase/usecase.dart';
import 'package:spotify_app_clone/data/models/song/upload_song_req.dart';

import '../../../service_locator.dart';
import '../../repository/song/song.dart';

class UploadSongUseCase implements UseCase<Either, UploadSongReq> {
  @override
  Future<Either> call({UploadSongReq? params}) async {
    return await sl<SongsRepository>().uploadSong(params!);
  }
}
