import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:meta/meta.dart';

part 'network_event.dart';
part 'network_state.dart';

class NetworkBloc extends Bloc<NetworkEvent, NetworkState> {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _subscription;

  bool _isInitialCheck = true;
  bool _wasDisable = false;


  NetworkBloc() : super(NetworkInitial()) {
    on<NetworkChangedEvent>((event, emit) {
      final isNowDisable = event.results.contains(ConnectivityResult.none);

      if (_isInitialCheck) {
        _isInitialCheck = false;
        if (isNowDisable) {
          _wasDisable = true;
          emit(NetworkDisabled());
        }
        return;
      }
      if (isNowDisable) {
        _wasDisable = true;
        emit(NetworkDisabled());
      } else {
        if (_wasDisable) {
          _wasDisable = false;
          emit(NetworkReEnabled());
        }
      }
    }
      );

    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      add(NetworkChangedEvent(results));
    });
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
