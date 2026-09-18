class ApiResponse<T> {
  final bool isSuccess;
  final T? data;
  final String? message;
  final int? statusCode;

  const ApiResponse._({
    required this.isSuccess,
    this.data,
    this.message,
    this.statusCode,
  });

  factory ApiResponse.success(T data, [int? statusCode]) {
    return ApiResponse._(
      isSuccess: true,
      data: data,
      statusCode: statusCode ?? 200,
    );
  }

  factory ApiResponse.error(String message, [int? statusCode]) {
    return ApiResponse._(
      isSuccess: false,
      message: message,
      statusCode: statusCode,
    );
  }
}
