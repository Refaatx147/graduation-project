import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/repositories/call_repository.dart';
import '../../domain/models/call_history.dart';

// Events
abstract class CallEvent extends Equatable {
  const CallEvent();

  @override
  List<Object> get props => [];
}

class LoadCallHistory extends CallEvent {}

class SaveCallHistory extends CallEvent {
  final String receiverId;
  final String receiverName;
  final bool isVideoCall;
  final int duration;
  final String status;

  const SaveCallHistory({
    required this.receiverId,
    required this.receiverName,
    required this.isVideoCall,
    required this.duration,
    required this.status,
  });

  @override
  List<Object> get props => [receiverId, receiverName, isVideoCall, duration, status];
}

// States
abstract class CallState extends Equatable {
  const CallState();

  @override
  List<Object> get props => [];
}

class CallInitial extends CallState {}

class CallHistoryLoading extends CallState {}

class CallHistoryLoaded extends CallState {
  final List<CallHistory> callHistory;

  const CallHistoryLoaded(this.callHistory);

  @override
  List<Object> get props => [callHistory];
}

class CallHistoryError extends CallState {
  final String message;

  const CallHistoryError(this.message);

  @override
  List<Object> get props => [message];
}

// Cubit
class CallCubit extends Cubit<CallState> {
  final CallRepository _callRepository;
  bool _isDisposed = false;

  CallCubit({required CallRepository callRepository})
      : _callRepository = callRepository,
        super(CallInitial()) {
    loadCallHistory();
  }

  @override
  Future<void> close() {
    _isDisposed = true;
    return super.close();
  }

  Future<void> loadCallHistory() async {
    if (_isDisposed) return;
    
    try {
      emit(CallHistoryLoading());
      final callHistory = await _callRepository.getCallHistory();
      if (_isDisposed) return;
      
      // Sort call history by timestamp in descending order (newest first)
      callHistory.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      // Force a new state emission even if the data is the same
      emit(CallHistoryLoaded([...callHistory]));
    } catch (e) {
      if (_isDisposed) return;
      emit(CallHistoryError(e.toString()));
    }
  }

  Future<void> saveCallHistory({
    required String receiverId,
    required String receiverName,
    required bool isVideoCall,
    required int duration,
    required String status,
  }) async {
    if (_isDisposed) return;
    
    try {
      // Save the call history
      await _callRepository.saveCallHistory(
        receiverId: receiverId,
        receiverName: receiverName,
        isVideoCall: isVideoCall,
        duration: duration,
        status: status,
      );
      
      if (_isDisposed) return;
      
      // Immediately load and emit new state
      await loadCallHistory();
    } catch (e) {
      if (_isDisposed) return;
      emit(CallHistoryError(e.toString()));
    }
  }

  void refreshCallHistory() {
    loadCallHistory();
  }
} 