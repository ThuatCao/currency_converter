import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

import '../data/database.dart';
import '../data/dio_client.dart';

part 'currency_event.dart';
part 'currency_state.dart';

class CurrencyBloc extends Bloc<CurrencyEvent, CurrencyState> {

  final AppDatabase db;
  final DioClient dioClient;
  Timer? _retryTimer;

  CurrencyBloc({required this.db, required this.dioClient}) : super(CurrencyInitial()) {
    on<InitializedAppCurrencyEvent>((event,emit) async{
      _retryTimer?.cancel();

      final localData = await db.getAllCurrencies();
      final bool hasLocalData = localData.isNotEmpty;

      @override
      Future<void> close() {
        _retryTimer?.cancel();
        return super.close();
      }

      void startAutoRetry(){
        int seconds = 10;
        _retryTimer = Timer.periodic(const Duration(seconds: 1), (timer){
          seconds--;
          if(isClosed){
            timer.cancel();
            return;
          }
          add(AutoRetryCountdownTick(remainingTicks: seconds));
          if(seconds == 0) timer.cancel();
        });
      }

      try {
        if(!hasLocalData) emit(CurrencyFirstLoadProgress());

        final response = await dioClient.getCurrencyRates();

        final String dateStr = response.data['date'] ?? '';
        final Map<String, dynamic> rates = response.data['rates'] ?? {};
        final DateTime updatedAt = DateTime.tryParse(dateStr) ?? DateTime.now();
        
        List<Currency> currencyList = [];
        rates.forEach((key, value) {
          final double? rate = double.tryParse(value.toString());
          if (rate != null) {
            currencyList.add(
                Currency(code: key, rate: rate, updatedAt: updatedAt));
          }
        });
        
        if(currencyList.isNotEmpty){
          await db.saveOrUpdateCurrencies(currencyList);
        }
        
        final freshData = await db.getAllCurrencies();
        final String formattedDate = DateFormat('HH:mm dd/MM/yyyy').format(DateTime.now());
        emit(CurrencyLoadSuccess(
          currencies: freshData,
          lastUpdatedText: formattedDate,
          isFromCache: false,
        ));

      } catch (e) {
        if(hasLocalData){
          emit(CurrencyLoadSuccess(currencies: localData, lastUpdatedText: "Using Cached Data", isFromCache: true));
        } else {
         startAutoRetry();
          emit(CurrencyFirstLoadFailure(message:
          e is DioException && e.type == DioExceptionType.connectionError
              ?
          "Không có kết nối internet. Ứng dụng cần nạp dữ liệu vào lần đầu. Vui lòng kiểm tra lại thiết bị!"
              : e.toString(),
          retryCountdown: 10));
        }
      }
    });

    on<AutoRetryCountdownTick>((event,emit){
      if(event.remainingTicks > 0){
        emit(CurrencyFirstLoadFailure(message: "Không có kết nối internet. Ứng dụng cần nạp dữ liệu vào lần đầu. Vui lòng kiểm tra lại thiết bị!", retryCountdown: event.remainingTicks));
      }else{
        add(InitializedAppCurrencyEvent());
      }
    });




  }
}
