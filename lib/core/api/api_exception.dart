class ApiException implements Exception {
  ApiException(this.message, {this.statusCode, this.uri});

  final String message;
  final int? statusCode;
  final Uri? uri;

  @override
  String toString() {
    final code = statusCode != null ? ' [$statusCode]' : '';
    final path = uri != null ? ' (${uri!.path})' : '';
    return 'ApiException$code$path: $message';
  }
}
