class ApiResult<T> {
  final T? data;
  final String? error;
  final String rawJson;

  const ApiResult._({
    this.data,
    this.error,
    this.rawJson = '',
  });

  bool get isSuccess => data != null && error == null;

  factory ApiResult.success(T data, {String rawJson = ''}) {
    return ApiResult._(data: data, rawJson: rawJson);
  }

  factory ApiResult.failure(String error) {
    return ApiResult._(error: error);
  }
}
