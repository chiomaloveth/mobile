class UserOnlineStatusResponse {
  final bool success;
  final UserOnlineData data;

  UserOnlineStatusResponse({
    required this.success,
    required this.data,
  });

  factory UserOnlineStatusResponse.fromJson(Map<String, dynamic> json) {
    return UserOnlineStatusResponse(
      success: json['success'],
      data: UserOnlineData.fromJson(json['data']),
    );
  }
}

class UserOnlineData {
  final String id;
  final bool isOnline;
  final DateTime? lastActive;

  UserOnlineData({
    required this.id,
    required this.isOnline,
    this.lastActive,
  });

  factory UserOnlineData.fromJson(Map<String, dynamic> json) {
    return UserOnlineData(
      id: json['_id'],
      isOnline: json['isOnline'],
      lastActive: json['lastActive'] != null
          ? DateTime.parse(json['lastActive'])
          : null,
    );
  }
}
