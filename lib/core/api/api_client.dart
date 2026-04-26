import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../auth/auth_repository.dart';
import '../config/api_config.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient({
    http.Client? httpClient,
    String? baseUrl,
    AuthRepository? authRepository,
  })  : _http = httpClient ?? http.Client(),
        _baseUrl = baseUrl ?? ApiConfig.baseUrl,
        _auth = authRepository ?? AuthRepository();

  final http.Client _http;
  final String _baseUrl;
  final AuthRepository _auth;

  void close() => _http.close();

  /// 공통 헤더 — 세션 있으면 Authorization Bearer 자동 첨부.
  Map<String, String> _buildHeaders({Map<String, String>? extra}) {
    final headers = <String, String>{
      'Accept': 'application/json',
      ...?extra,
    };
    final token = _auth.currentAccessToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<dynamic> getJson(
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    final uri = _buildUri(path, queryParameters);
    final http.Response response;
    try {
      response = await _http
          .get(uri, headers: _buildHeaders())
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

  Future<dynamic> postJson(
    String path, {
    Map<String, String>? queryParameters,
    Map<String, dynamic>? body,
  }) async {
    final uri = _buildUri(path, queryParameters);
    return _writeJson(uri, 'POST', body);
  }

  Future<dynamic> patchJson(
    String path, {
    Map<String, String>? queryParameters,
    Map<String, dynamic>? body,
  }) async {
    final uri = _buildUri(path, queryParameters);
    return _writeJson(uri, 'PATCH', body);
  }

  Future<dynamic> delete(
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    final uri = _buildUri(path, queryParameters);
    final http.Response response;
    try {
      response = await _http
          .delete(uri, headers: _buildHeaders())
          .timeout(ApiConfig.requestTimeout);
    } on TimeoutException {
      throw ApiException('요청 시간이 초과되었습니다.', uri: uri);
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
    if (body.isEmpty) return null;
    try {
      return jsonDecode(body);
    } on FormatException catch (e) {
      throw ApiException('응답 JSON 파싱 실패: ${e.message}', uri: uri);
    }
  }

  Future<dynamic> _writeJson(
    Uri uri,
    String method,
    Map<String, dynamic>? body,
  ) async {
    final headers = _buildHeaders(extra: {'Content-Type': 'application/json'});
    final encoded = body == null ? null : jsonEncode(body);
    final http.Response response;
    try {
      final request = http.Request(method, uri)..headers.addAll(headers);
      if (encoded != null) request.body = encoded;
      final streamed = await _http
          .send(request)
          .timeout(ApiConfig.requestTimeout);
      response = await http.Response.fromStream(streamed);
    } on TimeoutException {
      throw ApiException('요청 시간이 초과되었습니다.', uri: uri);
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

    final responseBody = utf8.decode(response.bodyBytes);
    if (responseBody.isEmpty) return null;
    try {
      return jsonDecode(responseBody);
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
