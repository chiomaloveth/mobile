import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:just_audio/just_audio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'package:flutter_system_ringtones/flutter_system_ringtones.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';

class ToneSelectionScreen extends StatefulWidget {
  final String title;
  final String note;
  final String currentTone;
  final String soundType; // 'notification', 'ringtone', or 'alarm'
  final Function(String, String) onToneSelected;

  const ToneSelectionScreen({
    super.key,
    required this.title,
    required this.note,
    this.currentTone = 'Default',
    this.soundType = 'notification',
    required this.onToneSelected,
  });

  @override
  State<ToneSelectionScreen> createState() => _ToneSelectionScreenState();
}

class _ToneSelectionScreenState extends State<ToneSelectionScreen> {
  double _volume = 0.75;
  late String _selectedToneUri;
  final ap.AudioPlayer _apPlayer = ap.AudioPlayer();
  final AudioPlayer _justPlayer = AudioPlayer();
  List<Ringtone> _systemRingtones = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedToneUri = widget.currentTone;
    _initializeVolume();
    _fetchSystemTones();
  }

  Future<void> _fetchSystemTones() async {
    try {
      final isIOS = defaultTargetPlatform == TargetPlatform.iOS;

      if (isIOS) {
        _loadBundledTones();
      } else {
        List<Ringtone> ringtones = [];
        if (widget.soundType == 'ringtone') {
          ringtones = await FlutterSystemRingtones.getRingtoneSounds();
        } else if (widget.soundType == 'alarm') {
          ringtones = await FlutterSystemRingtones.getAlarmSounds();
        } else {
          ringtones = await FlutterSystemRingtones.getNotificationSounds();
        }
        
        if (mounted) {
          setState(() {
            _systemRingtones = ringtones;
            _isLoading = false;
          });

          if (_systemRingtones.isEmpty) {
            _loadBundledTones();
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching ringtones: $e');
      if (mounted) {
        _loadBundledTones();
      }
    }
  }

  void _loadBundledTones() {
    setState(() {
      _systemRingtones = [
        Ringtone(
          id: 'incoming',
          title: 'Incoming Message',
          uri: 'asset:images/incoming_message.mp3',
        ),
        Ringtone(
          id: 'outgoing',
          title: 'Outgoing Message',
          uri: 'asset:images/outgoing_message.mp3',
        ),
      ];
      _isLoading = false;
    });
  }

  Future<void> _requestPermissionAndRetry() async {
    setState(() => _isLoading = true);
    await _fetchSystemTones();
  }

  bool _isPickerActive = false;
  static bool _globalPickerLock = false;

  Future<void> _pickFromFile() async {
    if (_isPickerActive || _globalPickerLock) {
      debugPrint('Picker lock active, ignoring request');
      return;
    }

    try {
      _globalPickerLock = true;
      setState(() => _isPickerActive = true);

      await Future.delayed(const Duration(milliseconds: 300));

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        final fileName = result.files.single.name;

        setState(() {
          _selectedToneUri = filePath;
        });

        _playPreview();
        widget.onToneSelected(fileName, filePath);
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
      if (mounted) {
        String errorMessage = e.toString();
        if (errorMessage.contains('multiple_request')) {
          errorMessage =
              'A file picker is already open or was recently closed. Please try again in a moment.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } finally {
      _globalPickerLock = false;
      if (mounted) {
        setState(() => _isPickerActive = false);
      }
    }
  }

  Future<void> _initializeVolume() async {
    try {
      final currentVolume = await FlutterVolumeController.getVolume();
      if (currentVolume != null) {
        setState(() {
          _volume = currentVolume;
        });
      }

      FlutterVolumeController.addListener((volume) {
        if (mounted) {
          setState(() {
            _volume = volume;
          });
        }
      });
    } catch (e) {
      debugPrint('Error initializing volume: $e');
    }
  }

  @override
  void dispose() {
    FlutterVolumeController.removeListener();
    _apPlayer.dispose();
    _justPlayer.dispose();
    super.dispose();
  }

  Future<void> _playPreview() async {
    try {
      debugPrint('[NOTIF_TRACK] Previewing sound: $_selectedToneUri');
      
      // Stop all currently playing sounds
      await _apPlayer.stop();
      await _justPlayer.stop();
      try {
        await FlutterRingtonePlayer().stop();
      } catch (_) {}

      if (_selectedToneUri == 'None (Silent)') return;

      if (_selectedToneUri == 'Default') {
        await FlutterRingtonePlayer().playNotification();
      } else if (_selectedToneUri.startsWith('ios:')) {
        final soundId = int.tryParse(_selectedToneUri.replaceFirst('ios:', ''));
        if (soundId != null) {
          await FlutterRingtonePlayer().play(
            ios: IosSound(soundId),
            volume: 1.0,
            looping: false,
          );
        }
      } else if (_selectedToneUri.startsWith('asset:')) {
        final assetPath = _selectedToneUri.replaceFirst('asset:', '');
        await _apPlayer.play(ap.AssetSource(assetPath));
      } else if (_selectedToneUri.startsWith('content://') || _selectedToneUri.contains('ringtone')) {
        // just_audio is superior for system/content URIs on Android
        await _justPlayer.setAudioSource(AudioSource.uri(Uri.parse(_selectedToneUri)));
        await _justPlayer.play();
      } else if (_selectedToneUri.startsWith('/')) {
        await _apPlayer.play(ap.DeviceFileSource(_selectedToneUri));
      } else {
        // Fallback to UrlSource or system default if URI is ambiguous
        try {
          await _apPlayer.play(ap.UrlSource(_selectedToneUri));
        } catch (e) {
          debugPrint('[NOTIF_TRACK] Ambiguous URI, trying just_audio: $e');
          await _justPlayer.setAudioSource(AudioSource.uri(Uri.parse(_selectedToneUri)));
          await _justPlayer.play();
        }
      }
    } catch (e) {
      debugPrint('[NOTIF_TRACK] ❌ Error playing preview (URI: $_selectedToneUri): $e');
      try {
        await FlutterRingtonePlayer().playNotification();
      } catch (innerE) {
        debugPrint('[NOTIF_TRACK] Final fallback also failed: $innerE');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // ── Colours ──────────────────────────────────────────────────────────────
    final scaffoldColor = AppTheme.scaffoldBg(isDark);
    final cardColor =
        isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5EEE4);
    final volumeColor = const Color(0xFFFFB800);
    final volumeLabelColor = isDark ? Colors.white38 : const Color(0xFF9E8E7E);
    final primaryTextColor = AppTheme.textPrimary(isDark);
    final secondaryTextColor = AppTheme.textSecondary(isDark);
    final dividerColor =
        isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFD9CFC4);
    final sliderInactive = isDark ? Colors.white10 : const Color(0xFFD9CFC4);

    // ── AppBar gradient ───────────────────────────────────────────────────────
    final appBarGradient = isDark
        ? [const Color(0xFF171516), const Color(0xFF3A1D07)]
        : [const Color(0xFFFAF5F0), const Color(0xFFF0E8DE)];
    final appBarTextColor = isDark ? Colors.white : const Color(0xFF1A1008);
    final appBarIconColor = isDark ? Colors.white : const Color(0xFF1A1008);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: scaffoldColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleSpacing: 0,
          centerTitle: false,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
                isDark ? Brightness.light : Brightness.dark,
            statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: appBarGradient,
              ),
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: appBarIconColor),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            widget.title,
            style: GoogleFonts.poppins(
              color: appBarTextColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Column(
          children: [
            // ── Volume card ─────────────────────────────────────────────────
            Container(
              margin: const EdgeInsets.all(20),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.volume_up_outlined,
                            color: volumeLabelColor,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Volume',
                            style: GoogleFonts.poppins(
                              color: volumeLabelColor,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${(_volume * 100).toInt()}%',
                        style: GoogleFonts.poppins(
                          color: primaryTextColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: volumeColor,
                      inactiveTrackColor: sliderInactive,
                      thumbColor: Colors.white,
                      overlayColor: volumeColor.withOpacity(0.2),
                      trackHeight: 6,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 8,
                      ),
                    ),
                    child: Slider(
                      value: _volume,
                      onChanged: (val) {
                        setState(() {
                          _volume = val;
                        });
                        FlutterVolumeController.setVolume(val);
                      },
                    ),
                  ),
                ],
              ),
            ),

            // ── Tone list ───────────────────────────────────────────────────
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: volumeColor,
                        ),
                      )
                    : _systemRingtones.isEmpty
                        ? _buildEmptyState(
                            isDark, volumeColor, primaryTextColor,
                            secondaryTextColor)
                        : ListView.separated(
                            itemCount: _systemRingtones.length + 1,
                            padding: const EdgeInsets.all(16),
                            separatorBuilder: (context, index) => Divider(
                              color: dividerColor,
                              height: 1,
                            ),
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                const noneTone = 'None (Silent)';
                                final isSelected =
                                    _selectedToneUri == noneTone;
                                return _buildToneItem(
                                  noneTone,
                                  noneTone,
                                  isSelected,
                                  isDark,
                                  volumeColor,
                                  primaryTextColor,
                                  secondaryTextColor,
                                );
                              }

                              final ringtone = _systemRingtones[index - 1];
                              final isSelected =
                                  _selectedToneUri == ringtone.uri;
                              return _buildToneItem(
                                ringtone.title,
                                ringtone.uri,
                                isSelected,
                                isDark,
                                volumeColor,
                                primaryTextColor,
                                secondaryTextColor,
                              );
                            },
                          ),
              ),
            ),

            // ── Bottom actions ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: _isPickerActive ? null : _pickFromFile,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'Choose from Files',
                        style: GoogleFonts.poppins(
                          color: volumeColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(isDark ? 0.1 : 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.blue
                              .withOpacity(isDark ? 0.2 : 0.15)),
                    ),
                    child: Text(
                      widget.note,
                      style: GoogleFonts.poppins(
                        color: isDark
                            ? Colors.blue
                            : const Color(0xFF1565C0),
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToneItem(
    String title,
    String uri,
    bool isSelected,
    bool isDark,
    Color accentColor,
    Color primaryTextColor,
    Color secondaryTextColor,
  ) {
    return ListTile(
      onTap: () {
        setState(() {
          _selectedToneUri = uri;
        });
        _playPreview();
        widget.onToneSelected(title, uri);
      },
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        Icons.play_arrow_rounded,
        color: isSelected
            ? accentColor
            : (isDark ? Colors.white24 : const Color(0xFFCFC4B5)),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          color: isSelected ? primaryTextColor : secondaryTextColor,
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      trailing: isSelected
          ? Container(
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 16),
            )
          : null,
    );
  }

  Widget _buildEmptyState(
    bool isDark,
    Color accentColor,
    Color primaryTextColor,
    Color secondaryTextColor,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.music_off_outlined,
              size: 48,
              color: isDark ? Colors.white24 : Colors.black12,
            ),
            const SizedBox(height: 16),
            Text(
              'No sounds found',
              style: GoogleFonts.poppins(
                color: primaryTextColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please authorize the app to access your device sounds.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: secondaryTextColor,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _requestPermissionAndRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(
                'Scan for Sounds',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
