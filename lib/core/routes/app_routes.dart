import 'package:aura/core/constants/consultation_status.dart';
import 'package:aura/screens/auth/login_screen.dart';
import 'package:aura/screens/auth/sign_up_screen.dart';
import 'package:aura/screens/clinic_setup/clinic_setup_screen.dart';
import 'package:aura/screens/consultation/consultation_workflow_screen.dart';
import 'package:aura/screens/history/completed_consultation_screen.dart';
import 'package:aura/screens/history/history_screen.dart';
import 'package:aura/screens/onboarding/onboarding_screen.dart';
import 'package:aura/screens/main_navigation_screen.dart';
import 'package:aura/screens/notifications/notification_history_screen.dart';
import 'package:aura/screens/splash_screen.dart';
import 'package:flutter/material.dart';

/// Route names constants
class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String dashboard = '/dashboard';
  static const String clinicSetup = '/clinic-setup';
  static const String history = '/history';
  static const String consultationRecording = '/consultation-recording';
  static const String soapNote = '/soap-note';
  static const String notifications = '/notifications';
  static const String addPatient = '/add-patient';
  // Private constructor to prevent instantiation
  AppRoutes._();
}

/// Route arguments classes for type-safe navigation
class ClinicSetupArguments {
  final String? userEmail;

  ClinicSetupArguments({this.userEmail});
}

class ConsultationRecordingArguments {
  final String? consultationId;
  final ConsultationStatus? initialStatus;
  final String? initialPatientName;

  ConsultationRecordingArguments({
    this.consultationId,
    this.initialStatus,
    this.initialPatientName,
  });
}

class SOAPNoteArguments {
  final String consultationId;

  SOAPNoteArguments({required this.consultationId});
}

/// Route generator
class AppRouter {
  /// Generate routes based on route name
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    final routeName = settings.name;

    // Handle null or empty route name
    if (routeName == null || routeName.isEmpty) {
      return MaterialPageRoute(
        builder: (_) => const SplashScreen(),
        settings: settings,
      );
    }

    switch (routeName) {
      case AppRoutes.splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );

      case AppRoutes.onboarding:
        return MaterialPageRoute(
          builder: (_) => const OnboardingScreen(),
          settings: settings,
        );

      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );

      case AppRoutes.signup:
        return MaterialPageRoute(
          builder: (_) => const SignUpScreen(),
          settings: settings,
        );

      case AppRoutes.dashboard:
        return MaterialPageRoute(
          builder: (_) => const MainNavigationScreen(),
          settings: settings,
        );

      case AppRoutes.clinicSetup:
        // Handle typed arguments for clinic setup
        final typedArgs = args is ClinicSetupArguments ? args : null;
        return MaterialPageRoute(
          builder: (_) => ClinicSetupScreen(
            userEmail: typedArgs?.userEmail ?? (args is String ? args : null),
          ),
          settings: settings,
        );
      case AppRoutes.history:
        return MaterialPageRoute(
          builder: (_) => const HistoryScreen(),
          settings: settings,
        );

      case AppRoutes.consultationRecording:
        final typedArgs = args is ConsultationRecordingArguments ? args : null;
        return MaterialPageRoute(
          builder: (_) => ConsultationWorkflowScreen(
            consultationId: typedArgs?.consultationId,
            initialStatus:
                typedArgs?.initialStatus ?? ConsultationStatus.initialConsult,
            initialPatientName: typedArgs?.initialPatientName ?? 'New Patient',
          ),
          settings: settings,
        );

      case AppRoutes.soapNote:
        final typedArgs = args is SOAPNoteArguments ? args : null;
        if (typedArgs == null || typedArgs.consultationId.isEmpty) {
          // Redirect to dashboard if no consultation ID provided
          return MaterialPageRoute(
            builder: (_) => const MainNavigationScreen(),
            settings: settings,
          );
        }
        return MaterialPageRoute(
          builder: (_) => CompletedConsultationScreen(
            consultationId: typedArgs.consultationId,
          ),
          settings: settings,
        );

      case AppRoutes.notifications:
        return MaterialPageRoute(
          builder: (_) => const NotificationHistoryScreen(),
          settings: settings,
        );

      // case AppRoutes.addPatient:
      //   return MaterialPageRoute(
      //     builder: (_) => const AddPatientScreen(),
      //     settings: settings,
      //   );

      default:
        // Unknown route - redirect to landing
        return MaterialPageRoute(
          builder: (_) => const OnboardingScreen(),
          settings: settings,
        );
    }
  }

  /// Push a named route
  static Future<T?> pushNamed<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    // Use the root navigator so that routes are resolved by the top-level
    // MaterialApp, avoiding issues with nested Navigators (e.g. tab views).
    return Navigator.of(
      context,
      rootNavigator: true,
    ).pushNamed<T>(routeName, arguments: arguments);
  }

  /// Push and remove all previous routes
  static Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    bool Function(Route<dynamic>)? predicate,
  }) {
    return Navigator.of(
      context,
      rootNavigator: true,
    ).pushNamedAndRemoveUntil<T>(
      routeName,
      predicate ?? (route) => false,
      arguments: arguments,
    );
  }

  /// Push and replace current route
  static Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    TO? result,
  }) {
    return Navigator.pushReplacementNamed<T, TO>(
      context,
      routeName,
      arguments: arguments,
      result: result,
    );
  }

  /// Pop current route
  static void pop<T extends Object?>(BuildContext context, [T? result]) {
    Navigator.pop<T>(context, result);
  }

  /// Pop until a specific route
  static void popUntil(BuildContext context, String routeName) {
    Navigator.popUntil(context, (route) {
      return route.settings.name == routeName;
    });
  }
}
