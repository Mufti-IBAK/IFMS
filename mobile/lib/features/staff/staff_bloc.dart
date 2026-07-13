import 'package:flutter_bloc/flutter_bloc.dart';
import 'staff_repository.dart';
import '../../core/database/local_db.dart';

// EVENTS
abstract class StaffEvent {}

class LoadStaffData extends StaffEvent {}

class AddStaffMember extends StaffEvent {
  final Map<String, dynamic> data;
  AddStaffMember(this.data);
}

class UpdateStaffMember extends StaffEvent {
  final String id;
  final Map<String, dynamic> data;
  UpdateStaffMember(this.id, this.data);
}

class DeleteStaffMember extends StaffEvent {
  final String id;
  DeleteStaffMember(this.id);
}

class IssueStaffQuery extends StaffEvent {
  final String staffId;
  final Map<String, dynamic> data;
  IssueStaffQuery(this.staffId, this.data);
}

class ProcessPayroll extends StaffEvent {
  final DateTime month;
  ProcessPayroll(this.month);
}

class ResolveStaffQuery extends StaffEvent {
  final String queryId;
  final String notes;
  ResolveStaffQuery(this.queryId, this.notes);
}

// STATES
abstract class StaffState {}

class StaffLoading extends StaffState {}

class StaffLoaded extends StaffState {
  final List<dynamic> staff;
  final List<LocalStaffQuery> queries;
  final Map<String, dynamic> budget;
  StaffLoaded(this.staff, this.queries, this.budget);
}

class StaffError extends StaffState {
  final String message;
  StaffError(this.message);
}

// BLOC
class StaffBloc extends Bloc<StaffEvent, StaffState> {
  final StaffRepository repository;

  StaffBloc(this.repository) : super(StaffLoading()) {
    on<LoadStaffData>((event, emit) async {
      final currentState = state;
      if (currentState is! StaffLoaded) {
        emit(StaffLoading());
      }
      try {
        final results = await Future.wait([
          repository.getStaff(),
          repository.getQueries(),
          repository.getBudgetSummary(),
        ]);
        emit(StaffLoaded(
          results[0] as List<dynamic>,
          results[1] as List<LocalStaffQuery>,
          results[2] as Map<String, dynamic>,
        ));
      } catch (e) {
        if (currentState is! StaffLoaded) {
          emit(StaffError(e.toString()));
        }
      }
    });

    on<AddStaffMember>((event, emit) async {
      try {
        await repository.addStaff(event.data);
        add(LoadStaffData());
      } catch (e) {
        emit(StaffError(e.toString()));
      }
    });

    on<UpdateStaffMember>((event, emit) async {
      try {
        await repository.updateStaff(event.id, event.data);
        add(LoadStaffData());
      } catch (e) {
        emit(StaffError(e.toString()));
      }
    });

    on<DeleteStaffMember>((event, emit) async {
      try {
        await repository.deleteStaff(event.id);
        add(LoadStaffData());
      } catch (e) {
        emit(StaffError(e.toString()));
      }
    });

    on<IssueStaffQuery>((event, emit) async {
      try {
        await repository.issueQuery(event.staffId, event.data);
        add(LoadStaffData());
      } catch (e) {
        emit(StaffError(e.toString()));
      }
    });

    on<ResolveStaffQuery>((event, emit) async {
      try {
        await repository.resolveQuery(event.queryId, event.notes);
        add(LoadStaffData());
      } catch (e) {
        emit(StaffError(e.toString()));
      }
    });

    on<ProcessPayroll>((event, emit) async {
      try {
        await repository.processPayroll(event.month);
        add(LoadStaffData());
      } catch (e) {
        emit(StaffError(e.toString()));
      }
    });
  }
}
