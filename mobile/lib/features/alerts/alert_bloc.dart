import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/database/local_db.dart';
import 'alert_repository.dart';

abstract class AlertEvent {}
class LoadAlerts extends AlertEvent {}

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

  AlertBloc(this.repository) : super(AlertLoading()) {
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
  }
}
