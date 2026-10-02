import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import 'package:hive_ce/hive.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:qik_talk/features/calls/models/call_log_model.dart';
import 'package:qik_talk/features/calls/webrtc_services/webrtc_service.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/features/chat/general/data/chat_list_item_hive.dart';
import 'package:qik_talk/utilities/constants/app_config.dart';

final _kBaseUrl = AppConfig.apiUrl.endsWith('/')
    ? AppConfig.apiUrl.substring(0, AppConfig.apiUrl.length - 1)
    : AppConfig.apiUrl;

enum CallState { idle, connecting, ringing, reconnecting, inProgress, ended, failed }

enum CallDirection { incoming, outgoing }

class CallInfo {
  final String callId;
  final String userId;
  final String userName;
  final String userPhoto;
  final bool isVideo;
  final CallDirection direction;
  final CallState state;
  final DateTime startTime;

  const CallInfo({
    required this.callId,
    required this.userId,
    required this.userName,
    required this.userPhoto,
    required this.isVideo,
    required this.direction,
    required this.state,
    required this.startTime,
  });

  CallInfo copyWith({
    String? callId,
    String? userId,
    String? userName,
    String? userPhoto,
    bool? isVideo,
    CallDirection? direction,
    CallState? state,
    DateTime? startTime,
  }) => CallInfo(
    callId: callId ?? this.callId,
    userId: userId ?? this.userId,
    userName: userName ?? this.userName,
    userPhoto: userPhoto ?? this.userPhoto,
    isVideo: isVideo ?? this.isVideo,
    direction: direction ?? this.direction,
    state: state ?? this.state,
    startTime: startTime ?? this.startTime,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CallInfo &&
          runtimeType == other.runtimeType &&
          callId == other.callId &&
          userId == other.userId &&
          userName == other.userName &&
          userPhoto == other.userPhoto &&
          isVideo == other.isVideo &&
          direction == other.direction &&
          state == other.state &&
          startTime == other.startTime;

  @override
  int get hashCode =>
      callId.hashCode ^
      userId.hashCode ^
      userName.hashCode ^
      userPhoto.hashCode ^
      isVideo.hashCode ^
      direction.hashCode ^
      state.hashCode ^
      startTime.hashCode;
}

class CallStateNotifier extends StateNotifier<CallInfo?> {
  CallStateNotifier() : super(null);

  final WebRTCService webrtcService = WebRTCService();

  IO.Socket? _socket;
  String _myUserId = '';
  String _myUsername = '';
  String _authToken = '';
  String? _roomId;

  Timer? _callTimer;
  Timer? _timeoutTimer;
  int _callDuration = 0;
  DateTime? _callStartTime;

  bool _socketListenersAttached = false;
  bool _acceptInProgress = false;
  bool _endCallInProgress = false;
  bool _isDisposed = false;

  bool _isMuted = false;
  bool _isSpeakerOn = false;
  bool _isCameraOn = false;

  int get callDuration => _callDuration;
  bool get isMuted => _isMuted;
  bool get isSpeakerOn => _isSpeakerOn;
  bool get isCameraOn => _isCameraOn;

  void initializeWithSocket(
    IO.Socket socket, {
    required String myUserId,
    required String myUsername,
    required String authToken,
  }) {
    _socket = socket; // ✅ Share the global socket, don't spawn a new one!
    _myUserId = myUserId.trim();
    _myUsername = myUsername.trim().replaceAll(' ', '_');
    _authToken = authToken;

    _setupSocketListeners();
    debugPrint('✅ CallStateNotifier initialized for user=$_myUserId');
  }

