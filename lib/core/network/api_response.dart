class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final Map<String, List<String>>? errors;
  final Map<String, dynamic>? meta;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.errors,
    this.meta,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    Map<String, List<String>>? parsedErrors;
    if (json['errors'] != null && json['errors'] is Map) {
      parsedErrors = {};
      (json['errors'] as Map).forEach((key, val) {
        if (val is List) {
          parsedErrors![key.toString()] =
              val.map((e) => e.toString()).toList();
        } else if (val != null) {
          parsedErrors![key.toString()] = [val.toString()];
        }
      });
    }

    return ApiResponse<T>(
      success: json['success'] == true,
      message: json['message'] as String?,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      errors: parsedErrors,
      meta: json['meta'] as Map<String, dynamic>?,
    );
  }

  String? getFirstErrorForField(String field) {
    if (errors != null && errors!.containsKey(field)) {
      final list = errors![field];
      if (list != null && list.isNotEmpty) {
        return list.first;
      }
    }
    return null;
  }
}
