class CountResponse {
  final bool success;
  final int count;

  CountResponse({
    required this.success,
    required this.count,
  });

  factory CountResponse.fromJson(Map<String, dynamic> json) {
    return CountResponse(
      success: json['success'] ?? false,
      count: json['count'] ?? 0,
    );
  }
}
