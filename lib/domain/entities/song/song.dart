import 'package:cloud_firestore/cloud_firestore.dart';

class SongEntity {
  final String title;
  final String artist;
  final num duration;
  final Timestamp releaseDate;
  final bool isFavorite;
  final String songId;

  //New Added
  final bool? isPublic;
  final String? ownerUid;
  final String? storageAudioPath;
  final String? storageCoverPath;

  // Resolved URLs
  final String? audioUrl;
  final String? coverUrl;

  SongEntity({
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
    this.audioUrl,
    this.coverUrl,
  });
  SongEntity copyWith({
    String? title,
    String? artist,
    num? duration,
    Timestamp? releaseDate,
    bool? isFavorite,
    String? songId,
    bool? isPublic,
    String? ownerUid,
    String? storageAudioPath,
    String? storageCoverPath,
    String? audioUrl,
    String? coverUrl,
  }) {
    return SongEntity(
      title: title ?? this.title,
      artist: artist ?? this.artist,
      duration: duration ?? this.duration,
      releaseDate: releaseDate ?? this.releaseDate,
      isFavorite: isFavorite ?? this.isFavorite,
      songId: songId ?? this.songId,
      isPublic: isPublic ?? this.isPublic,
      ownerUid: ownerUid ?? this.ownerUid,
      storageAudioPath: storageAudioPath ?? this.storageAudioPath,
      storageCoverPath: storageCoverPath ?? this.storageCoverPath,
      audioUrl: audioUrl ?? this.audioUrl,
      coverUrl: coverUrl ?? this.coverUrl,
    );
  }
}
