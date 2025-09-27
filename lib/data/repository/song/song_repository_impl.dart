import 'package:dartz/dartz.dart';
import 'package:spotify_app_clone/data/models/song/upload_song_req.dart';
import 'package:spotify_app_clone/data/sources/song/song_firebase_service.dart';
import 'package:spotify_app_clone/data/sources/song/song_uploader_service.dart';
import 'package:spotify_app_clone/domain/repository/song/song.dart';

import '../../../service_locator.dart';

class SongRepositoryImpl extends SongsRepository {
  @override
  Future<Either> getNewSongs() async {
    return await sl<SongFirebaseService>().getNewSongs();
  }

  @override
  Future<Either> getPlayList() async {
    return await sl<SongFirebaseService>().getPlayList();
  }

  @override
  Future<Either> addOrRemoveFavoriteSongs(String songId) async {
    return await sl<SongFirebaseService>().addOrRemoveFavoriteSongs(songId);
  }

  @override
  Future<bool> isFavoriteSong(String songId) async {
    return await sl<SongFirebaseService>().isFavoriteSong(songId);
  }

  @override
  Future<Either> getUserFavoriteSongs() async {
    return await sl<SongFirebaseService>().getUserFavoriteSongs();
  }

  //New Added
  @override
  Future<Either> uploadSong(UploadSongReq req) async {
    try {
      final id = await sl<SongUploaderService>().uploadSongAndCreateDoc(
        localAudioPath: req.localAudioPath,
        title: req.title,
        artist: req.artist,
        durationSeconds: req.durationSeconds,
        releaseDate: req.releaseDate,
        localCoverPath: req.localCoverPath,
        isPublic: req.isPublic,
      );
      return Right(id);
    } catch (e) {
      return Left("Upload failed, please try again later.");
    }
  }
}