  void _setupSocketListeners() {
    if (_socket == null) return;

    final events = [
      'video:incomingCall',
      'video:callResponse',
      'video:ready',
      'video:offer',
      'video:answer',
      'video:iceCandidate',
      'video:leaveCall',
      'video:error',
      'audio:incomingCall',
      'audio:callResponse',
      'audio:ready',
      'audio:offer',
      'audio:answer',
      'audio:iceCandidate',
      'audio:leaveCall',
      'audio:error'
    ];

    for (final ev in events) {
      _socket!.off(ev);
    }

    // --- Video Listeners ---
    _socket!.on('video:incomingCall', (data) {
      debugPrint('📞 [Socket] Incoming video call: $data');
      _onIncomingCallReceived(Map<String, dynamic>.from(data as Map), true);
    });

    _socket!.on('video:callResponse', (data) {
      debugPrint('📥 [Socket] Video call response: $data');
      _onCallResponse(Map<String, dynamic>.from(data as Map));
    });

    _socket!.on('video:ready', (data) {
      debugPrint('📥 [Socket] Video call ready: $data');
      _onCallReady(Map<String, dynamic>.from(data as Map), true);
    });

    _socket!.on('video:offer', (data) {
      _onOfferReceived(Map<String, dynamic>.from(data as Map));
    });

    _socket!.on('video:answer', (data) {
      _onAnswerReceived(Map<String, dynamic>.from(data as Map));
    });

    _socket!.on('video:iceCandidate', (data) {
      _onIceCandidateReceived(Map<String, dynamic>.from(data as Map));
    });

    _socket!.on('video:leaveCall', (_) => _onRemoteLeave());
    _socket!.on('video:error', (data) => _onCallError(data));

    // --- Audio Listeners ---
    _socket!.on('audio:incomingCall', (data) {
      debugPrint('📞 [Socket] Incoming audio call: $data');
      _onIncomingCallReceived(Map<String, dynamic>.from(data as Map), false);
    });

    _socket!.on('audio:callResponse', (data) {
      debugPrint('📥 [Socket] Audio call response: $data');
      _onCallResponse(Map<String, dynamic>.from(data as Map));
    });

    _socket!.on('audio:ready', (data) {
      debugPrint('📥 [Socket] Audio call ready: $data');
      _onCallReady(Map<String, dynamic>.from(data as Map), false);
    });

    _socket!.on('audio:offer', (data) {
      _onOfferReceived(Map<String, dynamic>.from(data as Map));
    });

    _socket!.on('audio:answer', (data) {
      _onAnswerReceived(Map<String, dynamic>.from(data as Map));
    });

    _socket!.on('audio:iceCandidate', (data) {
      _onIceCandidateReceived(Map<String, dynamic>.from(data as Map));
    });

    _socket!.on('audio:leaveCall', (_) => _onRemoteLeave());
    _socket!.on('audio:error', (data) => _onCallError(data));

    _socketListenersAttached = true;
    debugPrint('✅ WebRTC/Socket calling listeners attached');
  }

  void _onIncomingCallReceived(Map<String, dynamic> data, bool isVideo) {
    final callerId = data['callerId']?.toString() ?? '';
    final callerName = data['callerName']?.toString() ?? (isVideo ? 'Video Caller' : 'Audio Caller');

    if (callerId.isEmpty) return;

    if (state != null && state!.state != CallState.ended) {
      // Send busy response
      final prefix = isVideo ? 'video:' : 'audio:';
      _emitSafely('${prefix}respondToCall', {
        'callerId': callerId,
        'accepted': false,
      });
      return;
    }

    handleIncomingCall(
      callerId: callerId,
      callerName: callerName,
      callerPhoto: '',
      isVideo: isVideo,
      callId: callerId,
    );
  }

  void _onCallResponse(Map<String, dynamic> data) {
    final accepted = data['accepted'] == true;
    final roomId = data['roomId']?.toString() ?? '';

    if (!accepted) {
      debugPrint('📵 Call rejected by remote user');
      _updateCallState(CallState.ended);
      _cleanup();
    } else {
      _roomId = roomId;
      debugPrint('📲 Call accepted by remote user. Room ID: $roomId (waiting for ready event)');
    }
  }

  Future<void> _onCallReady(Map<String, dynamic> data, bool isVideo) async {
    final roomId = data['roomId']?.toString() ?? '';
    final iceServers = data['iceServers'] as List<dynamic>?;

    _roomId = roomId;
    debugPrint('🌐 Call is ready. Room ID: $roomId. Initializing WebRTC components...');

    try {
      _updateCallState(CallState.connecting);

      // Initialize local media and WebRTC peer connection
      await webrtcService.initRenderers();
      await webrtcService.openUserMedia(isVideo);
      
      // Keep track of toggle states
      _isMuted = false;
      _isSpeakerOn = isVideo; // default speaker on for video, off/earpiece for audio
      _isCameraOn = isVideo;

      await webrtcService.setupPeerConnection(iceServers);

      // Bind WebRTC Service callbacks back to signaling socket
      webrtcService.currentTargetUserId = state?.userId;
      final prefix = isVideo ? 'video:' : 'audio:';

      webrtcService.onSendSignal = (targetUserId, offerOrAnswer) {
        final event = offerOrAnswer['type'] == 'offer' ? '${prefix}offer' : '${prefix}answer';
        _emitSafely(event, {
          'to': targetUserId,
          offerOrAnswer['type']: offerOrAnswer,
        });
      };

      webrtcService.onSendCandidate = (targetUserId, candidate) {
        _emitSafely('${prefix}iceCandidate', {
          'to': targetUserId,
          'candidate': candidate,
        });
      };

      // User A (initiator) creates and sends the initial offer
      if (state?.direction == CallDirection.outgoing) {
        debugPrint('📤 Sending WebRTC offer...');
        await webrtcService.createOffer();
      }

      _updateCallState(CallState.inProgress);
      _startTimer();
      _callStartTime = DateTime.now();
    } catch (e) {
      debugPrint('❌ WebRTC setup failed: $e');
      _updateCallState(CallState.failed);
      _cleanup();
    }
  }

