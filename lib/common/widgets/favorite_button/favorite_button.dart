import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_app_clone/common/bloc/favorite_button/favorite_button_cubit.dart';
import 'package:spotify_app_clone/common/bloc/favorite_button/favorite_button_state.dart';
import 'package:spotify_app_clone/core/configs/theme/app_colors.dart';
import 'package:spotify_app_clone/domain/entities/song/song.dart';

class FavoriteButton extends StatelessWidget {
  final SongEntity songEntity;
  final Function? function;

  const FavoriteButton({super.key, required this.songEntity, this.function});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FavoriteButtonCubit(),
      child: BlocBuilder<FavoriteButtonCubit, FavoriteButtonState>(
        builder: (context, state) {
          if (state is FavoriteButtonInitil) {
            return GestureDetector(
              onTap: () async {
                HapticFeedback.lightImpact();
                await context.read<FavoriteButtonCubit>().favoriteButtonUpdated(
                  songEntity.songId,
                );
                if (function != null) {
                  function!();
                }
              },
              child: Icon(
                songEntity.isFavorite
                    ? CupertinoIcons.heart_fill
                    : CupertinoIcons.heart,
                color: AppColors.primary,
              ),
            );
          }
          if (state is FavoriteButtonUpdated) {
            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                context.read<FavoriteButtonCubit>().favoriteButtonUpdated(
                  songEntity.songId,
                );
              },
              child: Icon(
                state.isFavorite
                    ? CupertinoIcons.heart_fill
                    : CupertinoIcons.heart,
                color: AppColors.primary,
              ),
            );
          }

          return Container();
        },
      ),
    );
  }
}
