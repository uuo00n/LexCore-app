class ApiEnvelope<T> {
  const ApiEnvelope({
    required this.code,
    required this.message,
    required this.data,
    this.requestId,
  });

  final String code;
  final String message;
  final T data;
  final String? requestId;

  bool get ok => code == 'OK';

  factory ApiEnvelope.fromJson(
    Map<String, dynamic> json,
    T Function(Object? value) dataDecoder,
  ) {
    return ApiEnvelope<T>(
      code: (json['code'] as String?)?.trim().isNotEmpty == true
          ? json['code'] as String
          : 'INTERNAL_ERROR',
      message: (json['message'] as String?) ?? 'request failed',
      data: dataDecoder(json['data']),
      requestId: json['request_id'] as String?,
    );
  }
}
