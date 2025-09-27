import 'package:dartz/dartz.dart';
import 'package:spotify_app_clone/data/models/song/upload_song_req.dart';

abstract class SongsRepository {
  Future<Either> getNewSongs();
  Future<Either> getPlayList();
  Future<Either> addOrRemoveFavoriteSongs(String songId);
  Future<bool> isFavoriteSong(String songId);
  Future<Either> getUserFavoriteSongs();

  //New Added
  Future<Either> uploadSong(UploadSongReq req);
}
