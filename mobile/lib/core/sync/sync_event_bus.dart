import 'dart:async';

class SyncCompletedEvent {
  final Set<String> tablesUpdated;
  final DateTime timestamp;

  SyncCompletedEvent({required this.tablesUpdated, DateTime? timestamp})
      : timestamp = timestamp ?? DateTime.now();

  bool containsAny(List<String> tables) =>
      tablesUpdated.isEmpty || tables.any((t) => tablesUpdated.contains(t));
}

class SyncEventBus {
  static final SyncEventBus _instance = SyncEventBus._internal();
  factory SyncEventBus() => _instance;
  SyncEventBus._internal();

  final _controller = StreamController<SyncCompletedEvent>.broadcast();

  Stream<SyncCompletedEvent> get stream => _controller.stream;

  void fire(SyncCompletedEvent event) {
    if (!_controller.isClosed) {
      _controller.add(event);
    }
  }

  void dispose() {
    _controller.close();
  }
}
