import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:spotify_app_clone/common/helpers/is_dark_mode.dart';
import 'package:spotify_app_clone/common/widgets/appbar/app_bar.dart';
import 'package:spotify_app_clone/core/configs/assets/app_images.dart';
import 'package:spotify_app_clone/core/configs/assets/app_vectors.dart';
import 'package:spotify_app_clone/core/configs/theme/app_colors.dart';
import 'package:spotify_app_clone/presentation/auth/pages/signup_or_signin_page.dart';
import 'package:spotify_app_clone/presentation/home/widgets/new_songs.dart';
import 'package:spotify_app_clone/presentation/home/widgets/playlist.dart';
import 'package:spotify_app_clone/domain/usecases/auth/signout.dart';
import 'package:spotify_app_clone/service_locator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_app_clone/presentation/navigation/bloc/tab_refresh_cubit.dart';
import 'package:spotify_app_clone/presentation/navigation/bloc/nav_cubit.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _refreshTick = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TabRefreshCubit, NavTab?>(
      listenWhen: (prev, curr) => curr != null,
      listener: (context, tab) {
        if (tab == NavTab.home) {
          setState(() => _refreshTick++);
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
            tooltip: 'Logout',
            onPressed: () async {
              await sl<SignoutUseCase>().call();
              HapticFeedback.lightImpact();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const SignupOrSigninPage()),
                  (route) => false,
                );
              }
            },
            icon: const Icon(Icons.logout),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _homeTopCard(),
              _tabs(),
              SizedBox(
                height: 260,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    NewSongs(key: ValueKey('newSongs$_refreshTick')),
                    Container(),
                    Container(),
                  ],
                ),
              ),
              Playlist(key: ValueKey('playlist$_refreshTick')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _homeTopCard() {
    return Center(
      child: SizedBox(
        height: 150,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: SvgPicture.asset(AppVectors.homeTopCard),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: EdgeInsets.only(right: 40.0),
                child: Image.asset(AppImages.topCardImage),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabs() {
    return TabBar(
      controller: _tabController,
      labelColor: context.isDarkMode ? Colors.white : Colors.black,

      isScrollable: false,
      padding: EdgeInsets.symmetric(vertical: 25, horizontal: 16),
      dividerColor: Colors.transparent,

      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(width: 2.5, color: AppColors.primary),
        insets: EdgeInsets.symmetric(horizontal: 5),
        borderRadius: BorderRadius.circular(15),
      ),
      splashBorderRadius: BorderRadius.circular(10),
      tabs: [
        Text(
          "Songs",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        Text(
          "Video",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        Text(
          "Artists",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
