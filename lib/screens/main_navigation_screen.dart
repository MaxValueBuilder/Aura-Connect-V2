import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/di/injection.dart';
import '../../features/navigation/navigation_cubit.dart';
import '../../features/navigation/navigation_state.dart';
import '../../features/notification/notification_cubit.dart';
import '../../features/notification/notification_state.dart';
import 'dashboard/dashboard_screen.dart';
import 'history/history_screen.dart';
import 'patients/patients_screen.dart';
import 'notifications/notification_history_screen.dart';
import 'settings/settings_screen.dart';

/// Dark nav bar colors to match design (dark bar, white icons, active tab highlight)
final _navBarBackgroundColor = AppColors.secondary;
final _navBarActiveItemBackground = Color(0xFF2A3757);

/// Main navigation wrapper that manages bottom navigation bar
/// and switches between different screens
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late final PersistentTabController _tabController;
  late final NavigationCubit _navigationCubit;

  List<CustomNavBarScreen> _buildScreens() {
    return [
      CustomNavBarScreen(screen: const DashboardScreen()),
      CustomNavBarScreen(screen: const HistoryScreen()),
      CustomNavBarScreen(screen: const PatientsScreen()),
      CustomNavBarScreen(screen: const NotificationHistoryScreen()),
      CustomNavBarScreen(screen: const SettingsScreen()),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.home_filled),
        // activeIcon: const Icon(Icons.dashboard),
        title: 'Dashboard',
        activeColorPrimary: AppColors.white,
        inactiveColorPrimary: AppColors.white,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.history),
        // activeIcon: const Icon(Icons.history),
        title: 'History',
        activeColorPrimary: AppColors.white,
        inactiveColorPrimary: AppColors.white,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.person),
        // activeIcon: const Icon(Icons.people),
        title: 'Patients',
        activeColorPrimary: AppColors.white,
        inactiveColorPrimary: AppColors.white,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.notifications),
        // activeIcon: const Icon(Icons.notifications),
        title: 'Notifications',
        activeColorPrimary: AppColors.white,
        inactiveColorPrimary: AppColors.white,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.settings_outlined),
        // activeIcon: const Icon(Icons.settings),
        title: 'Settings',
        activeColorPrimary: AppColors.white,
        inactiveColorPrimary: AppColors.white,
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _navigationCubit = getIt<NavigationCubit>();
    _tabController = PersistentTabController(
      initialIndex: _navigationCubit.state.selectedIndex,
    );
    _tabController.addListener(_onTabIndexChanged);
    // Load unread count so badge shows immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getIt<NotificationCubit>().refreshUnreadNotifications();
    });
  }

  void _onTabIndexChanged() {
    final index = _tabController.index;
    if (index != _navigationCubit.state.selectedIndex) {
      _navigationCubit.changeTab(index);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabIndexChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use the device's bottom inset (gesture/home indicator area) instead of a
    // fixed extra height, so the nav bar stays consistent across devices.
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;
    return BlocProvider<NavigationCubit>.value(
      value: _navigationCubit,
      child: BlocListener<NavigationCubit, NavigationState>(
        listener: (context, state) {
          if (_tabController.index != state.selectedIndex) {
            _tabController.jumpToTab(state.selectedIndex);
            setState(() {});
          }
        },
        child: PersistentTabView.custom(
          context,
          controller: _tabController,
          itemCount: _navBarItems().length,
          screens: _buildScreens(),
          customWidget: BlocBuilder<NotificationCubit, NotificationState>(
            builder: (context, notificationState) {
              return _DarkStyleNavBar(
                items: _navBarItems(),
                selectedIndex: _tabController.index,
                notificationUnreadCount: notificationState.unreadCount,
                onItemSelected: (index) {
                  setState(() {
                    _tabController.index = index;
                  });
                  _navigationCubit.changeTab(index);
                  if (index == _notificationsTabIndex) {
                    getIt<NotificationCubit>().loadNotifications(refresh: true);
                  }
                },
              );
            },
          ),
          // We'll handle safe area ourselves (see `_DarkStyleNavBar`).
          confineToSafeArea: false,
          backgroundColor: _navBarBackgroundColor,
          handleAndroidBackButtonPress: true,
          stateManagement: true,
          hideNavigationBarWhenKeyboardAppears: true,
          resizeToAvoidBottomInset: true,
          isVisible: true,
          navBarHeight: kBottomNavigationBarHeight + bottomInset,
          margin: EdgeInsets.zero,
          animationSettings: const NavBarAnimationSettings(
            navBarItemAnimation: ItemAnimationSettings(
              duration: Duration(milliseconds: 400),
              curve: Curves.ease,
            ),
            screenTransitionAnimation: ScreenTransitionAnimationSettings(
              animateTabTransition: true,
              duration: Duration(milliseconds: 200),
              screenTransitionAnimationType:
                  ScreenTransitionAnimationType.fadeIn,
            ),
          ),
        ),
      ),
    );
  }
}

/// Index of the Notifications tab in the bottom nav bar.
const _notificationsTabIndex = 3;

class _DarkStyleNavBar extends StatelessWidget {
  const _DarkStyleNavBar({
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
    this.notificationUnreadCount = 0,
  });

  final List<PersistentBottomNavBarItem> items;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final int notificationUnreadCount;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;
    return Container(
      color: _navBarBackgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: kBottomNavigationBarHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(items.length, (index) {
                final item = items[index];
                final isSelected = selectedIndex == index;
                final showBadge =
                    index == _notificationsTabIndex &&
                    notificationUnreadCount > 0;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onItemSelected(index),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _navBarActiveItemBackground
                            : Colors.transparent,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              IconTheme(
                                data: IconThemeData(
                                  size: 24,
                                  color: isSelected
                                      ? (item.activeColorSecondary ??
                                            item.activeColorPrimary)
                                      : item.inactiveColorPrimary,
                                ),
                                child: item.icon,
                              ),
                              if (showBadge)
                                Positioned(
                                  right: -8,
                                  top: -6,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 0,
                                      vertical: 0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.error,
                                      shape: notificationUnreadCount <= 9
                                          ? BoxShape.circle
                                          : BoxShape.rectangle,
                                      borderRadius: notificationUnreadCount > 9
                                          ? BorderRadius.circular(12)
                                          : null,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 20,
                                      minHeight: 20,
                                    ),
                                    child: Center(
                                      child: Text(
                                        // '45',
                                        notificationUnreadCount > 99
                                            ? '99+'
                                            : '$notificationUnreadCount',
                                        style: const TextStyle(
                                          color: AppColors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Material(
                            type: MaterialType.transparency,
                            child: FittedBox(
                              child: Text(
                                item.title ?? '',
                                style: TextStyle(
                                  color: isSelected
                                      ? item.activeColorPrimary
                                      : item.inactiveColorPrimary,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          // Exact bottom inset area (gesture/home indicator). Prevents any
          // "mystery" extra space from stacking multiple safe-area widgets.
          SizedBox(height: bottomInset),
        ],
      ),
    );
  }
}
