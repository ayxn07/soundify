import 'package:get_it/get_it.dart';
import 'package:spotify_app_clone/data/repository/auth/auth_repository_impl.dart';
import 'package:spotify_app_clone/data/repository/song/song_repository_impl.dart';
import 'package:spotify_app_clone/data/sources/auth/auth_firebase_service.dart';
import 'package:spotify_app_clone/data/sources/song/song_firebase_service.dart';
import 'package:spotify_app_clone/data/sources/song/song_uploader_service.dart';
import 'package:spotify_app_clone/data/sources/storage/storage_url_resolver.dart';
import 'package:spotify_app_clone/domain/repository/auth/auth.dart';
import 'package:spotify_app_clone/domain/repository/song/song.dart';
import 'package:spotify_app_clone/domain/usecases/auth/get_user.dart';
import 'package:spotify_app_clone/domain/usecases/auth/signin.dart';
import 'package:spotify_app_clone/domain/usecases/auth/signin_with_google.dart';
import 'package:spotify_app_clone/domain/usecases/auth/signout.dart';
import 'package:spotify_app_clone/domain/usecases/auth/signup.dart';
import 'package:spotify_app_clone/domain/usecases/song/add_or_remove_favorite_song.dart';
import 'package:spotify_app_clone/domain/usecases/song/get_musiclist.dart';
import 'package:spotify_app_clone/domain/usecases/song/get_new_songs.dart';
import 'package:spotify_app_clone/domain/usecases/song/get_playlist.dart';
import 'package:spotify_app_clone/domain/usecases/song/get_user_favorite_songs.dart';
import 'package:spotify_app_clone/domain/usecases/song/is_favorite_song.dart';
import 'package:spotify_app_clone/data/sources/local/local_storage_service.dart';

import 'domain/usecases/song/upload_song.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  sl.registerSingleton<AuthFirebaseService>(AuthFirebaseServiceImpl());
  sl.registerSingleton<SongFirebaseService>(SongFirebaseServiceImpl());
  sl.registerSingleton<AuthRepository>(AuthRepositoryImpl());
  sl.registerSingleton<SongsRepository>(SongRepositoryImpl());
  sl.registerSingleton<SignupUseCase>(SignupUseCase());
  sl.registerSingleton<SigninUseCase>(SigninUseCase());
  sl.registerSingleton<SigninWithGoogleUsecase>(SigninWithGoogleUsecase());
  sl.registerSingleton<GetNewSongsUseCase>(GetNewSongsUseCase());
  sl.registerSingleton<GetPlaylistUseCase>(GetPlaylistUseCase());
  sl.registerSingleton<AddOrRemoveFavoriteSongUseCase>(
    AddOrRemoveFavoriteSongUseCase(),
  );
  sl.registerSingleton<IsFavoriteSongUseCase>(IsFavoriteSongUseCase());
  sl.registerSingleton<GetUserUseCase>(GetUserUseCase());
  sl.registerSingleton<GetUserFavoriteSongsUseCase>(
    GetUserFavoriteSongsUseCase(),
  );
  sl.registerLazySingleton<LocalStorageService>(
    () => LocalStorageServiceImpl(),
  );
  sl.registerSingleton<SignoutUseCase>(SignoutUseCase());
  sl.registerSingleton<GetMusiclistUseCase>(GetMusiclistUseCase());

  //New Added
  sl.registerLazySingleton<SongUploaderService>(
    () => SongUploaderServiceImpl(),
  );
  sl.registerSingleton<UploadSongUseCase>(UploadSongUseCase());

  sl.registerLazySingleton<StorageUrlResolver>(() => StorageUrlResolverImpl());
}
