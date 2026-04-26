import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient({http.Client? httpClient, String? baseUrl})
      : _http = httpClient ?? http.Client(),
        _baseUrl = baseUrl ?? ApiConfig.baseUrl;

  final http.Client _http;
  final String _baseUrl;

  void close() => _http.close();

  Future<dynamic> getJson(
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    final uri = _buildUri(path, queryParameters);
    final http.Response response;
    try {
      response = await _http
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(ApiConfig.requestTimeout);
    } on TimeoutException {
      throw ApiException(
        '요청 시간이 초과되었습니다. 서버 캐시가 비어있어 시간이 더 걸릴 수 있습니다.',
        uri: uri,
      );
    } catch (e) {
      throw ApiException('네트워크 오류: $e', uri: uri);
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        '서버에서 오류 응답을 반환했습니다.',
        statusCode: response.statusCode,
        uri: uri,
      );
    }

    final body = utf8.decode(response.bodyBytes);
    try {
      return jsonDecode(body);
    } on FormatException catch (e) {
      throw ApiException('응답 JSON 파싱 실패: ${e.message}', uri: uri);
    }
  }

  Uri _buildUri(String path, Map<String, String>? queryParameters) {
    final base = Uri.parse(_baseUrl);
    final combinedPath = _joinPath(base.path, path);
    return base.replace(
      path: combinedPath,
      queryParameters: (queryParameters == null || queryParameters.isEmpty)
          ? null
          : queryParameters,
    );
  }

  String _joinPath(String basePath, String path) {
    final left = basePath.endsWith('/')
        ? basePath.substring(0, basePath.length - 1)
        : basePath;
    final right = path.startsWith('/') ? path : '/$path';
    return '$left$right';
  }
}
