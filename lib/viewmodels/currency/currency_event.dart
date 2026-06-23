part of 'currency_bloc.dart';


abstract class CurrencyEvent {}

class InitializedAppCurrencyEvent extends CurrencyEvent {}

class AutoRetryCountdownTick extends CurrencyEvent {
  final int remainingTicks;

  AutoRetryCountdownTick({required this.remainingTicks});
}