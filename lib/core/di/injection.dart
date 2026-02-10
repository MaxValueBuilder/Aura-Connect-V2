import 'package:aura/core/network/dio_client.dart';
import 'package:aura/features/auth/auth_cubit.dart';
import 'package:aura/features/consultation/consultation_cubit.dart';
import 'package:aura/features/navigation/navigation_cubit.dart';
import 'package:aura/features/notification/notification_cubit.dart';
import 'package:aura/features/patient/patient_cubit.dart';
import 'package:aura/features/settings/settings_cubit.dart';
import 'package:aura/features/subscription/subscription_cubit.dart';
import 'package:aura/services/auth_service.dart';
import 'package:aura/services/consultation_service.dart';
import 'package:aura/services/notification_service.dart';
import 'package:aura/services/patient_service.dart';
import 'package:aura/services/settings_service.dart';
import 'package:aura/services/subscription_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../constants/app_constants.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Core
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  // Network
  getIt.registerLazySingleton<DioClient>(
    () => DioClient(getIt<FlutterSecureStorage>()),
  );

  getIt.registerLazySingleton<Dio>(() => getIt<DioClient>().dio);

  // Services
  getIt.registerLazySingleton<AuthService>(() => AuthService(getIt<Dio>()));

  // Import ConsultationService
  getIt.registerLazySingleton<ConsultationService>(
    () => ConsultationService(getIt<Dio>(), getIt<FlutterSecureStorage>()),
  );

  // Settings Service
  getIt.registerLazySingleton<SettingsService>(
    () => SettingsService(getIt<Dio>()),
  );

  // Patient Service
  getIt.registerLazySingleton<PatientService>(
    () => PatientService(getIt<Dio>()),
  );

  // Subscription Service
  getIt.registerLazySingleton<SubscriptionService>(
    () => SubscriptionService(getIt<Dio>()),
  );

  // Notification Service
  getIt.registerLazySingleton<NotificationService>(
    () => NotificationService(getIt<Dio>()),
  );

  // API Service
  // getIt.registerLazySingleton<ApiService>(
  //   () => ApiService(getIt<Dio>(), baseUrl: AppConstants.apiBaseUrl),
  // );

  // getIt.registerLazySingleton<RecordingService>(() => RecordingService());

  // Repositories
  // getIt.registerLazySingleton<PatientRepository>(
  //   () => PatientRepositoryImpl(getIt<ApiService>()),
  // );

  // getIt.registerLazySingleton<ConsultationRepository>(
  //   () => ConsultationRepositoryImpl(getIt<ApiService>()),
  // );

  // getIt.registerLazySingleton<AIRepository>(
  //   () => AIRepositoryImpl(getIt<ApiService>()),
  // );

  // Cubits
  getIt.registerFactory<AuthCubit>(
    () => AuthCubit(
      getIt<FlutterSecureStorage>(),
      getIt<AuthService>(),
    ),
  );

  // getIt.registerFactory<PatientCubit>(
  //   () => PatientCubit(getIt<PatientRepository>()),
  // );

  getIt.registerFactory<ConsultationCubit>(
    () => ConsultationCubit(getIt<ConsultationService>()),
  );

  // Navigation
  getIt.registerLazySingleton<NavigationCubit>(
    () => NavigationCubit(),
  );

  // Settings
  getIt.registerLazySingleton<SettingsCubit>(
    () => SettingsCubit(getIt<SettingsService>()),
  );

  // Patient
  getIt.registerLazySingleton<PatientCubit>(
    () => PatientCubit(getIt<PatientService>()),
  );

  // Subscription
  getIt.registerLazySingleton<SubscriptionCubit>(
    () => SubscriptionCubit(getIt<SubscriptionService>()),
  );

  // Notification
  getIt.registerLazySingleton<NotificationCubit>(
    () => NotificationCubit(getIt<NotificationService>()),
  );

  // getIt.registerFactory<RecordingCubit>(
  //   () => RecordingCubit(
  //     getIt<RecordingService>(),
  //     getIt<AIRepository>(),
  //   ),
  // );
}
