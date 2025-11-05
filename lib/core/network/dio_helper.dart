import 'package:dio/dio.dart';
import '../helper/app_logger.dart';
import '../constants/constants.dart';
import '../storage/cache_helper.dart';

class DioHelper {
  static late Dio dio;

  static void init() {
    BaseOptions options = BaseOptions(
      baseUrl: kBaseUrl,
      receiveDataWhenStatusError: true,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    );

    dio = Dio(options);

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = CacheHelper.getString(key: kAccessToken);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            AppLogger.w('🔄 Token expired... trying refresh');

            final refreshed = await _refreshToken();

            if (refreshed) {
              final newToken = CacheHelper.getString(key: kAccessToken);
              error.requestOptions.headers['Authorization'] =
                  'Bearer $newToken';

              final clonedRequest = await dio.fetch(error.requestOptions);
              return handler.resolve(clonedRequest);
            }
          }

          return handler.next(error);
        },
      ),
    );
  }

  static Future<bool> _refreshToken() async {
    final refreshToken = CacheHelper.getString(key: kRefreshToken);
    if (refreshToken == null) return false;

    try {
      final response = await dio.post(
        'auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      final newAccessToken = response.data[kAccessToken];
      final newRefreshToken = response.data[kRefreshToken];

      await CacheHelper.saveString(key: kAccessToken, value: newAccessToken);
      await CacheHelper.saveString(key: kRefreshToken, value: newRefreshToken);
      AppLogger.i('✅ Token refreshed');

      return true;
    } catch (e) {
      AppLogger.e('❌ Failed to refresh token: $e');
      return false;
    }
  }

  static Future<Response> postData({
    required String url,
    required Map<String, dynamic> data,
  }) async {
    return await dio.post(url, data: data);
  }

  static Future<Response> registerUser({
    required String firstName,
    required String lastName,
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        'users/add',
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'username': username,
          'password': password,
        },
      );
      AppLogger.i('✅ User Registered: ${response.data}');
      return response;
    } catch (error) {
      AppLogger.e('❌ Register Error: $error');
      rethrow;
    }
  }

  static Future<Response> getData({required String url}) async {
    return await dio.get(url);
  }
}
