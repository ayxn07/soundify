import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotify_app_clone/domain/entities/song/song.dart';

class SongModel {
  String? title;
  String? artist;
  num? duration;
  Timestamp? releaseDate;
  bool? isFavorite;
  String? songId;

  //New Added
  bool? isPublic;
  String? ownerUid;
  String? storageAudioPath;
  String? storageCoverPath;

  SongModel({
    required this.title,
    required this.artist,
    required this.duration,
    required this.releaseDate,
    required this.isFavorite,
    required this.songId,
    this.isPublic,
    this.ownerUid,
    this.storageAudioPath,
    this.storageCoverPath,
  });

  SongModel.fromJson(Map<String, dynamic> data) {
    title = data['title'];
    artist = data['artist'];
    duration = data['duration'];
    releaseDate = data['releaseDate'];

    //New Added
    isPublic = data['isPublic'] ?? true;
    ownerUid = data['ownerUid'];
    storageAudioPath = data['storageAudioPath'];
    storageCoverPath = data['storageCoverPath'];
  }
}

extension SongModelX on SongModel {
  SongEntity toEntity() {
    return SongEntity(
      title: title!,
      artist: artist!,
      duration: duration!,
      releaseDate: releaseDate!,
      isFavorite: isFavorite!,
      songId: songId!,
      isPublic: isPublic,
      ownerUid: ownerUid,
      storageAudioPath: storageAudioPath,
      storageCoverPath: storageCoverPath,
    );
  }
}
