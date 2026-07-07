import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/service_locator.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'features/animals/animals_bloc.dart';
import 'features/animals/animals_repository.dart';
import 'features/animals/animals_screen.dart';
import 'features/tasks/tasks_bloc.dart';
import 'features/tasks/tasks_repository.dart';
import 'features/tasks/tasks_screen.dart';
import 'features/dairy/dairy_bloc.dart';
import 'features/dairy/dairy_repository.dart';
import 'features/dairy/dairy_screen.dart';
import 'features/poultry/poultry_bloc.dart';
import 'features/poultry/poultry_repository.dart';
import 'features/poultry/poultry_screen.dart';
import 'features/finance/finance_bloc.dart';
import 'features/finance/finance_repository.dart';
import 'features/finance/finance_screen.dart';
import 'features/alerts/alert_bloc.dart';
import 'features/alerts/alert_repository.dart';
import 'features/alerts/alert_screen.dart';
import 'features/inventory/inventory_bloc.dart';
import 'features/inventory/inventory_repository.dart';
import 'features/inventory/inventory_screen.dart';
import 'features/hatchery/hatchery_bloc.dart';
import 'features/hatchery/hatchery_repository.dart';
import 'features/hatchery/hatchery_screen.dart';
import 'package:ifms_mobile/features/pharmacy/pharmacy_bloc.dart';
import 'package:ifms_mobile/features/pharmacy/pharmacy_repository.dart';
import 'package:ifms_mobile/features/pharmacy/pharmacy_screen.dart';
import 'features/staff/staff_bloc.dart';
import 'features/staff/staff_repository.dart';
import 'features/staff/staff_screen.dart';
import 'features/breeding/breeding_bloc.dart';
import 'features/breeding/breeding_repository.dart';
import 'features/breeding/breeding_screen.dart';
import 'core/network/notification_service.dart';
import 'core/sync/sync_manager.dart';
import 'core/updater/app_updater.dart';
import 'core/database/local_db.dart';
import 'features/settings/settings_controller.dart';
import 'features/settings/settings_screen.dart';
import 'features/settings/auth_screen.dart';


final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class IFMSApp extends StatefulWidget {
  const IFMSApp({super.key});

  @override
  State<IFMSApp> createState() => _IFMSAppState();
}

class _IFMSAppState extends State<IFMSApp> {
  late final Future<bool> _isInitializedFuture;

