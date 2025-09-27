import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_app_clone/core/configs/theme/app_colors.dart';
import 'package:spotify_app_clone/presentation/home/pages/home.dart';
import 'package:spotify_app_clone/presentation/music_list/pages/music_list.dart';
import 'package:spotify_app_clone/presentation/navigation/bloc/nav_cubit.dart';
import 'package:spotify_app_clone/presentation/profile/pages/profile.dart';
import 'package:spotify_app_clone/presentation/navigation/bloc/tab_refresh_cubit.dart';

class NavScaffold extends StatelessWidget {
  const NavScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => NavCubit()),
        BlocProvider(create: (_) => TabRefreshCubit()),
      ],
      child: const _NavView(),
    );
  }
}

class _NavView extends StatelessWidget {
  const _NavView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavCubit, NavTab>(
      builder: (context, state) {
        final currentIndex = context.read<NavCubit>().index;

        return Scaffold(
          body: IndexedStack(
            index: currentIndex,
            children: const [HomePage(), MusicList(), ProfilePage()],
          ),
          bottomNavigationBar: NavigationBarTheme(
            data: NavigationBarThemeData(
              indicatorColor: AppColors.primary,
              labelTextStyle: WidgetStateProperty.all(
                TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
            child: NavigationBar(
              selectedIndex: currentIndex,
              onDestinationSelected: (i) {
                HapticFeedback.lightImpact();
                context.read<NavCubit>().setIndex(i);
                context.read<TabRefreshCubit>().refresh(NavTab.values[i]);
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded, color: Colors.white),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.music_note_outlined),
                  selectedIcon: Icon(
                    Icons.music_note_rounded,
                    color: Colors.white,
                  ),

                  label: "Music",
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person_rounded, color: Colors.white),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
