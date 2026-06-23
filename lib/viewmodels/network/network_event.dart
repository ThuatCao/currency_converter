part of 'network_bloc.dart';


abstract class NetworkEvent {}

class NetworkChangedEvent extends NetworkEvent {
  final List<ConnectivityResult> results;

  NetworkChangedEvent(this.results);

}
