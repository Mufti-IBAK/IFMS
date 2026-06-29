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
import 'core/network/notification_service.dart';

class IFMSApp extends StatefulWidget {
  const IFMSApp({super.key});

  @override
  State<IFMSApp> createState() => _IFMSAppState();
}

class _IFMSAppState extends State<IFMSApp> {
  @override
  void initState() {
    super.initState();
    // Initialize Notifications
    sl<NotificationService>().initialize();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AnimalsBloc>(
          create: (context) => AnimalsBloc(sl<AnimalsRepository>())..add(LoadAnimals()),
        ),
        BlocProvider<TasksBloc>(
          create: (context) => TasksBloc(sl<TasksRepository>())..add(LoadTasks()),
        ),
        BlocProvider<DairyBloc>(
          create: (context) => DairyBloc(sl<DairyRepository>())..add(LoadDairyData()),
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
      ],
      child: MaterialApp(
        title: 'IFMS Mobile',
        theme: AppTheme.lightTheme,
        home: const MainNavigationWrapper(),
        routes: {
          '/animals': (context) => const AnimalsScreen(),
          '/tasks': (context) => const TasksScreen(),
          '/dairy': (context) => const DairyScreen(),
          '/poultry': (context) => const PoultryScreen(),
          '/finance': (context) => const FinanceScreen(),
          '/alerts': (context) => const AlertScreen(),
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
          IconButton(
            onPressed: () {},
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
                _buildMenuCard(
                  context,
                  title: 'Herd Registry',
                  subtitle: '142 Cattle Active',
                  icon: Icons.pets,
                  color: AppColors.primary,
                  route: '/animals',
                ),
                _buildMenuCard(
                  context,
                  title: 'Dairy Intel',
                  subtitle: '1,420L Today',
                  icon: Icons.water_drop,
                  color: Colors.blue,
                  route: '/dairy',
                ),
                _buildMenuCard(
                  context,
                  title: 'Poultry Batch',
                  subtitle: 'FCR 1.62 Normal',
                  icon: Icons.egg,
                  color: Colors.brown,
                  route: '/poultry',
                ),
                _buildMenuCard(
                  context,
                  title: 'Work Orders',
                  subtitle: '5 Pending Tasks',
                  icon: Icons.assignment,
                  color: Colors.orange,
                  route: '/tasks',
                ),
                _buildMenuCard(
                  context,
                  title: 'Alert Hub',
                  subtitle: '3 Critical Alerts',
                  icon: Icons.notifications_active,
                  color: AppColors.error,
                  route: '/alerts',
                ),
                _buildMenuCard(
                  context,
                  title: 'Financials',
                  subtitle: '₦ 2.4M Margin',
                  icon: Icons.account_balance_wallet,
                  color: Colors.teal,
                  route: '/finance',
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
            const Text(
              '₦ 2,450,000.00',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            const SizedBox(height: 4),
            Text('Across all active enterprise layers', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
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
