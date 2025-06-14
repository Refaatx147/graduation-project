import 'dart:async';

class BlinkEventBus {
  BlinkEventBus._internal();
  static final BlinkEventBus _instance = BlinkEventBus._internal();
  factory BlinkEventBus() => _instance;
  final _controller = StreamController<void>.broadcast();
  Stream<void> get stream => _controller.stream;
  void emit() {
    _controller.add(null);
  }
} 