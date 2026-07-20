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
import 'features/history/history_tracking_screen.dart';
import 'core/network/notification_service.dart';
import 'core/sync/sync_manager.dart';
import 'core/updater/app_updater.dart';
import 'core/database/local_db.dart';
import 'features/settings/settings_controller.dart';
import 'features/settings/settings_screen.dart';
import 'features/settings/auth_screen.dart';
import 'dart:io';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';


final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class IFMSApp extends StatefulWidget {
  const IFMSApp({super.key});

  @override
  State<IFMSApp> createState() => _IFMSAppState();
}

class _IFMSAppState extends State<IFMSApp> {
  late final Future<bool> _isInitializedFuture;
  Timer? _updateTimer;
  Timer? _syncTimer;

  @override
  void initState() {
    super.initState();
    _isInitializedFuture = _checkIfDatabaseInitialized();

    // Notifications and sync
    sl<NotificationService>().initialize();
    sl<SyncManager>().syncAll(); // Push and Pull immediately

    // Check for OTA updates silently after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        AppUpdater.checkForUpdates(context);
        _startUpdatePolling();
        _startDataSyncPolling();
      }
    });
  }

  void _startDataSyncPolling() {
    // Aggressively sync data every 30 seconds
    _syncTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        sl<SyncManager>().syncAll();
      }
    });
  }

  void _startUpdatePolling() {
    // Poll for updates every 30 minutes
    _updateTimer = Timer.periodic(const Duration(minutes: 30), (timer) {
      if (mounted) {
        AppUpdater.checkForUpdates(context);
      }
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    _syncTimer?.cancel();
    super.dispose();
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
            scaffoldMessengerKey: scaffoldMessengerKey,
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
              '/history': (context) => const HistoryTrackingScreen(),
              '/settings': (context) => SettingsScreen(controller: settingsController),
              '/auth': (context) => AuthScreen(controller: settingsController),
            },
          );
        },
      ),
    );
  }
}

class MainNavigationWrapper extends StatelessWidget {
  const MainNavigationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _getTimeBasedGreeting(String? userName) {
    final hour = DateTime.now().hour;
    final name = userName?.trim().isNotEmpty == true ? userName!.trim() : 'Manager';
    
    if (hour >= 5 && hour < 12) {
      return 'Good morning, $name';
    } else if (hour >= 12 && hour < 17) {
      return 'Good afternoon, $name';
    } else if (hour >= 17 && hour < 22) {
      return 'Good evening, $name';
    } else {
      return 'Good night, $name';
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsController = sl<SettingsController>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shield, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              'RoyalHeritage Farms',
              style: GoogleFonts.rajdhani(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: const [],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            AnimatedBuilder(
              animation: settingsController,
              builder: (context, _) {
                final profile = settingsController.profile;
                return UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, Color(0xFF061835)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white24,
                    backgroundImage: profile?.profilePicPath != null &&
                            profile!.profilePicPath!.isNotEmpty &&
                            File(profile.profilePicPath!).existsSync()
                        ? FileImage(File(profile.profilePicPath!))
                        : null,
                    child: profile?.profilePicPath == null ||
                            profile!.profilePicPath!.isEmpty ||
                            !File(profile.profilePicPath!).existsSync()
                        ? const Icon(Icons.person, size: 36, color: Colors.white)
                        : null,
                  ),
                  accountName: Text(
                    profile?.name ?? 'Royal Manager',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  accountEmail: Text(
                    profile?.role.toUpperCase() ?? 'OPERATIONS DIRECTOR',
                    style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w600, fontSize: 11, letterSpacing: 0.5),
                  ),
                  onDetailsPressed: () {
                    Navigator.pop(context);
                    Navigator.of(context).pushNamed('/settings');
                  },
                );
              },
            ),
            
            _buildDrawerItem(context, 'Livestock Portfolio', Icons.agriculture, '/animals'),
            _buildDrawerItem(context, 'Genetics & Lineage', Icons.favorite, '/breeding'),
            _buildDrawerItem(context, 'Milk Production Registry', Icons.water_drop, '/dairy'),
            _buildDrawerItem(context, 'Poultry Batches Control', Icons.egg, '/poultry'),
            _buildDrawerItem(context, 'Task & Operation Logs', Icons.assignment, '/tasks'),
            _buildDrawerItem(context, 'Alerts & Insights Control', Icons.notifications_active, '/alerts'),
            _buildDrawerItem(context, 'Financial Ledger', Icons.account_balance_wallet, '/finance'),
            _buildDrawerItem(context, 'Feed Stock Vault', Icons.storage, '/inventory'),
            _buildDrawerItem(context, 'Avian Incubation Hub', Icons.bubble_chart, '/hatchery'),
            _buildDrawerItem(context, 'Veterinary Apothecary', Icons.local_pharmacy, '/pharmacy'),
            _buildDrawerItem(context, 'Labor & Operations Management', Icons.groups, '/staff'),
            _buildDrawerItem(context, 'History & Audit Trail', Icons.history, '/history'),
            
            const Divider(),
            
            ListTile(
              leading: const Icon(Icons.sync, color: AppColors.primary),
              title: const Text('Synchronize Database', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              trailing: const Icon(Icons.chevron_right, size: 16),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Syncing Data...'), duration: Duration(seconds: 2)),
                );
                sl<SyncManager>().syncAll();
              },
            ),
            
