import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:spotify_app_clone/common/helpers/is_dark_mode.dart';
import 'package:spotify_app_clone/common/widgets/favorite_button/favorite_button.dart';
import 'package:spotify_app_clone/core/configs/assets/app_vectors.dart';
import 'package:spotify_app_clone/core/configs/theme/app_colors.dart';
import 'package:spotify_app_clone/domain/entities/song/song.dart';
import 'package:spotify_app_clone/presentation/home/bloc/playlist_cubit.dart';
import 'package:spotify_app_clone/presentation/home/bloc/playlist_state.dart';
import 'package:spotify_app_clone/presentation/song_player/pages/song_player.dart';

class Playlist extends StatelessWidget {
  const Playlist({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PlaylistCubit()..getPlaylist(),
      child: BlocBuilder<PlaylistCubit, PlaylistState>(
        builder: (context, state) {
          if (state is PlaylistLoading) {
            return Container(
              height: 200,
              alignment: Alignment.center,
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (state is PlaylistLoaded) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 25),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Playlist",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: context.isDarkMode
                                  ? Color(0xffDBDBDB)
                                  : Color(0xff131313),
                            ),
                          ),
                          SizedBox(width: 10),
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              context.read<PlaylistCubit>().getPlaylist();
                            },
                            child: SizedBox(
                              height: 20,
                              width: 20,
                              child: Icon(
                                Icons.refresh,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "See More",
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: context.isDarkMode
                              ? Color(0xffC6C6C6)
                              : Color(0xff131313),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _songs(state.songs),
                ],
              ),
            );
          }
          return Container();
        },
      ),
    );
  }

  Widget _songs(List<SongEntity> songs) {
    return ListView.separated(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) =>
                    SongPlayerPage(songEntity: songs[index]),
              ),
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.isDarkMode
                          ? AppColors.darkGrey
                          : Color(0xffE6E6E6),
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: SvgPicture.asset(
                        AppVectors.play,
                        height: 22,
                        colorFilter: ColorFilter.mode(
                          context.isDarkMode
                              ? Color(0xff959595)
                              : Color(0xff555555),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: [
                      Text(
                        songs[index].title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: context.isDarkMode
                              ? Color(0xffD6D6D6)
                              : Color(0xff000000),
                        ),
                      ),
                      Text(
                        songs[index].artist,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: context.isDarkMode
                              ? Color(0xffD6D6D6)
                              : Color(0xff000000),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    '${songs[index].duration} min'.replaceAll('.', ':'),
                    style: TextStyle(
                      color: context.isDarkMode
                          ? Color(0xffD6D6D6)
                          : Color(0xff000000),
                    ),
                  ),
                  const SizedBox(width: 15),
                  FavoriteButton(songEntity: songs[index]),
                ],
              ),
            ],
          ),
        );
      },
      separatorBuilder: (context, index) => SizedBox(height: 20),
      itemCount: songs.length,
    );
  }
}
