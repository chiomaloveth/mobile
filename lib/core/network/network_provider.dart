import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qik_talk/utilities/constants/app_strings/api_strings.dart';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';

/// Interceptor to add Authorization header to every request
class AuthInterceptor extends Interceptor {
  final SaveValues _saveValues = SaveValues();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);

    // Only add Authorization header if it's a request to our own backend
    final isBackendRequest =
        options.path.startsWith(ApiStrings.serverUrlOne) ||
        options.path.startsWith(ApiStrings.baseUriTwo) ||
        !options.path.startsWith('http'); // Relative paths

    if (token != null && token.isNotEmpty && isBackendRequest) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Also ensuring Accept and Content-Type are set as we saw in existing code,
    // but ONLY for backend requests. Sending these to external services
    // can cause 401/400 errors due to unexpected headers.
    if (isBackendRequest) {
      options.headers['Accept'] = 'application/json';
      // Skip Content-Type for FormData — Dio auto-sets multipart headers
      if (options.data is! FormData) {
        options.headers['Content-Type'] = 'application/json';
      }
    }

    return handler.next(options);
  }
}

/// Provider for Dio instance configured with base URL and auth interceptor
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiStrings.baseUri,
      connectTimeout: const Duration(seconds: 120),
      receiveTimeout: const Duration(seconds: 120),
    ),
  );

  dio.interceptors.add(AuthInterceptor());

  // You can add a LogInterceptor here for debugging if needed
  dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));

  return dio;
});
