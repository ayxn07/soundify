import '../../../domain/entities/song/song.dart';

abstract class MusiclistState {}

class MusiclistLoading extends MusiclistState {}

class MusiclistLoaded extends MusiclistState {
  final List<SongEntity> songs;

  MusiclistLoaded({required this.songs});
}

class MusiclistLoadFailure extends MusiclistState {}
