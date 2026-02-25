import 'package:aura/core/di/injection.dart';
import 'package:aura/core/network/dio_client.dart';
import 'package:aura/core/routes/app_routes.dart';
import 'package:aura/features/auth/auth_cubit.dart';
import 'package:aura/features/consultation/consultation_cubit.dart';
import 'package:aura/features/navigation/navigation_cubit.dart';
import 'package:aura/features/notification/notification_cubit.dart';
import 'package:aura/features/patient/patient_cubit.dart';
import 'package:aura/features/settings/settings_cubit.dart';
import 'package:aura/features/subscription/subscription_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'core/theme/app_theme.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // Preserve the native splash screen
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await dotenv.load(fileName: "assets/.env");

  // Initialize Stripe
  Stripe.publishableKey = dotenv.env["STRIPE_PUBLISHABLE_KEY"]!;
  Stripe.merchantIdentifier = 'merchant.com.example.aura';

  // Setup dependency injection
  await setupDependencies();

  runApp(const AuraApp());

  // Remove the splash screen after the first frame
  WidgetsBinding.instance.addPostFrameCallback((_) {
    FlutterNativeSplash.remove();
  });
}

/// Global key for the root Navigator so we can navigate from BlocListener (whose context is above MaterialApp).
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class AuraApp extends StatelessWidget {
  const AuraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) {
            final auth = getIt<AuthCubit>();
            auth.initialize();
            getIt<DioClient>().onSessionExpired = () => auth.logout();
            return auth;
          },
        ),
        BlocProvider<ConsultationCubit>(
          create: (context) => getIt<ConsultationCubit>(),
        ),
        BlocProvider<NavigationCubit>.value(value: getIt<NavigationCubit>()),
        BlocProvider<SettingsCubit>.value(value: getIt<SettingsCubit>()),
        BlocProvider<PatientCubit>.value(value: getIt<PatientCubit>()),
        BlocProvider<SubscriptionCubit>.value(
          value: getIt<SubscriptionCubit>(),
        ),
        BlocProvider<NotificationCubit>.value(
          value: getIt<NotificationCubit>(),
        ),
      ],
      child: BlocListener<AuthCubit, AuthState>(
        listenWhen: (previous, current) =>
            previous.status == AuthStatus.authenticated &&
            current.status == AuthStatus.unauthenticated,
        listener: (_, __) {
          rootNavigatorKey.currentState?.pushNamedAndRemoveUntil(
            AppRoutes.login,
            (route) => false,
          );
        },
        child: MaterialApp(
          navigatorKey: rootNavigatorKey,
          title: 'Aura Connect',
          theme: AppTheme.lightTheme,
          debugShowCheckedModeBanner: false,
          initialRoute: AppRoutes.login,
          onGenerateRoute: AppRouter.generateRoute,
        ),
      ),
    );
  }
}
