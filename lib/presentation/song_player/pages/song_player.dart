import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_app_clone/common/helpers/is_dark_mode.dart';
import 'package:spotify_app_clone/common/widgets/appbar/app_bar.dart';
import 'package:spotify_app_clone/core/configs/theme/app_colors.dart';
import 'package:spotify_app_clone/domain/entities/song/song.dart';
import 'package:spotify_app_clone/presentation/song_player/bloc/song_player_cubit.dart';
import 'package:spotify_app_clone/presentation/song_player/bloc/song_player_state.dart';

import '../../../common/widgets/favorite_button/favorite_button.dart';
import '../../../core/configs/constants/app_urls.dart';

class SongPlayerPage extends StatelessWidget {
  final SongEntity songEntity;
  const SongPlayerPage({super.key, required this.songEntity});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BasicAppBar(
        hideBack: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 5.0),
          child: Text(
            "Now Playing",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        action: IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.more_vert_rounded,
            color: context.isDarkMode ? Color(0xffDDDDDD) : Color(0xff7D7D7D),
          ),
        ),
      ),
      body: BlocProvider(
        create: (_) => SongPlayerCubit()
          ..loadSong(
            songEntity.audioUrl ??
                '${AppUrls.songFireStorage}${songEntity.artist} - ${songEntity.title}.mp3?${AppUrls.mediaAlt}',
          ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            children: [
              _songCover(context),
              const SizedBox(height: 25),
              _songDetail(context),
              const SizedBox(height: 20),
              _songPlayer(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _songCover(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 2.35,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage(
            songEntity.coverUrl ??
                '${AppUrls.coverFireStorage}${songEntity.artist} - ${songEntity.title}.jpg?${AppUrls.mediaAlt}',
          ),
        ),
      ),
    );
  }

  Widget _songDetail(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: [
              Text(
                songEntity.title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: context.isDarkMode
                      ? Color(0xffDFDFDF)
                      : Color(0xff000000),
                ),
              ),
              Text(
                songEntity.artist,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: context.isDarkMode
                      ? Color(0xffBABABA)
                      : Color(0xff404040),
                ),
              ),
            ],
          ),
          FavoriteButton(songEntity: songEntity),
        ],
      ),
    );
  }

  Widget _songPlayer(BuildContext context) {
    return BlocBuilder<SongPlayerCubit, SongPlayerState>(
      builder: (context, state) {
        if (state is SongPlayerLoading) {
          return Container(
            alignment: Alignment.center,
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        if (state is SongPlayerLoaded) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),

            child: Column(
              children: [
                Slider(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  activeColor: context.isDarkMode
                      ? Color(0xffB7B7B7)
                      : Color(0xff434343),
                  thumbColor: AppColors.primary,
                  value: context
                      .read<SongPlayerCubit>()
                      .songPosition
                      .inSeconds
                      .toDouble(),
                  min: 0.0,
                  max: context
                      .read<SongPlayerCubit>()
                      .songDuration
                      .inSeconds
                      .toDouble(),
                  onChanged: (value) {
                    context.read<SongPlayerCubit>().updateSliderPosition(
                      Duration(seconds: value.toInt()),
                    );
                  },
                  onChangeEnd: (value) {
                    context.read<SongPlayerCubit>().seekTo(
                      Duration(seconds: value.toInt()),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatDuration(
                        context.read<SongPlayerCubit>().songPosition,
                      ),
                      style: TextStyle(
                        color: context.isDarkMode
                            ? Color(0xff878787)
                            : Color(0xff404040),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      formatDuration(
                        context.read<SongPlayerCubit>().songDuration,
                      ),
                      style: TextStyle(
                        color: context.isDarkMode
                            ? Color(0xff878787)
                            : Color(0xff404040),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.read<SongPlayerCubit>().playOrPauseSong();
                  },
                  child: Container(
                    height: 72,
                    width: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                    ),
                    child: Icon(
                      context.read<SongPlayerCubit>().audioPlayer.playing
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.white,
                      size: 38,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return Container();
      },
    );
  }

  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
