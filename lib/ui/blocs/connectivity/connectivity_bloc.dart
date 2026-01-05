import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/connectivity_service.dart';
import 'connectivity_event.dart';
import 'connectivity_state.dart';

class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  final ConnectivityService connectivityService;
  StreamSubscription<bool>? _connectivitySubscription;

  ConnectivityBloc({required this.connectivityService})
    : super(const ConnectivityState()) {
    on<StartConnectivityMonitoring>(_onStartMonitoring);
    on<ConnectivityChanged>(_onConnectivityChanged);
  }

  Future<void> _onStartMonitoring(
    StartConnectivityMonitoring event,
    Emitter<ConnectivityState> emit,
  ) async {
    final isConnected = await connectivityService.isConnected;
    emit(state.copyWith(isConnected: isConnected, isInitialized: true));

    _connectivitySubscription?.cancel();
    _connectivitySubscription = connectivityService.onConnectivityChanged
        .listen((isConnected) {
          add(ConnectivityChanged(isConnected));
        });
  }

  void _onConnectivityChanged(
    ConnectivityChanged event,
    Emitter<ConnectivityState> emit,
  ) {
    emit(state.copyWith(isConnected: event.isConnected));
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }
}
