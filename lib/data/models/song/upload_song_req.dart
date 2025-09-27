class UploadSongReq {
  final String localAudioPath;
  final String title;
  final String artist;
  final num durationSeconds;
  final DateTime releaseDate;
  final String? localCoverPath;
  final bool isPublic;

  UploadSongReq({
    required this.localAudioPath,
    required this.title,
    required this.artist,
    required this.durationSeconds,
    required this.releaseDate,
    this.localCoverPath,
    required this.isPublic,
  });
}
