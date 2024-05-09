import 'package:data_connection_checker_nulls/data_connection_checker_nulls.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_layer/network/network_info.dart';
import 'package:test/test.dart';

class MockDataConnectionChecker extends Mock implements DataConnectionChecker {}

void main() {
  group('NetworkInfoImpl', () {
    late NetworkInfo networkInfo;
    late MockDataConnectionChecker mockChecker;

    setUp(() {
      mockChecker = MockDataConnectionChecker();
      networkInfo = NetworkInfoImpl(mockChecker);
    });

    test('isConnected - returns true when connection exists', () async {
      when(() => mockChecker.hasConnection).thenReturn(Future.value(true));

      final isConnected = await networkInfo.isConnected;

      expect(isConnected, true);
    });

    test('isConnected - returns false when no connection exists', () async {
      when(() => mockChecker.hasConnection).thenReturn(Future.value(false));

      final isConnected = await networkInfo.isConnected;

      expect(isConnected, false);
    });

    test('isConnected - throws exception for unexpected error', () async {
      when(() => mockChecker.hasConnection).thenThrow(Exception('Unexpected error'));

      expect(() => networkInfo.isConnected, throwsA(isA<Exception>()));
    });
  });
}
