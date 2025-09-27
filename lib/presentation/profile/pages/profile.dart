import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:spotify_app_clone/common/helpers/is_dark_mode.dart';
import 'package:spotify_app_clone/common/widgets/appbar/app_bar.dart';
import 'package:spotify_app_clone/common/widgets/favorite_button/favorite_button.dart';
import 'package:spotify_app_clone/core/configs/constants/app_urls.dart';
import 'package:spotify_app_clone/core/configs/theme/app_colors.dart';
import 'package:spotify_app_clone/presentation/profile/bloc/favorite_songs_cubit.dart';
import 'package:spotify_app_clone/presentation/profile/bloc/favorite_songs_state.dart';
import 'package:spotify_app_clone/presentation/profile/bloc/profile_info_state.dart';
import 'package:spotify_app_clone/presentation/song_player/pages/song_player.dart';
import 'package:spotify_app_clone/presentation/navigation/bloc/tab_refresh_cubit.dart';
import 'package:spotify_app_clone/presentation/navigation/bloc/nav_cubit.dart';
import '../../../core/configs/assets/app_vectors.dart';
import '../../choose_mode/bloc/theme_cubit.dart';
import '../bloc/profile_info_cubit.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _refreshTick = 0;
  ThemeMode? _selectedMode;

  void _selectMode(ThemeMode mode) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedMode = mode;
    });
    context.read<ThemeCubit>().updateTheme(mode);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TabRefreshCubit, NavTab?>(
      listenWhen: (prev, curr) => curr != null,
      listener: (context, tab) {
        if (tab == NavTab.profile) {
          setState(() => _refreshTick++);
        }
      },
      child: Scaffold(
        appBar: BasicAppBar(
          backgroundColor: context.isDarkMode
              ? AppColors.darkGrey
              : Colors.white,
          hideBack: true,
          title: Text(
            "Profile",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            KeyedSubtree(
              key: ValueKey('profileInfo$_refreshTick'),
              child: _profileInfo(context),
            ),
            SizedBox(height: 20),
            Expanded(
              child: KeyedSubtree(
                key: ValueKey("favoriteSongs$_refreshTick"),
                child: _favoriteSongs(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileInfo(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileInfoCubit()..getUser(),
      child: Container(
        height: MediaQuery.of(context).size.height / 2.8,
        width: double.infinity,
        decoration: BoxDecoration(
          color: context.isDarkMode ? AppColors.darkGrey : Colors.white,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(80),
            bottomRight: Radius.circular(80),
          ),
        ),
        child: BlocBuilder<ProfileInfoCubit, ProfileInfoState>(
          builder: (context, state) {
            if (state is ProfileInfoLoading) {
              return Container(
                alignment: Alignment.center,
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }
            if (state is ProfileInfoLoaded) {
              return Padding(
                padding: const EdgeInsets.only(top: 14.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: 93,
                      height: 93,

                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(state.userEntity.imageURL!),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      state.userEntity.email!,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      state.userEntity.fullName!,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () => _selectMode(ThemeMode.dark),
                              child: ClipOval(
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 10,
                                    sigmaY: 10,
                                  ),
                                  child: Container(
                                    height: 60,
                                    width: 60,
                                    decoration: BoxDecoration(
                                      color: _selectedMode == ThemeMode.dark
                                          ? Color(0xff30393c).withAlpha(180)
                                          : Colors.black.withAlpha(50),
                                      shape: BoxShape.circle,
                                    ),
                                    child: SvgPicture.asset(
                                      AppVectors.moon,
                                      fit: BoxFit.none,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "Dark Mode",
                              style: TextStyle(
                                color: context.isDarkMode
                                    ? Color(0xffDADADA)
                                    : Colors.black,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(width: 50),

                        // Light Mode Option
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () => _selectMode(ThemeMode.light),
                              child: ClipOval(
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 10,
                                    sigmaY: 10,
                                  ),
                                  child: Container(
                                    height: 60,
                                    width: 60,
                                    decoration: BoxDecoration(
                                      color: _selectedMode == ThemeMode.light
                                          ? Color(0xff30393c).withAlpha(180)
                                          : Colors.white.withAlpha(50),
                                      shape: BoxShape.circle,
                                    ),
                                    child: SvgPicture.asset(
                                      AppVectors.sun,
                                      fit: BoxFit.none,
                                      colorFilter: ColorFilter.mode(
                                        Colors.white,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "Light Mode",
                              style: TextStyle(
                                color: context.isDarkMode
                                    ? Color(0xffDADADA)
                                    : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }
            if (state is ProfileInfoFailure) {
              return Text("Please try again later");
            }
            return Container();
          },
        ),
      ),
    );
  }

  Widget _favoriteSongs() {
    return BlocProvider(
      create: (context) => FavoriteSongsCubit()..getFavoriteSongs(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Favorite Songs",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: context.isDarkMode
                    ? Color(0xffD6D6D6)
                    : Color(0xff222222),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: BlocBuilder<FavoriteSongsCubit, FavoriteSongsState>(
                builder: (context, state) {
                  if (state is FavoriteSongsLoading) {
                    return Container(
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }
                  if (state is FavoriteSongsLoaded) {
                    return ListView.separated(
                      scrollDirection: Axis.vertical,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    SongPlayerPage(
                                      songEntity: state.favoriteSongs[index],
                                    ),
                              ),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    height: 66,
                                    width: 66,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: NetworkImage(
                                          state.favoriteSongs[index].coverUrl ??
                                              '${AppUrls.coverFireStorage}${state.favoriteSongs[index].artist} - ${state.favoriteSongs[index].title}.jpg?${AppUrls.mediaAlt}',
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 15),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        state.favoriteSongs[index].title,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: context.isDarkMode
                                              ? Color(0xffE3E3E3)
                                              : Color(0xff000000),
                                        ),
                                      ),
                                      Text(
                                        state.favoriteSongs[index].artist,
                                        style: TextStyle(
                                          color: context.isDarkMode
                                              ? Color(0xffE3E3E3)
                                              : Color(0xff000000),
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              Row(
                                children: [
                                  Text(
                                    '${state.favoriteSongs[index].duration} min'
                                        .replaceAll('.', ':'),
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                      color: context.isDarkMode
                                          ? Color(0xffE3E3E3)
                                          : Color(0xff000000),
                                    ),
                                  ),
                                  SizedBox(width: 15),
                                  FavoriteButton(
                                    songEntity: state.favoriteSongs[index],
                                    key: UniqueKey(),
                                    function: () {
                                      context
                                          .read<FavoriteSongsCubit>()
                                          .removeSong(index);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 20),
                      itemCount: state.favoriteSongs.length,
                    );
                  }
                  if (state is FavoriteSongsLoadFailure) {
                    return Text("Please try again later.");
                  }
                  return Container();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
