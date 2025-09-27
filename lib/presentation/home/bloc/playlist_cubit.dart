import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_app_clone/data/sources/storage/storage_url_resolver.dart';
import 'package:spotify_app_clone/domain/entities/song/song.dart';
import 'package:spotify_app_clone/domain/usecases/song/get_playlist.dart';
import 'package:spotify_app_clone/presentation/home/bloc/playlist_state.dart';

import '../../../service_locator.dart';

class PlaylistCubit extends Cubit<PlaylistState> {
  PlaylistCubit() : super(PlaylistLoading());
  Future<void> getPlaylist() async {
    emit(PlaylistLoading());
    final either = await sl<GetPlaylistUseCase>().call();

    await either.fold<Future<void>>(
      (l) async {
        emit(PlaylistLoadFailure());
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
        emit(PlaylistLoaded(songs: resolved));
      },
    );
  }
}
