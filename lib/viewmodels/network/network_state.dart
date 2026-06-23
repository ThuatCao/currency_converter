part of 'network_bloc.dart';


abstract class NetworkState {}

final class NetworkInitial extends NetworkState {}
final class NetworkEnabled extends NetworkState {}
final class NetworkReEnabled extends NetworkState {}
final class NetworkDisabled extends NetworkState {}

