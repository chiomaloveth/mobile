import 'package:hive_ce/hive.dart';

part 'call_log_model.g.dart';

// ✅ IMPORTANT: typeId 5, 6, 7 match the registrations in main.dart exactly.
// Do NOT change these without updating main.dart adapter registrations.

@HiveType(typeId: 5)
class CallLog extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String callerId;

  @HiveField(2)
  final String callerName;

  @HiveField(3)
  final String callerPhoto;

  @HiveField(4)
  final CallType callType;

  @HiveField(5)
  final CallStatus callStatus;

  @HiveField(6)
  final DateTime timestamp;

  @HiveField(7)
  final int duration;

  @HiveField(8)
  final bool isGroupCall;

  CallLog({
    required this.id,
    required this.callerId,
    required this.callerName,
    required this.callerPhoto,
    required this.callType,
    required this.callStatus,
    required this.timestamp,
    this.duration = 0,
    this.isGroupCall = false,
  });

  factory CallLog.fromJson(Map<String, dynamic> json) {
    return CallLog(
      id: json['_id'] as String? ?? '',
      callerId: json['callerId'] as String? ?? '',
      callerName: json['callerName'] as String? ?? 'Unknown',
      callerPhoto: json['callerPhoto'] as String? ?? '',
      callType: (json['isVideo'] == true) ? CallType.video : CallType.audio,
      callStatus: _parseStatus(json['callStatus'] as String?),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      duration: (json['duration'] as num?)?.toInt() ?? 0,
      isGroupCall: json['isGroupCall'] as bool? ?? false,
    );
  }

  static CallStatus _parseStatus(String? s) {
    switch (s) {
      case 'missed':
        return CallStatus.missed;
      case 'incoming':
        return CallStatus.incoming;
      case 'outgoing':
        return CallStatus.outgoing;
      default:
        return CallStatus.missed;
    }
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'callerId': callerId,
    'callerName': callerName,
    'callerPhoto': callerPhoto,
    'isVideo': callType == CallType.video,
    'callStatus': callStatus.name,
    'timestamp': timestamp.toIso8601String(),
    'duration': duration,
    'isGroupCall': isGroupCall,
  };
}

@HiveType(typeId: 6)
enum CallType {
  @HiveField(0)
  audio,

  @HiveField(1)
  video,
}

@HiveType(typeId: 7)
enum CallStatus {
  @HiveField(0)
  missed,

  @HiveField(1)
  incoming,

  @HiveField(2)
  outgoing,
}
