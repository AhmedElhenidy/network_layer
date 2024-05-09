
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:network_layer/services/cache_service.dart';
import 'package:network_layer/utils/get_it_injection.dart';
import 'package:test/test.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  group('CacheService', () {
    late CacheService cacheService;
    late MockSharedPreferences mockPrefs;

    setUp(() {
      mockPrefs = MockSharedPreferences();
      getIt.registerSingleton<SharedPreferences>(mockPrefs);
      cacheService = CacheService();
    });

    tearDown(() => getIt.reset());

    test('setUserToken - sets token with "Bearer" prefix', () async {
      when(()=>mockPrefs.setString(any(), any())).thenReturn(Future.value(true));

      final result = await cacheService.setUserToken(token: "my_token");

      expect(result, true);
      verify(() => mockPrefs.setString(CacheService.userToken, "Bearer my_token"));
    });

    test('getUserToken - returns stored token', () async {
      when(()=>mockPrefs.getString(CacheService.userToken)).thenReturn("Bearer saved_token");

      final token = cacheService.getUserToken();

      expect(token, "Bearer saved_token");
    });

    test('getUserToken - returns null for missing key', () async {
      when(()=>mockPrefs.getString(CacheService.userToken)).thenReturn(null);

      final token = cacheService.getUserToken();

      expect(token, null);
    });

    test('clear - successfully clears preferences', () async {
      when(()=>mockPrefs.clear()).thenReturn(Future.value(true));

      final result = await cacheService.clear();

      expect(result, true);
      verify(() => mockPrefs.clear());
    });

    test('clear - handles exceptions', () async {
      when(()=>mockPrefs.clear()).thenThrow(Exception());

      final result = await cacheService.clear();

      expect(result, null);
    });
  });
}
