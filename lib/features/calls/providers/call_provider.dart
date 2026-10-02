import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../chat/general/services/socket_services/socket_services.dart';
import '../../../../utilities/database/save_values.dart';
import '../../../../utilities/services/app_pref_helper.dart';

// ─────────────────────────────────────────────────────────────────────────────
// NOTE: This file has been updated for the LiveKit migration.
//
// REMOVED (WebRTC-only, no longer exist in SocketService):
//   • signalData parameter from callUser()
//   • SocketService().answerCall()
//   • SocketService().sendIceCandidate()
//
// The old WebRTCService is no longer used here. All media is handled by
// LiveKitCallManager via call_state_provider.dart (CallStateNotifier).
// This file now only handles the simple ring/reject/end signaling flow
// for the outgoing-call ringing screen, before the call is accepted.
// ─────────────────────────────────────────────────────────────────────────────

/// The different states a call can be in
enum CallStatus {
  idle, // No call happening
  ringing, // Someone is calling YOU
  calling, // YOU are calling someone else
  connected, // You are talking
  ended, // Call finished
}

/// Data package for the current call
class CallState {
  final CallStatus status;
  final String? remoteUserId;
  final String? remoteUserName;
  final bool isVideo;
  final String? callId;

  CallState({
    this.status = CallStatus.idle,
    this.remoteUserId,
    this.remoteUserName,
    this.isVideo = false,
    this.callId,
  });

  CallState copyWith({
    CallStatus? status,
    String? remoteUserId,
    String? remoteUserName,
    bool? isVideo,
    String? callId,
  }) {
    return CallState(
      status: status ?? this.status,
      remoteUserId: remoteUserId ?? this.remoteUserId,
      remoteUserName: remoteUserName ?? this.remoteUserName,
      isVideo: isVideo ?? this.isVideo,
      callId: callId ?? this.callId,
    );
  }
}

/// CallNotifier — lightweight signaling-only notifier.
/// All media (audio/video) is managed by CallStateNotifier + LiveKitCallManager.
class CallNotifier extends StateNotifier<CallState> {
  final SaveValues _saveValues = SaveValues();

  CallNotifier() : super(CallState()) {
    print('📞 CallNotifier created');
  }

  @override
  set state(CallState value) {
    print('📊 Call state changing: ${super.state.status} -> ${value.status}');
    super.state = value;
  }

  /// Called by the global socket listener when an incoming call arrives.
  /// The actual LiveKit connection is done in CallStateNotifier.acceptCall().
  void handleIncomingCall({
    required String callerId,
    required String callerName,
    required bool isVideo,
    required String callId,
  }) {
    state = state.copyWith(
      status: CallStatus.ringing,
      remoteUserId: callerId,
      remoteUserName: callerName,
      isVideo: isVideo,
      callId: callId,
    );
  }

  /// Signal the server that we are calling [targetId].
  /// LiveKit connection is handled BEFORE this is called (in CallStateNotifier).
  Future<void> makeCall(
    String targetId,
    String targetName,
    bool isVideo,
    String callId,
  ) async {
    print('📞 makeCall – target: $targetName, callId: $callId');

    state = state.copyWith(
      status: CallStatus.calling,
      remoteUserId: targetId,
      remoteUserName: targetName,
      isVideo: isVideo,
      callId: callId,
    );

    final myUserId = await _saveValues.getString(AppPreferenceHelper.ID) ?? '';
    final myName =
        await _saveValues.getString(AppPreferenceHelper.FIRST_NAME) ??
        'Unknown';

    // FIX: callUser() now takes myUserId + callId instead of signalData.
    // signalData / answerCall / sendIceCandidate have been removed from
    // SocketService because LiveKit handles all media negotiation itself.
    if (SocketService().isConnected) {
      SocketService().callUser(
        userToCallId: targetId,
        myUserId: myUserId,
        myName: myName,
        isVideo: isVideo,
        callId: callId,
      );
    } else {
      print('❌ Cannot emit call user – socket not connected');
    }
  }

  /// Hang up / cancel the outgoing ring.
  void endCall() {
    print('📞 endCall() – resetting call state');
    if (state.remoteUserId != null && SocketService().isConnected) {
      SocketService().endCall(toUserId: state.remoteUserId!);
    }
    state = CallState();
  }
}

// Provider
final callProvider = StateNotifierProvider<CallNotifier, CallState>((ref) {
  return CallNotifier();
});
