import 'package:flutter_bloc/flutter_bloc.dart';
import 'navigation_state.dart';

/// Navigation Cubit for managing bottom navigation bar state
class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit() : super(const NavigationState());

  /// Change the selected tab index
  void changeTab(int index) {
    if (index >= 0 && index < 5) {
      // 5 tabs: Dashboard, History, Patients, Notifications, Settings
      emit(state.copyWith(selectedIndex: index));
    }
  }

  /// Navigate to Dashboard (index 0)
  void navigateToDashboard() {
    changeTab(0);
  }

  /// Navigate to History (index 1)
  void navigateToHistory() {
    changeTab(1);
  }

  /// Navigate to Patients (index 2)
  void navigateToPatients() {
    changeTab(2);
  }

  /// Navigate to Notifications (index 3)
  void navigateToNotifications() {
    changeTab(3);
  }

  /// Navigate to Settings (index 4)
  void navigateToSettings() {
    changeTab(4);
  }
}

