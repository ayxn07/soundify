import 'package:flutter_bloc/flutter_bloc.dart';

enum NavTab { home, music, profile }

class NavCubit extends Cubit<NavTab> {
  NavCubit() : super(NavTab.home);
  void setTab(NavTab tab) => emit(tab);
  int get index => NavTab.values.indexOf(state);
  void setIndex(int i) => emit(NavTab.values[i]);
}
