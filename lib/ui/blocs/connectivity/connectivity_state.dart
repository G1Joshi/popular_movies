import 'package:equatable/equatable.dart';

class ConnectivityState extends Equatable {
  final bool isConnected;
  final bool isInitialized;

  const ConnectivityState({
    this.isConnected = true,
    this.isInitialized = false,
  });

  ConnectivityState copyWith({bool? isConnected, bool? isInitialized}) {
    return ConnectivityState(
      isConnected: isConnected ?? this.isConnected,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }

  @override
  List<Object?> get props => [isConnected, isInitialized];
}
