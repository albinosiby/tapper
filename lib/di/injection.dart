import 'package:get_it/get_it.dart';

import '../config/app_config.dart';
import '../core/settings/theme_cubit.dart';
import '../modules/home/bloc/tapping_bloc.dart';
import '../modules/home/repositories/tapping_repository.dart';
import '../modules/home/repositories/tapping_repository_interface.dart';
import '../modules/setup/bloc/setup_bloc.dart';
import '../modules/setup/repositories/setup_repository.dart';
import '../modules/setup/repositories/setup_repository_interface.dart';
import '../utils/services/cache_service.dart';
import '../utils/services/local_storage_service.dart';
import '../utils/services/rest_api_service.dart';
import '../utils/services/secure_storage_service.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // === Shared services (always registered) ===
  getIt.registerSingleton<LocalStorageService>(LocalStorageService());
  await getIt<LocalStorageService>().init();
  getIt.registerLazySingleton<CacheService>(
    () => CacheService(getIt<LocalStorageService>()),
  );

  // === Backend-specific registration ===
  if (AppConfig.isFirebase) {
    _registerFirebaseDependencies();
  } else {
    _registerRestDependencies();
  }

  // === BLoCs / Cubits ===
  getIt.registerLazySingleton<ThemeCubit>(
    () => ThemeCubit(getIt<LocalStorageService>()),
  );
  getIt.registerFactory<SetupBloc>(() => SetupBloc(getIt<ISetupRepository>()));
  getIt.registerFactory<TappingBloc>(
    () => TappingBloc(getIt<ITappingRepository>(), getIt<ISetupRepository>()),
  );
}

void _registerRestDependencies() {
  getIt.registerLazySingleton<SecureStorageService>(
    () => SecureStorageService(),
  );
  getIt.registerLazySingleton<RestApiService>(
    () => RestApiService(getIt<SecureStorageService>()),
  );

  getIt.registerLazySingleton<ISetupRepository>(
    () => RestSetupRepository(getIt<RestApiService>(), getIt<CacheService>()),
  );
  getIt.registerLazySingleton<ITappingRepository>(
    () => RestTappingRepository(getIt<RestApiService>(), getIt<CacheService>()),
  );
}

void _registerFirebaseDependencies() {
  // Add Firebase services and repositories (FirebaseSetupRepository for
  // ISetupRepository, FirebaseTappingRepository for ITappingRepository)
  // once firebase_core etc. are added. The router guard needs
  // ISetupRepository registered.
}
