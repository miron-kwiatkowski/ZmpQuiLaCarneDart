import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../network/auth_interceptor.dart';
import '../network/api_client.dart';
import '../network/offline_queue_manager.dart';
import '../network/auth_token_provider.dart';
import '../database/local_database.dart';

// WebSocket Module
import '../websocket/data/services/websocket_service.dart';
import '../websocket/presentation/cubit/websocket_cubit.dart';

// Auth Module
import '../../features/auth_module/data/repositories/auth_repository_impl.dart';
import '../../features/auth_module/data/datasources/auth_remote_datasource.dart';
import '../../features/auth_module/domain/repositories/auth_repository.dart';
import '../../features/auth_module/domain/usecases/auth_usecases.dart';
import '../../features/auth_module/presentation/cubit/auth_cubit.dart';

// Waiter Module - Repositories
import '../../features/waiter_module/data/repositories/waiter_repository_impl.dart';
import '../../features/waiter_module/data/datasources/waiter_remote_datasource.dart';
import '../../features/waiter_module/data/datasources/waiter_local_datasource.dart';
import '../../features/waiter_module/domain/repositories/waiter_repository.dart';
import '../../features/waiter_module/domain/usecases/waiter_usecases.dart';

// Waiter Module - Cubits
import '../../features/waiter_module/presentation/cubits/tables/tables_cubit_export.dart';
import '../../features/waiter_module/presentation/cubits/orders/orders_cubit_export.dart';
import '../../features/waiter_module/presentation/cubits/reports/reports_cubit_export.dart';

/// Globalny injector zależności
///
/// Wzorzec: Service Locator Pattern (GetIt)
/// Dlaczego: Umożliwia wstrzykiwanie zależności bez użycia widgetów,
/// łatwe testowanie przez mockowanie, centralne zarządzanie instancjami
final sl = GetIt.instance;

/// Inicjalizacja wszystkich zależności
Future<void> initDependencies() async {
  // ==================== EXTERNAL ====================

  // Connectivity
  sl.registerLazySingleton<Connectivity>(() => Connectivity());

  // Secure Storage dla tokenów
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  // Dio instance
  sl.registerLazySingleton<Dio>(() => Dio());

  // ==================== CORE ====================

  // Local Database
  await LocalDatabase.initialize();

  // Auth Token Provider
  sl.registerLazySingleton<AuthTokenProvider>(
    () => AuthTokenProviderImpl(sl()),
  );

  // Network Info
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl()),
  );

  // Local DataSource
  sl.registerLazySingleton<WaiterLocalDataSource>(
    () => WaiterLocalDataSourceImpl(isar: LocalDatabase.instance),
  );

  // Offline Queue Manager
  sl.registerLazySingleton<OfflineQueueManager>(
    () => OfflineQueueManager(
      networkInfo: sl(), 
      database: LocalDatabase.instance, 
      dio: sl(),
    ),
  );

  // Auth Interceptor
  sl.registerLazySingleton<AuthInterceptor>(
    () => AuthInterceptor(sl(), sl()),
  );

  // API Client
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(
      authInterceptor: sl(),
      queueManager: sl(),
    ),
  );

  // ==================== WEBSOCKET MODULE ====================

  // WebSocket Config
  sl.registerLazySingleton<WebSocketConfig>(() => WebSocketConfig());

  // WebSocket Service
  sl.registerLazySingleton<WebSocketService>(
    () => WebSocketService(sl(), sl()),
  );

  // WebSocket Cubit
  sl.registerFactory(() => WebSocketCubit(sl()));

  // ==================== AUTH MODULE - DATA LAYER ====================

  // Remote Datasource
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: sl<ApiClient>().dio),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // ==================== AUTH MODULE - USE CASES ====================

  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RefreshTokenUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));

  // ==================== AUTH MODULE - CUBIT ====================

  sl.registerFactory(
    () => AuthCubit(
      loginUseCase: sl(),
      refreshTokenUseCase: sl(),
      logoutUseCase: sl(),
    ),
  );

  // ==================== WAITER MODULE - DATA LAYER ====================

  // Remote Datasource
  sl.registerLazySingleton<WaiterRemoteDataSource>(
    () => WaiterRemoteDataSourceImpl(dio: sl<ApiClient>().dio),
  );

  // Repository
  sl.registerLazySingleton<WaiterRepository>(
    () => WaiterRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      queueManager: sl(),
      networkInfo: sl(),
    ),
  );

  // ==================== WAITER MODULE - USE CASES ====================

  sl.registerLazySingleton(() => GetTablesUseCase(sl()));
  sl.registerLazySingleton(() => ChangeTableStatusUseCase(sl()));
  sl.registerLazySingleton(() => AddItemsToReservationUseCase(sl()));
  sl.registerLazySingleton(() => RemoveItemFromReservationUseCase(sl()));
  sl.registerLazySingleton(() => AssignWaiterUseCase(sl()));
  sl.registerLazySingleton(() => MarkAbsentUseCase(sl()));
  sl.registerLazySingleton(() => CreateGuestReportUseCase(sl()));
  sl.registerLazySingleton(() => GetDishesUseCase(sl()));
  sl.registerLazySingleton(() => GetReservationDetailsUseCase(sl()));

  // ==================== WAITER MODULE - CUBITS ====================

  // TablesCubit - factory, żeby za każdym razem tworzyć nową instancję
  sl.registerFactory(
    () => TablesCubit(
      getTablesUseCase: sl(),
      changeTableStatusUseCase: sl(),
    ),
  );

  // OrdersCubit
  sl.registerFactory(
    () => OrdersCubit(
      addItemsUseCase: sl(),
      removeItemUseCase: sl(),
      getDetailsUseCase: sl(),
    ),
  );

  // ReportsCubit
  sl.registerFactory(
    () => ReportsCubit(
      createReportUseCase: sl(),
    ),
  );
}


/// Inicjalizacja bazy danych (wywołuje initDependencies)
Future<void> initDatabase() async {
  await initDependencies();
}

/// Czyszczenie wszystkich zależności (np. przy wylogowaniu)
Future<void> resetDependencies() async {
  await sl.reset();
  await initDependencies();
}

/// Sprawdza czy wszystkie zależności są zarejestrowane
bool areDependenciesReady() {
  return sl.isRegistered<ApiClient>() &&
         sl.isRegistered<WaiterRepository>() &&
         sl.isRegistered<OfflineQueueManager>() &&
         sl.isRegistered<WaiterLocalDataSource>();
}
