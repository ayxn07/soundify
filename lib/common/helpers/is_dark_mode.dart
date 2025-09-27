import 'package:flutter/material.dart';

extension IsDarkMode on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