  @override
  void initState() {
    super.initState();
    _isInitializedFuture = _checkIfDatabaseInitialized();

    // Notifications and sync
    sl<NotificationService>().initialize();
    sl<SyncManager>().triggerSync();
    // Check for OTA updates silently after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) AppUpdater.checkForUpdates(context);
    });
  }

  Future<bool> _checkIfDatabaseInitialized() async {
    try {
      final db = sl<LocalDatabase>();
      final animals = await (db.select(db.localAnimals)..limit(1)).get();
      return animals.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsController = sl<SettingsController>();

    return MultiBlocProvider(
      providers: [
        BlocProvider<AnimalsBloc>(
          create: (context) => AnimalsBloc(sl<AnimalsRepository>())..add(LoadAnimals()),
        ),
        BlocProvider<TasksBloc>(
          create: (context) => TasksBloc(sl<TasksRepository>())..add(LoadTasks()),
        ),
        BlocProvider<DairyBloc>(
          create: (context) => DairyBloc(sl<DairyRepository>(), sl<AnimalsRepository>())..add(LoadDairyData()),
        ),
        BlocProvider<PoultryBloc>(
          create: (context) => PoultryBloc(sl<PoultryRepository>())..add(LoadPoultryData()),
        ),
        BlocProvider<FinanceBloc>(
          create: (context) => FinanceBloc(sl<FinanceRepository>())..add(LoadFinanceData()),
        ),
        BlocProvider<AlertBloc>(
          create: (context) => AlertBloc(sl<AlertRepository>())..add(LoadAlerts()),
        ),
         BlocProvider<InventoryBloc>(
          create: (context) => InventoryBloc(sl<InventoryRepository>())..add(LoadInventoryItems()),
        ),
        BlocProvider<HatcheryBloc>(
          create: (context) => HatcheryBloc(sl<HatcheryRepository>())..add(LoadHatcheryBatches()),
        ),
        BlocProvider<PharmacyBloc>(
          create: (context) => PharmacyBloc(sl<PharmacyRepository>())..add(LoadPharmacy()),
        ),
        BlocProvider<StaffBloc>(
          create: (context) => StaffBloc(sl<StaffRepository>())..add(LoadStaffData()),
        ),
        BlocProvider<BreedingBloc>(
          create: (context) => BreedingBloc(sl<BreedingRepository>()),
        ),
      ],
      child: AnimatedBuilder(
        animation: settingsController,
        builder: (context, child) {
          return MaterialApp(
            navigatorKey: appNavigatorKey,
            title: 'IFMS Mobile',
            theme: AppTheme.lightTheme,
            darkTheme: ThemeData.dark().copyWith(
              useMaterial3: true,
              scaffoldBackgroundColor: const Color(0xFF11140E),
              colorScheme: const ColorScheme.dark(
                primary: AppColors.primary,
                onPrimary: Colors.white,
                surface: Color(0xFF11140E),
                onSurface: Color(0xFFE0E4DB),
              ),
            ),
            themeMode: settingsController.themeMode,
            builder: (context, child) {
              final scale = settingsController.fontScale;
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaleFactor: scale,
                ),
                child: GestureDetector(
                  onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                  child: child,
                ),
              );
            },
            home: FutureBuilder<bool>(
              future: _isInitializedFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                if (snapshot.data == true) {
                  return const MainNavigationWrapper();
                } else {
                  // Route to AuthScreen for first login/signup setup
                  return AuthScreen(controller: settingsController);
                }
              },
            ),
            routes: {
              '/home': (context) => const MainNavigationWrapper(),
              '/animals': (context) => const AnimalsScreen(),
              '/tasks': (context) => const TasksScreen(),
              '/dairy': (context) => const DairyScreen(),
              '/poultry': (context) => const PoultryScreen(),
              '/finance': (context) => const FinanceScreen(),
              '/alerts': (context) => const AlertScreen(),
              '/inventory': (context) => const InventoryScreen(),
              '/hatchery': (context) => const HatcheryScreen(),
              '/pharmacy': (context) => const PharmacyScreen(),
              '/staff': (context) => const StaffScreen(),
              '/breeding': (context) => const BreedingScreen(),
              '/settings': (context) => SettingsScreen(controller: settingsController),
              '/auth': (context) => AuthScreen(controller: settingsController),
            },
          );
        },
      ),
    );
  }
}

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    HomeScreen(),
    AnimalsScreen(),
    TasksScreen(),
    AlertScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.pets_outlined), activeIcon: Icon(Icons.pets), label: 'Herd'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), activeIcon: Icon(Icons.assignment), label: 'Tasks'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_outlined), activeIcon: Icon(Icons.notifications), label: 'Alerts'),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IFMS OPERATIONS'),
        actions: [
          // Update button — shows red badge dot when a new version is available
          ValueListenableBuilder<bool>(
            valueListenable: updateAvailableNotifier,
            builder: (context, hasUpdate, _) => Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  onPressed: () => AppUpdater.showUpdateDialog(context),
                  icon: const Icon(Icons.system_update_alt_outlined),
                  tooltip: 'Check for Updates',
                ),
                if (hasUpdate)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/settings');
            },
            icon: const Icon(Icons.account_circle_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSyncStatusBanner(),
            const SizedBox(height: 24),
            Text(
              'MANAGEMENT LAYERS',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                BlocBuilder<AnimalsBloc, AnimalsState>(
                  builder: (context, state) {
                    final count = state is AnimalsLoaded 
                        ? state.animals.where((a) {
                            final isMap = a is Map;
                            final status = ((isMap ? a['status'] : a.status) ?? 'active').toString().toLowerCase();
                            return status != 'dead';
                          }).length
                        : 0;
                    return _buildMenuCard(
                      context,
                      title: 'Farm Registry',
                      subtitle: '$count Animals Active',
                      icon: Icons.agriculture,
                      color: AppColors.primary,
                      route: '/animals',
                    );
                  },
                ),
                _buildMenuCard(
                  context,
                  title: 'Breeding & Genetics',
                  subtitle: 'Manage Lifecycles',
                  icon: Icons.favorite,
                  color: Colors.pink,
                  route: '/breeding',
                ),
                BlocBuilder<DairyBloc, DairyState>(
                  builder: (context, state) {
                    final yieldVal = state is DairyLoaded ? state.totalMilkToday : 0.0;
                    return _buildMenuCard(
                      context,
                      title: 'Dairy Intel',
                      subtitle: '${yieldVal.toStringAsFixed(1)}L Total',
                      icon: Icons.water_drop,
                      color: Colors.blue,
                      route: '/dairy',
                    );
                  },
                ),
                BlocBuilder<PoultryBloc, PoultryState>(
                  builder: (context, state) {
                    return _buildMenuCard(
                      context,
                      title: 'Poultry Batch',
                      subtitle: 'FCR 1.62 Normal',
                      icon: Icons.egg,
                      color: Colors.brown,
                      route: '/poultry',
                    );
                  },
                ),
                BlocBuilder<TasksBloc, TasksState>(
                  builder: (context, state) {
                    final count = state is TasksLoaded
                        ? state.tasks.where((t) {
                            final status = (t is Map ? t['status'] : t.status).toString().toLowerCase();
                            return status != 'completed' && status != 'cancelled';
                          }).length
                        : 0;
                    return _buildMenuCard(
                      context,
                      title: 'Work Orders',
                      subtitle: '$count Pending Tasks',
                      icon: Icons.assignment,
                      color: Colors.orange,
                      route: '/tasks',
                    );
                  },
                ),
                BlocBuilder<AlertBloc, AlertState>(
                  builder: (context, state) {
                    final count = state is AlertLoaded ? state.alerts.where((a) => !a.isResolved).length : 0;
                    return _buildMenuCard(
                      context,
                      title: 'Alert Hub',
                      subtitle: '$count Active Alerts',
                      icon: Icons.notifications_active,
                      color: AppColors.error,
                      route: '/alerts',
                    );
                  },
                ),
                BlocBuilder<FinanceBloc, FinanceState>(
                  builder: (context, state) {
                    double totalMargin = 0.0;
                    if (state is FinanceLoaded) {
                      for (var tx in state.transactions) {
                        totalMargin += tx.transactionType == 'income' ? tx.amount : -tx.amount;
                      }
                    }
                    final marginStr = totalMargin >= 0
                        ? '₦ ${totalMargin.toStringAsFixed(0)} Margin'
                        : '-₦ ${totalMargin.abs().toStringAsFixed(0)} Deficit';
                    return _buildMenuCard(
                      context,
                      title: 'Financials',
                      subtitle: state is FinanceLoaded ? marginStr : 'Margin Insights',
                      icon: Icons.account_balance_wallet,
                      color: Colors.teal,
                      route: '/finance',
                    );
                  },
                ),
                BlocBuilder<InventoryBloc, InventoryState>(
                  builder: (context, state) {
                    int lowCount = 0;
                    if (state is InventoryLoaded) {
                      lowCount = state.items.where((i) {
                        final stock = double.tryParse(i['current_stock'].toString()) ?? 0.0;
                        final threshold = double.tryParse(i['reorder_threshold'].toString()) ?? 0.0;
                        return stock <= threshold;
                      }).length;
                    }
                    final subtitle = state is InventoryLoaded
                        ? '$lowCount Items Low'
                        : 'Stock Levels';
                    return _buildMenuCard(
                      context,
                      title: 'Farm Inventory',
                      subtitle: subtitle,
                      icon: Icons.storage,
                      color: Colors.blueGrey,
                      route: '/inventory',
                    );
                  },
                ),
                BlocBuilder<HatcheryBloc, HatcheryState>(
                  builder: (context, state) {
                    int incubating = 0;
                    if (state is HatcheryLoaded) {
                      incubating = state.batches.where((b) => b['status'] == 'incubating').length;
                    }
                    final subtitle = state is HatcheryLoaded
                        ? '$incubating Incubating'
                        : 'Cohorts';
                    return _buildMenuCard(
                      context,
                      title: 'Hatchery Hub',
                      subtitle: subtitle,
                      icon: Icons.bubble_chart,
                      color: Colors.deepPurple,
                      route: '/hatchery',
                    );
                  },
                ),
                BlocBuilder<PharmacyBloc, PharmacyState>(
                  builder: (context, state) {
                    int lowCount = 0;
                    if (state is PharmacyLoaded) {
                      lowCount = state.medications.where((m) => m.currentStock <= m.reorderThreshold).length;
                    }
                    final subtitle = state is PharmacyLoaded
                        ? '$lowCount Low Stock'
                        : 'Vet Pharmacy';
                    return _buildMenuCard(
                      context,
                      title: 'Pharmacy',
                      subtitle: subtitle,
                      icon: Icons.local_pharmacy,
                      color: Colors.pink,
                      route: '/pharmacy',
                    );
                  },
                ),
                BlocBuilder<StaffBloc, StaffState>(
                  builder: (context, state) {
                    int staffCount = 0;
                    if (state is StaffLoaded) {
                      staffCount = state.staff.length;
                    }
                    final subtitle = state is StaffLoaded
                        ? '$staffCount Workers'
                        : 'HR & Payroll';
                    return _buildMenuCard(
                      context,
                      title: 'Staffing',
                      subtitle: subtitle,
                      icon: Icons.groups,
                      color: Colors.indigo,
                      route: '/staff',
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildFinancialOverview(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncStatusBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondaryContainer),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.secondary, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'System Synchronized',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  'Ready to work offline. Actions will queue.',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            'OK',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialOverview(BuildContext context) {
    return BlocBuilder<FinanceBloc, FinanceState>(
      builder: (context, state) {
        double totalRevenue = 0.0;
        if (state is FinanceLoaded) {
          for (var tx in state.transactions) {
            if (tx.transactionType == 'income') {
              totalRevenue += tx.amount;
            }
          }
        }
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ESTIMATED REVENUE', style: Theme.of(context).textTheme.labelLarge),
                    const Icon(Icons.trending_up, color: AppColors.secondary, size: 16),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '₦ ${totalRevenue.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                const SizedBox(height: 4),
                Text('Across all active enterprise layers', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant.withValues(alpha: 0.7)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
