import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_app_clone/presentation/upload/bloc/upload_song_state.dart';

import '../../../data/models/song/upload_song_req.dart';
import '../../../domain/usecases/song/upload_song.dart';
import '../../../service_locator.dart';

class UploadSongCubit extends Cubit<UploadSongState> {
  UploadSongCubit() : super(UploadIdle());

  Future<void> upload(UploadSongReq req) async {
    emit(UploadUploading());
    final res = await sl<UploadSongUseCase>().call(params: req);
    res.fold(
      (l) {
        emit(UploadFailure(l.toString()));
      },
      (r) {
        emit(UploadSuccess());
      },
    );
  }
}
