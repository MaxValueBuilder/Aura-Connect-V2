import 'package:flutter_bloc/flutter_bloc.dart';
import 'navigation_state.dart';

/// Navigation Cubit for managing bottom navigation bar state
class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit() : super(const NavigationState());

  /// Change the selected tab index
  void changeTab(int index) {
    if (index >= 0 && index < 4) {
      // 4 tabs: Dashboard, History, Patients, Settings
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

  /// Navigate to Settings (index 3)
  void navigateToSettings() {
    changeTab(3);
  }
}

