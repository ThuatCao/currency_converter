import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:currency_converter/constants/constants.dart';

class DioClient {
  late Dio _dio;
  final Connectivity _connectivity = Connectivity();

  DioClient() {
    _initializeDio();
  }

  void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: currencyApiUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        contentType: Headers.jsonContentType,
      ),
    );

    // Add interceptor to check network connectivity and add API key
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Check network connectivity before making request
          final isConnected = await _checkNetworkConnectivity();

          if (!isConnected) {
            return handler.reject(
              DioException(
                requestOptions: options,
                message: 'No internet connection',
                type: DioExceptionType.unknown,
              ),
            );
          }

          // Add API key to query parameters
          options.queryParameters['apikey'] = currencyFreaksKey;
          return handler.next(options);
        },
        onError: (error, handler) {
          // Handle network-related errors
          if (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.receiveTimeout ||
              error.type == DioExceptionType.sendTimeout) {
            return handler.reject(
              DioException(
                requestOptions: error.requestOptions,
                message: 'Network timeout. Please check your connection.',
                type: error.type,
              ),
            );
          }
          return handler.next(error);
        },
      ),
    );
  }

  /// Check if device has internet connectivity
  Future<bool> _checkNetworkConnectivity() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      // Handle both List<ConnectivityResult> and ConnectivityResult
      if (connectivityResult is List<ConnectivityResult>) {
        return !connectivityResult.contains(ConnectivityResult.none);
      } else {
        return connectivityResult != ConnectivityResult.none;
      }
    } catch (e) {
      return false;
    }
  }

  /// Get the Dio instance
  Dio get dio => _dio;

  /// Fetch currency rates
  Future<Response> getCurrencyRates() async {
    try {
      final response = await _dio.get('');
      return response;
    } on DioException {
      rethrow;
    }
  }

  /// Check network status directly (can be used by UI)
  Future<bool> checkNetworkStatus() async {
    return await _checkNetworkConnectivity();
  }
}


