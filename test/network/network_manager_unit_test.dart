import 'package:mocktail/mocktail.dart';
import 'package:network_layer/utils/get_it_injection.dart';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:http_interceptor/http_interceptor.dart';
import 'package:network_layer/network/network_manager.dart';
import 'package:network_layer/services/cache_service.dart';

class MockCacheService extends Mock implements CacheService {}
class MockClient extends Mock implements http.Client {}

void main() {
  group('NetworkManager', ()
  {
    late NetworkManager networkManager;
    late MockCacheService mockCacheService;
    late MockClient mockClient;

    setUp(() {
      mockCacheService = MockCacheService();
      mockClient = MockClient();
      networkManager = NetworkManager();
      networkManager.https =
          InterceptedHttp.build(interceptors: [LoggingInterceptor()]);
      when(() => getIt<CacheService>()).thenReturn(mockCacheService);
      when(() => mockCacheService.getUserToken()).thenReturn("valid_token");
    });

    test('GET request - successful response', () async {
      final mockResponse = http.Response('{"data": "success"}', 200);
      when(() => mockClient.get(any())).thenAnswer((_) =>
          Future.value(mockResponse));

      networkManager.https = MockClient() as InterceptedHttp;
      when(() =>
          (networkManager.https as MockClient).get(any(named: "any url")))
          .thenAnswer((_) => Future.value(mockResponse));

      final response = await networkManager.request(
        method: RequestMethod.get,
        endPoint: "/api/data",
      );

      expect(response.statusCode, 200);
      expect(response.body, '{"data": "success"}');
    });

    test('GET request - throws exception for non-200 status code', () async {
      final mockResponse = http.Response('Error', 404);
      when(() => mockClient.get(any(named: "uri"))).thenAnswer((_) =>
          Future.value(mockResponse));

      networkManager.https = MockClient() as InterceptedHttp;
      when(() => (networkManager.https as MockClient).get(any(named: "uri")))
          .thenAnswer((_) => Future.value(mockResponse));

      expect(() =>
          networkManager.request(
              method: RequestMethod.get, endPoint: "/api/data"),
          throwsA(isA<Exception>()));
    });

    test('POST request - successful response', () async {
      final mockResponse = http.Response('{"data": "created"}', 201);
      when(() => mockClient.post(any(named: "url"), body: any)).thenAnswer((
          _) => Future.value(mockResponse));

      networkManager.https = MockClient() as InterceptedHttp;
      when(() =>
          (networkManager.https as MockClient).post(
              any(named: "url"), body: any)).thenAnswer((_) =>
          Future.value(mockResponse));

      final body = {"name": "John Doe"};
      final response = await networkManager.request(
        method: RequestMethod.post,
        endPoint: "/api/users",
        body: body,
      );

      expect(response.statusCode, 201);
      expect(response.body, '{"data": "created"}');
    });

    test('requestWithFormData - includes authorization header', () async {
      final mockStreamedResponse = http.StreamedResponse(Stream.empty(), 200);
      when(()=>mockClient.send(any())).thenAnswer((_) =>
          Future.value(mockStreamedResponse));

      networkManager.https = MockClient() as InterceptedHttp;
      when(()=>(networkManager.https as MockClient).send(any())).thenAnswer((_) =>
          Future.value(mockStreamedResponse));

      await networkManager.requestWithFormData(endPoint: "/api/upload");

      final capturedRequest = verify(()=>mockClient.send(captureAny())).captured.single;
      expect(capturedRequest.headers["Authorization"], "valid_token");
    });
  });
  }
