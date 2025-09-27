import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:spotify_app_clone/common/helpers/is_dark_mode.dart';
import 'package:spotify_app_clone/common/widgets/appbar/app_bar.dart';
import 'package:spotify_app_clone/presentation/music_list/bloc/musiclist_cubit.dart';
import 'package:spotify_app_clone/presentation/music_list/bloc/musiclist_state.dart';
import 'package:spotify_app_clone/presentation/upload/bloc/upload_song_cubit.dart';
import 'package:spotify_app_clone/presentation/upload/pages/add_song_page.dart';
import '../../../common/widgets/favorite_button/favorite_button.dart';
import '../../../core/configs/assets/app_vectors.dart';
import '../../../core/configs/constants/app_urls.dart';
import '../../../core/configs/theme/app_colors.dart';
import '../../../domain/entities/song/song.dart';
import '../../song_player/pages/song_player.dart';
import 'package:spotify_app_clone/presentation/navigation/bloc/tab_refresh_cubit.dart';
import 'package:spotify_app_clone/presentation/navigation/bloc/nav_cubit.dart';

class MusicList extends StatefulWidget {
  const MusicList({super.key});

  @override
  State<MusicList> createState() => _MusicListState();
}

class _MusicListState extends State<MusicList> {
  int _refreshTick = 0;
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MusiclistCubit()..getMusiclist(),
      child: BlocListener<TabRefreshCubit, NavTab?>(
        listenWhen: (prev, curr) => curr != null,
        listener: (context, tab) {
          if (tab == NavTab.music) {
            setState(() => _refreshTick++);
            context.read<MusiclistCubit>().getMusiclist();
          }
        },
        child: Scaffold(
          appBar: BasicAppBar(
            hideBack: true,
            title: Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: SvgPicture.asset(AppVectors.logo, height: 40, width: 40),
            ),
            action: IconButton(
              onPressed: () async {
                final ok = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => UploadSongCubit(),
                      child: const AddSongPage(),
                    ),
                  ),
                );
                if (ok == true && context.mounted && mounted) {
                  context.read<MusiclistCubit>().getMusiclist();
                }
              },
              icon: const Icon(
                Icons.upload_file_rounded,
                color: AppColors.primary,
              ),
            ),
          ),

          body: BlocBuilder<MusiclistCubit, MusiclistState>(
            builder: (context, state) {
              if (state is MusiclistLoading) {
                return Container(
                  height: 200,
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }
              if (state is MusiclistLoaded) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 25),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        KeyedSubtree(
                          key: ValueKey('musiclist$_refreshTick'),
                          child: _musicList(state.songs),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return Container();
            },
          ),
        ),
      ),
    );
  }

  Widget _musicList(List<SongEntity> songs) {
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
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: NetworkImage(
                          songs[index].coverUrl ??
                              '${AppUrls.coverFireStorage}${songs[index].artist} - ${songs[index].title}.jpg?${AppUrls.mediaAlt}',
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
