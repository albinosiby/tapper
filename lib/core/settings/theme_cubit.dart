import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/services/local_storage_service.dart';

/// Light / dark / system theme, saved between launches.
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this._storage) : super(_read(_storage));

  final LocalStorageService _storage;

  static ThemeMode _read(LocalStorageService storage) =>
      ThemeMode.values.firstWhere(
        (m) => m.name == storage.savedThemeMode,
        orElse: () => ThemeMode.system,
      );

  Future<void> setMode(ThemeMode mode) async {
    emit(mode);
    await _storage.setThemeMode(mode.name);
  }
}
