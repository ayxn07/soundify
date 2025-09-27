import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_app_clone/domain/entities/song/song.dart';
import 'package:spotify_app_clone/domain/usecases/song/get_new_songs.dart';
import 'package:spotify_app_clone/presentation/home/bloc/new_songs_state.dart';

import '../../../data/sources/storage/storage_url_resolver.dart';
import '../../../service_locator.dart';

class NewSongsCubit extends Cubit<NewSongsState> {
  NewSongsCubit() : super(NewSongsLoading());

  Future<void> getNewSongs() async {
    emit(NewSongsLoading());
    final either = await sl<GetNewSongsUseCase>().call();

    await either.fold<Future<void>>(
      (l) async {
        emit(NewSongsLoadFailure());
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
        emit(NewSongsLoaded(songs: resolved));
      },
    );
  }
}