  Future<void> _onOfferReceived(Map<String, dynamic> data) async {
    final offer = data['offer'];
    if (offer != null) {
      debugPrint('📥 Received remote WebRTC offer, processing...');
      await webrtcService.handleRemoteSignal(offer);
    }
  }

  Future<void> _onAnswerReceived(Map<String, dynamic> data) async {
    final answer = data['answer'];
    if (answer != null) {
      debugPrint('📥 Received remote WebRTC answer, processing...');
      await webrtcService.handleRemoteSignal(answer);
    }
  }

  Future<void> _onIceCandidateReceived(Map<String, dynamic> data) async {
    final candidate = data['candidate'];
    if (candidate != null) {
      debugPrint('📥 Received remote ICE candidate, adding...');
      await webrtcService.addCandidate(candidate);
    }
  }

  void _onRemoteLeave() {
    debugPrint('📴 Remote user ended the call');
    _updateCallState(CallState.ended);
    _cleanup();
  }

  void _onCallError(dynamic data) {
    final msg = data is Map ? (data['message']?.toString() ?? 'Call error') : data.toString();
    debugPrint('❌ Call error details: $msg');
    _updateCallState(CallState.failed);
    _cleanup();
  }

  void prepareOutgoingCall({
    required String userId,
    required String userName,
    required String userPhoto,
    required bool isVideo,
  }) {
    _isDisposed = false;
    _endCallInProgress = false;
    _acceptInProgress = false;

    state = CallInfo(
      callId: '',
      userId: userId,
      userName: userName,
      userPhoto: userPhoto,
      isVideo: isVideo,
      direction: CallDirection.outgoing,
      state: CallState.connecting,
      startTime: DateTime.now(),
    );
  }

  Future<void> startCall({
    required String userId,
    required String userName,
    required String userPhoto,
    required bool isVideo,
  }) async {
    _isDisposed = false;
    _endCallInProgress = false;
    _acceptInProgress = false;

    if (state == null || state!.callId != '') {
      state = CallInfo(
        callId: '',
        userId: userId,
        userName: userName,
        userPhoto: userPhoto,
        isVideo: isVideo,
        direction: CallDirection.outgoing,
        state: CallState.connecting,
        startTime: DateTime.now(),
      );
    }

    final prefix = isVideo ? 'video:' : 'audio:';
    debugPrint('📤 Emitting initiateCall to user=$userId');
    _emitSafely('${prefix}initiateCall', {
      'receiverId': userId,
    });

    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(const Duration(seconds: 60), () {
      if (state?.state == CallState.connecting ||
          state?.state == CallState.ringing) {
        debugPrint('⏱️ Outgoing call timeout reached, canceling call');
        endCall();
      }
    });
  }

  void handleIncomingCall({
    required String callerId,
    required String callerName,
    required String callerPhoto,
    required bool isVideo,
    required String callId,
  }) {
    if (state != null &&
        state!.state != CallState.ended &&
        state!.callId != callId) {
      debugPrint('ℹ️ handleIncomingCall: already in active call, ignoring');
      return;
    }

    if (state != null && state!.callId == callId) {
      debugPrint('ℹ️ handleIncomingCall: duplicate incoming call, ignoring');
      return;
    }

    debugPrint('📞 Incoming call from $callerName (callId: $callId)');

    _isDisposed = false;
    _endCallInProgress = false;
    _acceptInProgress = false;

    state = CallInfo(
      callId: callId,
      userId: callerId,
      userName: callerName,
      userPhoto: callerPhoto,
      isVideo: isVideo,
      direction: CallDirection.incoming,
      state: CallState.ringing,
      startTime: DateTime.now(),
    );
  }

