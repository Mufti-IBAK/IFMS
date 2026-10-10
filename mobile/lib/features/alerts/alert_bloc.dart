import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/database/local_db.dart';
import '../../core/sync/sync_event_bus.dart';
import 'alert_repository.dart';

abstract class AlertEvent {}
class LoadAlerts extends AlertEvent {}
class ResolveAlert extends AlertEvent {
  final String alertId;
  ResolveAlert(this.alertId);
}

abstract class AlertState {}
class AlertLoading extends AlertState {}
class AlertLoaded extends AlertState {
  final List<LocalAlert> alerts;
  AlertLoaded(this.alerts);
}
class AlertError extends AlertState {
  final String message;
  AlertError(this.message);
}

class AlertBloc extends Bloc<AlertEvent, AlertState> {
  final AlertRepository repository;
  StreamSubscription<SyncCompletedEvent>? _syncSubscription;

  AlertBloc(this.repository) : super(AlertLoading()) {
    _syncSubscription = SyncEventBus().stream.listen((event) {
      if (event.containsAny(['alerts'])) {
        add(LoadAlerts());
      }
    });

    on<LoadAlerts>((event, emit) async {
      final currentState = state;
      if (currentState is! AlertLoaded) {
        emit(AlertLoading());
      }
      try {
        final alerts = await repository.getAlerts();
        emit(AlertLoaded(alerts));
      } catch (e) {
        if (currentState is! AlertLoaded) {
          emit(AlertError(e.toString()));
        }
      }
    });

    on<ResolveAlert>((event, emit) async {
      try {
        await repository.resolveAlert(event.alertId);
        final alerts = await repository.getAlerts();
        emit(AlertLoaded(alerts));
      } catch (e) {
        emit(AlertError(e.toString()));
      }
    });
  }

  @override
  Future<void> close() {
    _syncSubscription?.cancel();
    return super.close();
  }
}

