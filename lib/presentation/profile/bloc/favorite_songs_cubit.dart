import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_app_clone/domain/entities/song/song.dart';
import 'package:spotify_app_clone/domain/usecases/song/get_user_favorite_songs.dart';
import 'package:spotify_app_clone/presentation/profile/bloc/favorite_songs_state.dart';

import '../../../data/sources/storage/storage_url_resolver.dart';
import '../../../service_locator.dart';

class FavoriteSongsCubit extends Cubit<FavoriteSongsState> {
  FavoriteSongsCubit() : super(FavoriteSongsLoading());
  List<SongEntity> favoriteSongs = [];
  Future<void> getFavoriteSongs() async {
    emit(FavoriteSongsLoading());
    final either = await sl<GetUserFavoriteSongsUseCase>().call();

    await either.fold<Future<void>>(
      (l) async {
        emit(FavoriteSongsLoadFailure());
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
        favoriteSongs = data;

        emit(FavoriteSongsLoaded(favoriteSongs: resolved));
      },
    );
  }

  void removeSong(int index) {
    favoriteSongs.removeAt(index);
    emit(FavoriteSongsLoaded(favoriteSongs: favoriteSongs));
  }
}