  Future<void> acceptCall() async {
    if (_acceptInProgress) return;
    if (state == null || state!.direction != CallDirection.incoming) return;
    if (state!.state == CallState.inProgress ||
        state!.state == CallState.connecting) return;

    _acceptInProgress = true;
    debugPrint('📲 Accepting incoming call from ${state!.userName}');

    final prefix = state!.isVideo ? 'video:' : 'audio:';
    _emitSafely('${prefix}respondToCall', {
      'callerId': state!.userId,
      'accepted': true,
    });

    _updateCallState(CallState.connecting);
    _timeoutTimer?.cancel();
    _acceptInProgress = false;
  }

  void rejectCall() {
    if (state == null) return;

    debugPrint('📵 Rejecting incoming call from ${state!.userName}');
    final prefix = state!.isVideo ? 'video:' : 'audio:';
    _emitSafely('${prefix}respondToCall', {
      'callerId': state!.userId,
      'accepted': false,
    });

    _saveCallLog(
      userId: state!.userId,
      userName: state!.userName,
      userPhoto: state!.userPhoto,
      callType: state!.isVideo ? 'video' : 'audio',
      callStatus: 'missed',
      duration: 0,
      isOutgoing: false,
    );
    _updateCallState(CallState.ended);
    _cleanup();
  }

  Future<void> endCall() async {
    if (_endCallInProgress) return;
    if (state == null || state!.state == CallState.ended) return;

    _endCallInProgress = true;
    debugPrint('📴 Hanging up / ending call');
    _timeoutTimer?.cancel();

    if (state != null) {
      final prefix = state!.isVideo ? 'video:' : 'audio:';
      if (_roomId != null && _roomId!.isNotEmpty) {
        _emitSafely('${prefix}leaveCall', {
          'roomId': _roomId,
        });
      }

      final duration = _callStartTime != null
          ? DateTime.now().difference(_callStartTime!).inSeconds
          : 0;

      String callStatus = 'missed';
      if (duration > 0) {
        callStatus = 'answered';
      } else if (state!.state == CallState.connecting ||
          state!.state == CallState.ringing) {
        callStatus = 'cancelled';
      }

      final logUserId = state!.userId;
      final logUserName = state!.userName;
      final logUserPhoto = state!.userPhoto;
      final logCallType = state!.isVideo ? 'video' : 'audio';
      final logIsOutgoing = state!.direction == CallDirection.outgoing;

      _updateCallState(CallState.ended);
      
      _saveCallLog(
        userId: logUserId,
        userName: logUserName,
        userPhoto: logUserPhoto,
        callType: logCallType,
        callStatus: callStatus,
        duration: duration,
        isOutgoing: logIsOutgoing,
      ).then((_) {
        debugPrint('✅ Call log stored successfully');
      });
    } else {
      _updateCallState(CallState.ended);
    }

    await _cleanup();
  }

  Future<void> toggleMute() async {
    _isMuted = !_isMuted;
    webrtcService.toggleMic(!_isMuted);
    if (state != null) state = state!.copyWith();
  }

  Future<void> toggleSpeaker() async {
    _isSpeakerOn = !_isSpeakerOn;
    await Helper.setSpeakerphoneOn(_isSpeakerOn);
    if (state != null) state = state!.copyWith();
  }

  Future<void> toggleCamera() async {
    _isCameraOn = !_isCameraOn;
    webrtcService.toggleCamera(_isCameraOn);
    if (state != null) {
      state = state!.copyWith(
        isVideo: _isCameraOn || state!.isVideo,
      );
    }
  }

  Future<void> switchCamera() async {
    await webrtcService.switchCamera();
  }

  Future<String> _getToken() async {
    if (_authToken.isNotEmpty) return _authToken;
    return await SaveValues().getString(AppPreferenceHelper.AUTH_TOKEN) ?? '';
  }

  Future<void> _saveCallLog({
    required String userId,
    required String userName,
    required String userPhoto,
    required String callType,
    required String callStatus,
    required int duration,
    required bool isOutgoing,
  }) async {
    try {
      final token = await _getToken();

      if (token.isNotEmpty) {
        final chatId = await getOrCreateChatId(userId);
        final now = DateTime.now();

        try {
          await http.post(
            Uri.parse('$_kBaseUrl/call/log'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'receiver': userId,
              'chat': chatId,
              'status': callStatus,
              'type': callType,
              'duration': duration,
              'startedAt': now.toIso8601String(),
              'endedAt': now.add(Duration(seconds: duration)).toIso8601String(),
            }),
          );
        } catch (e) {
          debugPrint('⚠️ Backend call log error: $e');
        }

        final content = _getCallEventText(
          callType,
          callStatus,
          duration,
          isOutgoing,
        );
        try {
          await http.post(
            Uri.parse('$_kBaseUrl/message'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'chatId': chatId,
              'contentType': 'call',
              'content': content,
              'isCallEvent': true,
              'callType': callType,
              'callStatus': callStatus,
              'callDuration': duration,
            }),
          );
        } catch (e) {
          debugPrint('⚠️ Call message save error: $e');
        }
      }

