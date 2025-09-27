abstract class UploadSongState {}

class UploadIdle extends UploadSongState {}

class UploadPicking extends UploadSongState {}

class UploadUploading extends UploadSongState {
  final double? progress;
  UploadUploading({this.progress});
}

class UploadSuccess extends UploadSongState {}

class UploadFailure extends UploadSongState {
  final String message;
  UploadFailure(this.message);
}
