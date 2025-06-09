import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class NavigationEvent extends Equatable {
  const NavigationEvent();

  @override
  List<Object> get props => [];
}

class NavigateToIndex extends NavigationEvent {
  final int index;

  const NavigateToIndex(this.index);

  @override
  List<Object> get props => [index];
}

class NavigateToScreen extends NavigationEvent {
  final String screenName;

  const NavigateToScreen(this.screenName);

  @override
  List<Object> get props => [screenName];
}

// State
class NavigationState extends Equatable {
  final int currentIndex;

  const NavigationState({
    this.currentIndex = 0,
  });

  NavigationState copyWith({
    int? currentIndex,
  }) {
    return NavigationState(
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }

  @override
  List<Object> get props => [currentIndex];
}

// Cubit
class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit() : super(const NavigationState());

  void navigateToIndex(int index) {
    if (index >= 0 && index <= 4) {  // Ensure index is valid
      emit(NavigationState(currentIndex: index));  // Create new state instead of copyWith
    }
  }

  void navigateToScreen(String screenName) {
    int index = 0;
    switch (screenName.toLowerCase()) {
      case 'home':
        index = 0;
        break;
      case 'qr':
        index = 1;
        break;
      case 'map':
        index = 2;
        break;
      case 'call':
        index = 3;
        break;
      case 'headset connection':
        index = 4;
        break;
    }
    emit(NavigationState(currentIndex: index));  // Create new state instead of copyWith
  }
} 