      await _saveToHive(
        userId: userId,
        userName: userName,
        userPhoto: userPhoto,
        callType: callType,
        callStatus: callStatus,
        duration: duration,
        isOutgoing: isOutgoing,
      );
    } catch (e) {
      debugPrint('❌ Error saving call log: $e');
    }
  }

  Future<void> _saveToHive({
    required String userId,
    required String userName,
    required String userPhoto,
    required String callType,
    required String callStatus,
    required int duration,
    required bool isOutgoing,
  }) async {
    try {
      final box = await Hive.openBox<CallLog>('call_logs');
      final callLog = CallLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        callerId: userId,
        callerName: userName,
        callerPhoto: userPhoto,
        callType: callType == 'video' ? CallType.video : CallType.audio,
        callStatus: callStatus == 'missed'
            ? CallStatus.missed
            : (isOutgoing ? CallStatus.outgoing : CallStatus.incoming),
        timestamp: DateTime.now(),
        duration: duration,
      );
      await box.add(callLog);
    } catch (e) {
      debugPrint('❌ Hive save error: $e');
    }
  }

  Future<String?> getOrCreateChatId(String userId) async {
    try {
      final chatBox = await Hive.openBox<ChatListItemHive>('chats');
      for (var chat in chatBox.values) {
        if (chat.userId == userId) return chat.id;
      }

      final token = await _getToken();
      if (token.isEmpty) return null;

      final response = await http.post(
        Uri.parse('$_kBaseUrl/chat'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'userId': userId}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['_id'] as String? ??
            (data['chat'] as Map?)?['_id'] as String?;
      }
      return null;
    } catch (e) {
      debugPrint('❌ getOrCreateChatId error: $e');
      return null;
    }
  }

  void _emitSafely(String event, Map<String, dynamic> data) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit(event, data);
      debugPrint('📡 Emitted "$event"');
    } else {
      debugPrint('⚠️ Cannot emit "$event" — socket disconnected');
    }
  }

  void _updateCallState(CallState newState) {
    if (state == null) return;
    if (state!.state == newState) return;
    state = state!.copyWith(state: newState);
  }

  void _startTimer() {
    _callDuration = 0;
    _callTimer?.cancel();
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isDisposed) {
        timer.cancel();
        return;
      }
      _callDuration++;
    });
  }

  Future<void> _cleanup() async {
    _isDisposed = true;
    _callTimer?.cancel();
    _timeoutTimer?.cancel();
    _callDuration = 0;
    _callStartTime = null;
    _acceptInProgress = false;
    _endCallInProgress = false;
    _roomId = null;

    webrtcService.dispose();

    _updateCallState(CallState.ended);
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) state = null;
  }

  String _getCallEventText(
    String type,
    String status,
    int duration,
    bool isOutgoing,
  ) {
    final t = type == 'video' ? 'Video call' : 'Voice call';
    if (status == 'missed') return isOutgoing ? 'Cancelled $t' : 'Missed $t';
    if (status == 'cancelled') return 'Cancelled $t';
    if (status == 'answered' && duration > 0) {
      return isOutgoing
          ? 'Outgoing $t - ${_formatDuration(duration)}'
          : 'Incoming $t - ${_formatDuration(duration)}';
    }
    return isOutgoing ? 'Outgoing $t' : 'Incoming $t';
  }

  String _formatDuration(int seconds) {
    if (seconds == 0) return '0s';
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) return '${h}h ${m}m ${s}s';
    if (m > 0) return '${m}m ${s}s';
    return '${s}s';
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    _timeoutTimer?.cancel();
    _socketListenersAttached = false;
    webrtcService.dispose();
    super.dispose();
  }
}

final callStateProvider = StateNotifierProvider<CallStateNotifier, CallInfo?>(
  (ref) => CallStateNotifier(),
);

final isCallScreenVisibleProvider = StateProvider<bool>((ref) => false);

final callTimerProvider = StreamProvider<int>((ref) {
  final notifier = ref.watch(callStateProvider.notifier);
  return Stream.periodic(
    const Duration(seconds: 1),
    (_) => notifier.callDuration,
  );
});
