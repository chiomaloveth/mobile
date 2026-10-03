import 'package:flutter_webrtc/flutter_webrtc.dart';

class WebRTCService {
  RTCPeerConnection? _peerConnection;

  // 1. SIGNALING CALLBACKS
  Function(String targetUserId, dynamic signal)? onSendSignal;
  Function(String targetUserId, dynamic candidate)? onSendCandidate;
  Function()? onRemoteStreamReady;

  String? currentTargetUserId; // The person we are talking to

  // 2. The Renderers (To show video on the UI)
  final RTCVideoRenderer localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer remoteRenderer = RTCVideoRenderer();

  // 3. The Local Stream (Your camera and mic)
  MediaStream? _localStream;

  Future<void> initRenderers() async {
    try {
      print('🎥 Initializing WebRTC renderers...');
      await localRenderer.initialize();
      await remoteRenderer.initialize();
      print('✅ WebRTC renderers initialized');
    } catch (e) {
      print('❌ Error initializing renderers: $e');
      rethrow;
    }
  }

  Future<void> openUserMedia(bool isVideo) async {
    try {
      print('🎙️ Opening user media (isVideo: $isVideo)...');

      final Map<String, dynamic> constraints = {
        'audio': true,
        'video': isVideo ? {'facingMode': 'user'} : false,
      };

      _localStream = await navigator.mediaDevices.getUserMedia(constraints);
      localRenderer.srcObject = _localStream;
      print('✅ User media opened successfully');
    } catch (e) {
      print('❌ Error opening user media: $e');
      rethrow;
    }
  }

  /// Step 3: Create the Peer Connection using dynamic ICE servers
  Future<void> setupPeerConnection(List<dynamic>? servers) async {
    final Map<String, dynamic> configuration = {
      'iceServers': (servers != null && servers.isNotEmpty)
          ? servers.map((item) => Map<String, dynamic>.from(item as Map)).toList()
          : [
              {'urls': 'stun:stun.l.google.com:19302'},
            ],
      'sdpSemantics': 'unified-plan',
    };

    print('🔌 Setting up PeerConnection with config: $configuration');
    _peerConnection = await createPeerConnection(configuration);

    // Add local stream to the connection so the other person can see/hear you
    if (_localStream != null) {
      for (var track in _localStream!.getTracks()) {
        await _peerConnection?.addTrack(track, _localStream!);
      }
    }

    // Listen for the other person's stream
    _peerConnection?.onTrack = (RTCTrackEvent event) {
      if (event.streams.isNotEmpty) {
        print('📺 Received remote video/audio track');
        remoteRenderer.srcObject = event.streams[0];
        onRemoteStreamReady?.call();
      }
    };

    // Listen for ICE Candidates (Internet address packets)
    _peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
      if (currentTargetUserId != null && onSendCandidate != null) {
        print('📡 Local ICE candidate generated, emitting...');
        onSendCandidate!(currentTargetUserId!, candidate.toMap());
      }
    };
  }

  /// Step 4: Create an Offer (Initiate the call)
  Future<void> createOffer() async {
    if (_peerConnection == null) {
      print('⚠️ PeerConnection is null — cannot create offer');
      return;
    }
    RTCSessionDescription offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);

    if (currentTargetUserId != null && onSendSignal != null) {
      print('📤 Emitting offer to $currentTargetUserId');
      onSendSignal!(currentTargetUserId!, offer.toMap());
    }
  }

  /// Step 5: Handle receiving a signal (Offer or Answer)
  Future<void> handleRemoteSignal(dynamic signal) async {
    if (_peerConnection == null) {
      print('⚠️ PeerConnection is null — cannot handle remote signal');
      return;
    }
    final description = RTCSessionDescription(signal['sdp'], signal['type']);
    await _peerConnection?.setRemoteDescription(description);

    // If it's an offer, we must create an answer
    if (description.type == 'offer') {
      RTCSessionDescription answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);

      if (currentTargetUserId != null && onSendSignal != null) {
        print('📤 Emitting answer to $currentTargetUserId');
        onSendSignal!(currentTargetUserId!, answer.toMap());
      }
    }
  }

  /// Step 6: Handle receiving a candidate
  Future<void> addCandidate(dynamic candidateData) async {
    if (_peerConnection == null) {
      print('⚠️ PeerConnection is null — cannot add candidate');
      return;
    }
    final candidate = RTCIceCandidate(
      candidateData['candidate'],
      candidateData['sdpMid'],
      candidateData['sdpMLineIndex'],
    );
    await _peerConnection?.addCandidate(candidate);
  }

  // Local Controls
  void toggleMic(bool enabled) {
    _localStream?.getAudioTracks().forEach((track) {
      track.enabled = enabled;
    });
    print('🎙️ Mic enabled: $enabled');
  }

  void toggleCamera(bool enabled) {
    _localStream?.getVideoTracks().forEach((track) {
      track.enabled = enabled;
    });
    print('📷 Camera enabled: $enabled');
  }

  Future<void> switchCamera() async {
    if (_localStream != null) {
      for (var track in _localStream!.getVideoTracks()) {
        await Helper.switchCamera(track);
      }
      print('🔄 Camera toggled between front and back');
    }
  }

  void dispose() {
    print('🧹 Disposing WebRTCService');
    localRenderer.srcObject = null;
    remoteRenderer.srcObject = null;
    localRenderer.dispose();
    remoteRenderer.dispose();
    _localStream?.getTracks().forEach((track) => track.stop());
    _localStream?.dispose();
    _peerConnection?.dispose();
  }
}
