import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:network_layer/network/network_response_handler.dart';
import 'package:network_layer/services/cache_service.dart';
import 'package:network_layer/utils/get_it_injection.dart';
import 'package:network_layer/error/exceptions.dart';
import 'package:test/test.dart';

class MockCacheService extends Mock implements CacheService {}
class MockResponse extends Mock implements http.Response {}
class MockStreamedResponse extends Mock implements http.StreamedResponse {}

void main() {
  group('NetworkResponseHandler', () {
    late NetworkResponseHandler handler;
    late MockCacheService mockCacheService;

    setUp(() {
      mockCacheService = MockCacheService();
      getIt.registerSingleton<CacheService>(mockCacheService);
      handler = NetworkResponseHandler();
    });

    tearDown(() => getIt.reset());

    test('call - successful response - parses data and stores token', () async {
      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(200);
      when(() => mockResponse.body).thenReturn(jsonEncode({'data': 'success', 'token': 'new_token'}));

      final response = await handler.call(mockResponse);

      expect(response, '{"data": "success"}');
      verify(() => mockCacheService.setUserToken(token: 'new_token'));
    });

    test('call - successful response - no token present', () async {
      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(200);
      when(() => mockResponse.body).thenReturn(jsonEncode({'data': 'success'}));

      final response = await handler.call(mockResponse);

      expect(response, '{"data": "success"}');
      verifyNever(() => mockCacheService.setUserToken(token: any()));
    });

    test('call - unauthorized (401)', () async {
      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(401);

      expect(() => handler.call(mockResponse), throwsA(isA<AuthException>()));
    });

    test('call - not found (404)', () async {
      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(404);

      expect(() => handler.call(mockResponse), throwsA(isA<ServerException>()));
    });

    test('call - other error status code', () async {
      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(500);

      expect(() => handler.call(mockResponse), throwsA(isA<ServerException>()));
    });

    // Similar tests can be written for handleFormData with other scenarios (no token, errors)
  });
}
