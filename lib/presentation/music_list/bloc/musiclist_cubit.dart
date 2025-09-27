import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_app_clone/domain/entities/song/song.dart';
import 'package:spotify_app_clone/presentation/music_list/bloc/musiclist_state.dart';

import '../../../data/sources/storage/storage_url_resolver.dart';
import '../../../domain/usecases/song/get_musiclist.dart';
import '../../../service_locator.dart';

class MusiclistCubit extends Cubit<MusiclistState> {
  MusiclistCubit() : super(MusiclistLoading());
  Future<void> getMusiclist() async {
    emit(MusiclistLoading());
    final either = await sl<GetMusiclistUseCase>().call();

    await either.fold<Future<void>>(
      (l) async {
        emit(MusiclistLoadFailure());
      },
      (data) async {
        final songs = data as List<SongEntity>;
        final resolver = sl<StorageUrlResolver>();
        final resolved = await Future.wait(
          songs.map((s) async {
            if (s.isPublic == false) {
              final audio = s.storageAudioPath != null
                  ? await resolver.urlFor(s.storageAudioPath!)
                  : null;
              final cover = s.storageCoverPath != null
                  ? await resolver.urlFor(s.storageCoverPath!)
                  : null;
              return s.copyWith(audioUrl: audio, coverUrl: cover);
            }
            return s;
          }),
        );
        emit(MusiclistLoaded(songs: resolved));
      },
    );
  }
}
