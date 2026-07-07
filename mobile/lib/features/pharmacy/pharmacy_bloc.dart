import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/database/local_db.dart';
import 'pharmacy_repository.dart';

// ──────────────────────────────────────────────
// EVENTS
// ──────────────────────────────────────────────

abstract class PharmacyEvent {}

class LoadPharmacy extends PharmacyEvent {}

class AddMedication extends PharmacyEvent {
  final Map<String, dynamic> data;
  AddMedication(this.data);
}

class UpdateMedicationStock extends PharmacyEvent {
  final Map<String, dynamic> data;
  UpdateMedicationStock(this.data);
}

class LogTreatment extends PharmacyEvent {
  final Map<String, dynamic> data;
  LogTreatment(this.data);
}

class DiscardStock extends PharmacyEvent {
  final Map<String, dynamic> data;
  DiscardStock(this.data);
}

// ──────────────────────────────────────────────
// STATES
// ──────────────────────────────────────────────

abstract class PharmacyState {}

class PharmacyInitial extends PharmacyState {}

class PharmacyLoading extends PharmacyState {}

class PharmacyLoaded extends PharmacyState {
  final List<LocalMedication> medications;
  final List<LocalMedicationLog> logs;
  final List<LocalAnimalMedicalRecord> medicalRecords;

  PharmacyLoaded(this.medications, this.logs, this.medicalRecords);
}

class PharmacyError extends PharmacyState {
  final String message;
  PharmacyError(this.message);
}

// ──────────────────────────────────────────────
// BLOC
// ──────────────────────────────────────────────

class PharmacyBloc extends Bloc<PharmacyEvent, PharmacyState> {
  final PharmacyRepository repository;

  PharmacyBloc(this.repository) : super(PharmacyInitial()) {
    on<LoadPharmacy>(_onLoad);
    on<AddMedication>(_onAddMedication);
    on<UpdateMedicationStock>(_onUpdateStock);
    on<LogTreatment>(_onLogTreatment);
    on<DiscardStock>(_onDiscardStock);
  }

  Future<void> _onLoad(LoadPharmacy event, Emitter<PharmacyState> emit) async {
    emit(PharmacyLoading());
    try {
      final meds = await repository.getMedications();
      final logs = await repository.getMedicationLogs();
      final records = await repository.getMedicalRecords();
      emit(PharmacyLoaded(meds, logs, records));
    } catch (e) {
      emit(PharmacyError('Failed to load pharmacy: ${e.toString()}'));
    }
  }

  Future<void> _onAddMedication(AddMedication event, Emitter<PharmacyState> emit) async {
    try {
      await repository.addMedication(event.data);
      add(LoadPharmacy());
    } catch (e) {
      emit(PharmacyError('Failed to add medication: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateStock(UpdateMedicationStock event, Emitter<PharmacyState> emit) async {
    try {
      await repository.logMedicationChange(event.data);
      add(LoadPharmacy());
    } catch (e) {
      emit(PharmacyError('Failed to update stock: ${e.toString()}'));
    }
  }

  Future<void> _onLogTreatment(LogTreatment event, Emitter<PharmacyState> emit) async {
    try {
      await repository.logAnimalTreatment(event.data);
      add(LoadPharmacy());
    } catch (e) {
      emit(PharmacyError('Failed to log treatment: ${e.toString()}'));
    }
  }

  Future<void> _onDiscardStock(DiscardStock event, Emitter<PharmacyState> emit) async {
    try {
      await repository.logMedicationChange({
        ...event.data,
        'change_type': 'discard',
      });
      add(LoadPharmacy());
    } catch (e) {
      emit(PharmacyError('Failed to discard medication: ${e.toString()}'));
    }
  }
}