            ValueListenableBuilder<bool>(
              valueListenable: updateAvailableNotifier,
              builder: (context, hasUpdate, _) => ListTile(
                leading: Icon(Icons.system_update_alt_outlined, color: hasUpdate ? Colors.green : AppColors.primary),
                title: const Text('Check for Updates', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                trailing: hasUpdate 
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(10)),
                        child: const Text('NEW', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      )
                    : const Icon(Icons.chevron_right, size: 16),
                onTap: () {
                  Navigator.pop(context);
                  AppUpdater.showUpdateDialog(context);
                },
              ),
            ),
            
            _buildDrawerItem(context, 'System Settings', Icons.settings, '/settings'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            AnimatedBuilder(
              animation: settingsController,
              builder: (context, _) {
                final profile = settingsController.profile;
                final greeting = _getTimeBasedGreeting(profile?.name);
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, Color(0xFF0A2B5C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.secondary.withOpacity(0.4), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ROYAL HERITAGE FARMS',
                        style: TextStyle(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        greeting,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Here is your live operational overview for today.',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                );
              },
            ),
            
            const SizedBox(height: 24),
            Text(
              'LIVE MONITORING STATS',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.45,
              children: [
                _insightKpiCard(
                  context,
                  title: 'Active Livestock',
                  icon: Icons.pets,
                  color: AppColors.primary,
                  route: '/animals',
                  valueWidget: BlocBuilder<AnimalsBloc, AnimalsState>(
                    builder: (context, state) {
                      final count = state is AnimalsLoaded
                          ? state.animals.cast<LocalAnimal>().where((a) => a.status.toLowerCase() != 'dead').length
                          : 0;
                      return Text('$count head', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
                    },
                  ),
                ),
                _insightKpiCard(
                  context,
                  title: 'Today\'s Milk Yield',
                  icon: Icons.water_drop,
                  color: Colors.teal,
                  route: '/dairy',
                  valueWidget: BlocBuilder<DairyBloc, DairyState>(
                    builder: (context, state) {
                      final yieldVal = state is DairyLoaded ? state.totalMilkDashboard : 0.0;
                      return Text('${yieldVal.toStringAsFixed(1)} Litres', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
                    },
                  ),
                ),
                _insightKpiCard(
                  context,
                  title: 'Pending Operations',
                  icon: Icons.assignment_turned_in,
                  color: Colors.orange,
                  route: '/tasks',
                  valueWidget: BlocBuilder<TasksBloc, TasksState>(
                    builder: (context, state) {
                      final count = state is TasksLoaded
                          ? state.tasks.where((t) {
                              final status = (t is Map ? t['status'] : t.status).toString().toLowerCase();
                              return status != 'completed' && status != 'cancelled';
                            }).length
                          : 0;
                      return Text('$count Tasks', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
                    },
                  ),
                ),
                _insightKpiCard(
                  context,
                  title: 'System Alerts',
                  icon: Icons.notifications_active,
                  color: AppColors.error,
                  route: '/alerts',
                  valueWidget: BlocBuilder<AlertBloc, AlertState>(
                    builder: (context, state) {
                      final count = state is AlertLoaded ? state.alerts.where((a) => !a.isResolved).length : 0;
                      return Text('$count Active', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.error));
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            Text(
              'FINANCIAL HEALTH',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 12),
            BlocBuilder<FinanceBloc, FinanceState>(
              builder: (context, state) {
                double revenue = 0.0;
                double expenses = 0.0;
                if (state is FinanceLoaded) {
                  for (var tx in state.transactions) {
                    if (tx.transactionType == 'income') {
                      revenue += tx.amount;
                    } else {
                      expenses += tx.amount;
                    }
                  }
                }
                final netMargin = revenue - expenses;

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.secondary.withOpacity(0.3), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: () => Navigator.pushNamed(context, '/finance'),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('ESTIMATED REVENUE LEDGER', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.secondary)),
                              Icon(
                                netMargin >= 0 ? Icons.trending_up : Icons.trending_down,
                                color: netMargin >= 0 ? Colors.green : AppColors.error,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Estimated Revenue', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                  const SizedBox(height: 2),
                                  Text('₦ ${revenue.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Recorded Expenses', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                  const SizedBox(height: 2),
                                  Text('₦ ${expenses.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.error)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Net Margin', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                  const SizedBox(height: 2),
                                  Text(
                                    '₦ ${netMargin.toStringAsFixed(2)}', 
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold, 
                                      fontSize: 16, 
                                      color: netMargin >= 0 ? AppColors.primary : AppColors.error
                                    )
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 24),
            Text(
              'INVENTORY & STOCKS',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.secondary.withOpacity(0.15), width: 1.2),
              ),
              child: Column(
                children: [
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
                      return ListTile(
                        leading: const Icon(Icons.storage, color: Colors.blueGrey),
                        title: const Text('Feed Ingredients Vault', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        subtitle: Text('$lowCount items need restock'),
                        trailing: const Icon(Icons.chevron_right, size: 18),
                        onTap: () => Navigator.pushNamed(context, '/inventory'),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  BlocBuilder<PharmacyBloc, PharmacyState>(
                    builder: (context, state) {
                      int lowCount = 0;
                      if (state is PharmacyLoaded) {
                        lowCount = state.medications.where((m) => m.currentStock <= m.reorderThreshold).length;
                      }
                      return ListTile(
                        leading: const Icon(Icons.local_pharmacy, color: Colors.pink),
                        title: const Text('Veterinary Apothecary', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        subtitle: Text('$lowCount drugs low on stock'),
                        trailing: const Icon(Icons.chevron_right, size: 18),
                        onTap: () => Navigator.pushNamed(context, '/pharmacy'),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  BlocBuilder<HatcheryBloc, HatcheryState>(
                    builder: (context, state) {
                      int incubating = 0;
                      if (state is HatcheryLoaded) {
                        incubating = state.batches.where((b) => b['status'] == 'incubating').length;
                      }
                      return ListTile(
                        leading: const Icon(Icons.bubble_chart, color: Colors.deepPurple),
                        title: const Text('Avian Incubation Hub', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        subtitle: Text('$incubating cohorts incubating'),
                        trailing: const Icon(Icons.chevron_right, size: 18),
                        onTap: () => Navigator.pushNamed(context, '/hatchery'),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            Text(
              'LABOR & WORKFORCE',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 12),
            BlocBuilder<StaffBloc, StaffState>(
              builder: (context, state) {
                int staffCount = 0;
                int activeQueries = 0;
                if (state is StaffLoaded) {
                  staffCount = state.staff.length;
                  activeQueries = state.queries.where((q) => !q.isResolved).length;
                }
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.secondary.withOpacity(0.15), width: 1.2),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.groups, color: Colors.indigo),
                    title: const Text('Labor & Operations Control', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    subtitle: Text('$staffCount active workers • $activeQueries unresolved queries'),
                    trailing: const Icon(Icons.chevron_right, size: 18),
                    onTap: () => Navigator.pushNamed(context, '/staff'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, String title, IconData icon, String route) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, route);
      },
    );
  }

  Widget _insightKpiCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required String route,
    required Widget valueWidget,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary.withOpacity(0.15), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 18),
                  ),
                  const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  valueWidget,
                  const SizedBox(height: 2),
                  Text(
                    title,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant.withOpacity(0.8)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
