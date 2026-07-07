import 'package:get_it/get_it.dart';
import '../database/local_db.dart';
import '../network/api_client.dart';
import '../network/notification_service.dart';
import '../sync/sync_manager.dart';
import '../../features/animals/animals_repository.dart';
import '../../features/tasks/tasks_repository.dart';
import '../../features/dairy/dairy_repository.dart';
import '../../features/poultry/poultry_repository.dart';
import '../../features/finance/finance_repository.dart';
import '../../features/alerts/alert_repository.dart';
import '../../features/inventory/inventory_repository.dart';
import '../../features/hatchery/hatchery_repository.dart';
import '../../features/pharmacy/pharmacy_repository.dart';
import '../../features/staff/staff_repository.dart';
import '../../features/breeding/breeding_repository.dart';
import '../../features/settings/settings_controller.dart';

final sl = GetIt.instance;

Future<void> setupLocator() async {
  // Core
  final database = LocalDatabase();
  sl.registerSingleton<LocalDatabase>(database);
  
  final settingsController = SettingsController();
  await settingsController.loadSettings();
  sl.registerSingleton<SettingsController>(settingsController);
  
  final apiClient = ApiClient();
  sl.registerSingleton<ApiClient>(apiClient);
  
  sl.registerSingleton<SyncManager>(SyncManager(sl(), sl()));

  sl.registerSingleton<NotificationService>(NotificationService());

  // Repositories
  sl.registerLazySingleton<AnimalsRepository>(() => AnimalsRepository(sl(), sl()));
  sl.registerLazySingleton<TasksRepository>(() => TasksRepository(sl(), sl()));
  sl.registerLazySingleton<DairyRepository>(() => DairyRepository(sl(), sl()));
  sl.registerLazySingleton<PoultryRepository>(() => PoultryRepository(sl(), sl()));
  sl.registerLazySingleton<FinanceRepository>(() => FinanceRepository(sl(), sl()));
  sl.registerLazySingleton<AlertRepository>(() => AlertRepository(sl(), sl()));
  sl.registerLazySingleton<InventoryRepository>(() => InventoryRepository(sl(), sl()));
  sl.registerLazySingleton<HatcheryRepository>(() => HatcheryRepository(sl(), sl()));
  sl.registerLazySingleton<PharmacyRepository>(() => PharmacyRepository(sl()));
  sl.registerLazySingleton<StaffRepository>(() => StaffRepository(sl(), sl()));
  sl.registerLazySingleton<BreedingRepository>(() => BreedingRepository(sl(), sl()));
}
