import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'currency_event.dart';
part 'currency_state.dart';

class CurrencyBloc extends Bloc<CurrencyEvent, CurrencyState> {
  CurrencyBloc() : super(CurrencyInitial()) {
    on<CurrencyEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
