// Modelo estándar de respuesta API
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final String? errorCode;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errorCode,
  });

  factory ApiResponse.success(T data, [String? message]) => ApiResponse(
    success: true,
    message: message ?? 'Operación exitosa',
    data: data,
  );

  factory ApiResponse.error(String message, [String? errorCode]) => ApiResponse(
    success: false,
    message: message,
    errorCode: errorCode,
  );

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'data': data,
    'errorCode': errorCode,
  };
}
