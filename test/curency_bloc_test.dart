import 'package:bloc_test/bloc_test.dart';
import 'package:currency_converter/viewmodels/currency/currency_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:currency_converter/data/database.dart';
import 'package:currency_converter/data/dio_client.dart';

// Tạo các lớp Mock từ tầng Data
class MockAppDatabase extends Mock implements AppDatabase {}
class MockDioClient extends Mock implements DioClient {}

void main() {
  late MockAppDatabase mockDb;
  late MockDioClient mockDioClient;
  late CurrencyBloc currencyBloc;

  setUp(() {
    mockDb = MockAppDatabase();
    mockDioClient = MockDioClient();
    currencyBloc = CurrencyBloc(db: mockDb, dioClient: mockDioClient);
  });

  tearDown(() {
    currencyBloc.close();
  });

  group('CurrencyBloc - Convert & Logic Test', () {
    final mockApiResponse = {
      'date': '2026-06-23T15:00:00Z',
      'base': 'USD',
      'rates': {
        'VND': '25450.00', // Dữ liệu String từ API
        'EUR': '0.92'
      }
    };

    blocTest<CurrencyBloc, CurrencyState>(
      'Test Convert thành công: Ép kiểu String từ API sang double và lưu thành công',
      setUp: () {
        // Giả lập DB trống ban đầu
        when(() => mockDb.getAllCurrencies()).thenAnswer((_) async => []);
        // Giả lập API trả về Map dữ liệu thô
        when(() => mockDioClient.getCurrencyRates()).thenAnswer(
              (_) async => Response(
            data: mockApiResponse,
            statusCode: 200,
            requestOptions: RequestOptions(path: 'rates/latest'),
          ),
        );
        // Giả lập hàm lưu vào DB chạy thành công
        when(() => mockDb.saveOrUpdateCurrencies(any())).thenAnswer((_) async => {});
      },
      build: () => currencyBloc,
      act: (bloc) => bloc.add(InitializedAppCurrencyEvent()),
      expect: () => [
        isA<CurrencyFirstLoadProgress>(), // Phải qua trạng thái Loading trước
        isA<CurrencyLoadSuccess>(),       // Sau đó nhảy sang trạng thái thành công
      ],
      verify: (_) {
        // Xác minh xem hàm save vào DB có được gọi hay không
        verify(() => mockDb.saveOrUpdateCurrencies(any())).called(1);
      },
    );
  });
}