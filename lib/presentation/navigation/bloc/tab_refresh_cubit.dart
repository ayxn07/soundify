import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_app_clone/presentation/navigation/bloc/nav_cubit.dart';

class TabRefreshCubit extends Cubit<NavTab?> {
  TabRefreshCubit() : super(null);
  void refresh(NavTab tab) => emit(tab);
}
