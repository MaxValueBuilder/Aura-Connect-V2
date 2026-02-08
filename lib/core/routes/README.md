# App Router Usage Guide

This document explains how to use the centralized router system for navigation in the Aura Connect app.

## Import

```dart
import 'package:aura/core/routes/app_routes.dart';
```

## Available Routes

- `AppRoutes.splash` - `/` - Splash screen
- `AppRoutes.landing` - `/landing` - Landing page
- `AppRoutes.dashboard` - `/dashboard` - Dashboard screen
- `AppRoutes.clinicSetup` - `/clinic-setup` - Clinic setup form

## Navigation Methods

### 1. Push a new route (keeps previous routes)

```dart
AppRouter.pushNamed(
  context,
  AppRoutes.dashboard,
);
```

### 2. Push with arguments

```dart
// For clinic setup with user email
AppRouter.pushNamed(
  context,
  AppRoutes.clinicSetup,
  arguments: ClinicSetupArguments(userEmail: 'user@example.com'),
);

// Or simple string argument
AppRouter.pushNamed(
  context,
  AppRoutes.clinicSetup,
  arguments: 'user@example.com',
);
```

### 3. Push and replace current route

```dart
AppRouter.pushReplacementNamed(
  context,
  AppRoutes.dashboard,
);
```

### 4. Push and remove all previous routes

```dart
// Clear entire navigation stack
AppRouter.pushNamedAndRemoveUntil(
  context,
  AppRoutes.dashboard,
);

// Or with custom predicate
AppRouter.pushNamedAndRemoveUntil(
  context,
  AppRoutes.dashboard,
  predicate: (route) => route.isFirst, // Keep only first route
);
```

### 5. Pop current route

```dart
AppRouter.pop(context);

// With return value
AppRouter.pop(context, 'some result');
```

### 6. Pop until specific route

```dart
AppRouter.popUntil(context, AppRoutes.landing);
```

## Examples

### Example 1: Navigate after login

```dart
onPressed: () {
  // After successful login
  AppRouter.pushNamedAndRemoveUntil(
    context,
    AppRoutes.dashboard,
  );
}
```

### Example 2: Navigate to clinic setup after signup

```dart
onPressed: () {
  final userEmail = authState.userEmail;
  AppRouter.pushNamed(
    context,
    AppRoutes.clinicSetup,
    arguments: ClinicSetupArguments(userEmail: userEmail),
  );
}
```

### Example 3: Go back

```dart
onPressed: () {
  AppRouter.pop(context);
}
```

## Adding New Routes

1. Add route name constant in `AppRoutes` class:
   ```dart
   static const String newScreen = '/new-screen';
   ```

2. Add case in `AppRouter.generateRoute`:
   ```dart
   case AppRoutes.newScreen:
     return MaterialPageRoute(
       builder: (_) => const NewScreen(),
       settings: settings,
     );
   ```

3. Import the screen at the top of `app_routes.dart`:
   ```dart
   import 'package:aura/screens/new_screen.dart';
   ```

## Benefits

- ✅ Centralized route management
- ✅ Type-safe route names
- ✅ Consistent navigation patterns
- ✅ Easy to add new routes
- ✅ Better maintainability

