import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:qik_talk/features/chat/general/model/chat_history_model.dart';
import 'package:qik_talk/utilities/services/media_cache_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DocumentBubble
//
// 3-state document bubble:
//
//  State 1 — NOT DOWNLOADED
//    • Document icon + file name + extension label
//    • Green download button on the right
//    • Tap anywhere → start download
//
//  State 2 — DOWNLOADING
//    • Circular progress spinner + × to cancel
//    • Linear progress bar + percentage label below the file row
//
//  State 3 — DOWNLOADED
//    • Open icon replaces download button
//    • Tap anywhere → open with OpenFilex
//    • Always opens from local file — works offline
//    • "Failed to open" replaced with a specific error per failure type
// ─────────────────────────────────────────────────────────────────────────────

enum _DocState { notDownloaded, downloading, downloaded }

class DocumentBubble extends StatefulWidget {
  final String name;
  final String text;
  final bool isMe;
  final bool isRead;
  final String timestamp;
  final String? documentUrl;
  final MessageStatus? status;

  const DocumentBubble({
    super.key,
    required this.name,
    required this.text,
    required this.isMe,
    required this.isRead,
    required this.timestamp,
    this.documentUrl,
    this.status,
  });

  @override
  State<DocumentBubble> createState() => _DocumentBubbleState();
}

class _DocumentBubbleState extends State<DocumentBubble> {
  _DocState _docState = _DocState.notDownloaded;
  double _downloadProgress = 0.0;
  String? _localPath;
  CancelToken? _cancelToken;
  int _fileSize = 0; // ✅ File size in bytes

  // ── Init ─────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _checkCache();
    _getFileSize(); // ✅ Get file size
  }

  // ✅ Get file size from local file or URL
  Future<void> _getFileSize() async {
    try {
      if (widget.documentUrl == null) return;

      // Check local file first
      if (!widget.documentUrl!.startsWith('http')) {
        final file = File(widget.documentUrl!);
        if (file.existsSync()) {
          final size = await file.length();
          if (mounted) {
            setState(() => _fileSize = size);
          }
        }
      } else {
        // For remote files, try cache first, then a lightweight HEAD request so
        // the size is visible before download (WhatsApp-style).
        final cached = MediaCacheService().getCachedPath(widget.documentUrl!);
        if (cached != null && File(cached).existsSync()) {
          final size = await File(cached).length();
          if (mounted) setState(() => _fileSize = size);
          return;
        }
        final response = await Dio().head(widget.documentUrl!);
        final length = int.tryParse(
          response.headers.value(Headers.contentLengthHeader) ?? '',
        );
        if (length != null && length > 0 && mounted) {
          setState(() => _fileSize = length);
        }
      }
    } catch (_) {
      // Size fetch failed, keep default
    }
  }

  // ✅ Format file size to human-readable format
  /// Extract real filename from URL if current name is generic
  String get _resolvedName {
    if (widget.name.isNotEmpty &&
        widget.name.toLowerCase() != 'attachment' &&
        widget.name.toLowerCase() != 'document') {
      return widget.name;
    }
    // Try to extract from URL
    if (widget.documentUrl != null && widget.documentUrl!.isNotEmpty) {
      try {
        final uri = Uri.parse(widget.documentUrl!);
        final segments = uri.pathSegments;
        if (segments.isNotEmpty) {
          final last = segments.last;
          if (last.isNotEmpty && last.contains('.')) return last;
        }
      } catch (_) {}
    }
    return widget.name.isNotEmpty ? widget.name : 'document';
  }

  String _formatFileSize(int bytes) {
    if (bytes == 0) return 'calculating...';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  // ✅ Format timestamp to display date and time
  String _formatDateTime(String isoTime) {
    try {
      final date = DateTime.parse(isoTime).toLocal();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final messageDate = DateTime(date.year, date.month, date.day);

      String dateStr;
      if (messageDate == today) {
        dateStr = 'Today';
      } else if (messageDate == yesterday) {
        dateStr = 'Yesterday';
      } else {
        dateStr = '${date.day}/${date.month}/${date.year}';
      }

      final timeStr =
          '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      return '$dateStr · $timeStr';
    } catch (_) {
      return 'Unknown';
    }
  }

  @override
  void dispose() {
    _cancelToken?.cancel('widget disposed');
    super.dispose();
  }

  // ── Cache check ───────────────────────────────────────────────────────────────

  Future<void> _checkCache() async {
    // 1. Local path (document just sent by this user — already on device)
    if (widget.documentUrl != null && !widget.documentUrl!.startsWith('http')) {
      if (File(widget.documentUrl!).existsSync()) {
        if (mounted)
          setState(() {
            _localPath = widget.documentUrl;
            _docState = _DocState.downloaded;
          });
        return;
      }
    }

    // 2. MediaCacheService persistent cache
    if (widget.documentUrl != null) {
      final cached = MediaCacheService().getCachedPath(widget.documentUrl!);
      if (cached != null && File(cached).existsSync()) {
        if (mounted)
          setState(() {
            _localPath = cached;
            _docState = _DocState.downloaded;
          });
        return;
      }
    }

    // 3. Our own documents-directory file (from a previous download in this bubble)
    final savedPath = await _buildSavePath();
    if (File(savedPath).existsSync()) {
      if (mounted)
        setState(() {
          _localPath = savedPath;
          _docState = _DocState.downloaded;
        });
      return;
    }

    // Not found anywhere — show download button
    if (mounted) setState(() => _docState = _DocState.notDownloaded);
  }

  // ── Download ──────────────────────────────────────────────────────────────────

  Future<void> _startDownload() async {
    if (widget.documentUrl == null) return;
    if (_docState == _DocState.downloading) return;

    if (mounted)
      setState(() {
        _docState = _DocState.downloading;
        _downloadProgress = 0.0;
      });

    try {
      final savePath = await _buildSavePath();
      _cancelToken = CancelToken();

      // Fresh Dio instance — no global interceptors that could inject auth
      // headers or break the public CDN URL
      final dio = Dio();

      await dio.download(
        widget.documentUrl!,
        savePath,
        cancelToken: _cancelToken,
        onReceiveProgress: (received, total) {
          if (!mounted) return;
          if (total > 0) setState(() => _downloadProgress = received / total);
        },
        options: Options(
          receiveTimeout: const Duration(minutes: 5),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      if (!mounted) return;

      setState(() {
        _localPath = savePath;
        _docState = _DocState.downloaded;
      });

      // Auto-open immediately after download
      await _openFile(savePath);
    } on DioException catch (e) {
      if (!mounted) return;
      if (e.type == DioExceptionType.cancel) {
        // User cancelled — Dio removes the partial file automatically
        setState(() => _docState = _DocState.notDownloaded);
      } else {
        setState(() => _docState = _DocState.notDownloaded);
        _showError(_friendlyDioError(e));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _docState = _DocState.notDownloaded);
      _showError('Download failed. Tap to retry.');
      debugPrint('❌ Document download error: $e');
    }
  }

  void _cancelDownload() {
    _cancelToken?.cancel('user cancelled');
  }

  // ── Open file ─────────────────────────────────────────────────────────────────

  Future<void> _openFile(String path) async {
    try {
      final file = File(path);
      if (!file.existsSync()) {
        _showError('File not found. Tap to re-download.');
        if (mounted) setState(() => _docState = _DocState.notDownloaded);
        return;
      }

      final result = await OpenFilex.open(path);

      switch (result.type) {
        case ResultType.done:
          break; // opened successfully — nothing to show
        case ResultType.noAppToOpen:
          _showError(
            'No app installed can open this file type.\n'
            'Try installing a PDF reader or file manager.',
          );
          break;
        case ResultType.fileNotFound:
          _showError('File not found on device. Tap to re-download.');
          if (mounted) setState(() => _docState = _DocState.notDownloaded);
          break;
        case ResultType.permissionDenied:
          _showError(
            'Storage permission denied.\n'
            'Go to Settings → Apps → Qiktalk → Permissions.',
          );
          break;
        case ResultType.error:
          _showError(
            result.message.isNotEmpty ? result.message : 'Could not open file.',
          );
          break;
      }
    } catch (e) {
      debugPrint('❌ OpenFilex error: $e');
      _showError('Could not open file: ${e.toString()}');
    }
  }

  // ── Tap handler ───────────────────────────────────────────────────────────────

  void _onTap() {
    switch (_docState) {
      case _DocState.notDownloaded:
        _startDownload();
        break;
      case _DocState.downloading:
        _cancelDownload();
        break;
      case _DocState.downloaded:
        if (_localPath != null) _openFile(_localPath!);
        break;
    }
  }

  Widget _buildStatusTicks(Color subtleColor) {
    if (widget.status == MessageStatus.sending) {
      return Icon(Icons.access_time_rounded, size: 12, color: subtleColor);
    }
    if (widget.status == MessageStatus.failed) {
      return const Icon(Icons.error_outline, size: 13, color: Colors.redAccent);
    }
    if (widget.status == MessageStatus.read || widget.isRead) {
      return _doubleTick(color: const Color(0xFF53BDEB));
    }
    if (widget.status == MessageStatus.delivered) {
      return _doubleTick(color: subtleColor);
    }
    // ✅ Explicit case for sent status (WhatsApp style)
    if (widget.status == MessageStatus.sent) {
      return Icon(Icons.check, size: 13, color: subtleColor);
    }
    // Fallback: Single grey tick
    return Icon(Icons.check, size: 13, color: subtleColor);
  }

  Widget _doubleTick({required Color color}) {
    return SizedBox(
      width: 18,
      height: 13,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Positioned(left: 0, child: Icon(Icons.check, size: 13, color: color)),
          Positioned(left: 5, child: Icon(Icons.check, size: 13, color: color)),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────

  Future<String> _buildSavePath() async {
    final dir = await getApplicationDocumentsDirectory();
    final docsDir = Directory(p.join(dir.path, 'qiktalk_documents'));
    if (!docsDir.existsSync()) docsDir.createSync(recursive: true);

    // Sanitise filename — keep extension, replace unsafe chars
    final safeName = _resolvedName
        .replaceAll(RegExp(r'[^\w\.\-]'), '_')
        .replaceAll(RegExp(r'_+'), '_');

    return p.join(docsDir.path, safeName);
  }

  String _friendlyDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timed out. Check your internet.';
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode;
        if (code == 403 || code == 401) return 'Access denied (error $code).';
        if (code == 404) return 'File not found on server (404).';
        return 'Server error ($code). Tap to retry.';
      case DioExceptionType.connectionError:
        return 'No internet connection.';
      default:
        return 'Download failed. Check your connection and tap to retry.';
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  // Returns a colour that matches the file type — PDF red, Word blue, etc.
  Color _fileIconColor() {
    final ext = p.extension(_resolvedName).toLowerCase();
    switch (ext) {
      case '.pdf':
        return Colors.red.shade400;
      case '.doc':
      case '.docx':
        return Colors.blue.shade400;
      case '.xls':
      case '.xlsx':
        return Colors.green.shade400;
      case '.ppt':
      case '.pptx':
        return Colors.orange.shade400;
      case '.zip':
      case '.rar':
      case '.7z':
        return Colors.yellow.shade600;
      case '.mp3':
      case '.wav':
      case '.aac':
        return Colors.purple.shade400;
      default:
        return Colors.white70;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Adaptive bubble colors
    final Color bubbleBg = isDark
        ? (widget.isMe ? HexColor('#1B1B1B') : HexColor('#232323'))
        : Colors.white;
    final Color textColor = isDark
        ? Colors.white
        : (widget.isMe ? const Color(0xFF2A1A0A) : const Color(0xFF1A1008));
    final Color subtleColor = isDark ? Colors.white54 : const Color(0xFF8A7060);
    final Color progressBg = isDark ? Colors.white12 : Colors.black12;
    const List<BoxShadow> shadows = [];

    return Align(
      alignment: widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _onTap,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.65,
          ),
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
          margin: const EdgeInsets.symmetric(vertical: 3),
          decoration: BoxDecoration(
            color: bubbleBg,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(widget.isMe ? 18 : 4),
              bottomRight: Radius.circular(widget.isMe ? 4 : 18),
            ),
            boxShadow: shadows,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── File info row ──────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Colour-coded file icon
                  Icon(
                    Icons.insert_drive_file_rounded,
                    color: _fileIconColor(),
                    size: 34,
                  ),
                  const SizedBox(width: 10),

                  // File name + extension label
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _resolvedName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 3),
                        // ✅ File type and size
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: widget.isMe
                                    ? HexColor('#FB8830').withOpacity(0.2)
                                    : HexColor('#1A7F4B').withOpacity(0.2),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Text(
                                p
                                    .extension(_resolvedName)
                                    .toUpperCase()
                                    .replaceFirst('.', '')
                                    .replaceAll('_', ' '),
                                style: TextStyle(
                                  color: widget.isMe
                                      ? HexColor('#FB8830')
                                      : HexColor('#1A7F4B'),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            // ✅ File size
                            Text(
                              _formatFileSize(_fileSize),
                              style: TextStyle(
                                color: subtleColor,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // ── Action button (state-dependent) ────────────────────
                  _buildActionButton(),
                ],
              ),

              // ── Progress bar — only during download ────────────────────
              if (_docState == _DocState.downloading) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _downloadProgress > 0 ? _downloadProgress : null,
                    minHeight: 3,
                    backgroundColor: progressBg,
                    color: HexColor('#1A7F4B'),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _downloadProgress > 0
                      ? 'Downloading… ${(_downloadProgress * 100).toStringAsFixed(0)}%'
                      : 'Starting download…',
                  style: TextStyle(color: subtleColor, fontSize: 11),
                ),
              ],

              // ── Caption text (if any) ──────────────────────────────────
              if (widget.text.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  widget.text,
                  style: TextStyle(color: textColor, fontSize: 14, height: 1.4),
                ),
              ],

              const SizedBox(height: 6),

              // ── Timestamp + ticks ──────────────────────────────────────
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatDateTime(widget.timestamp),
                      style: TextStyle(
                        letterSpacing: 0.2,
                        color: subtleColor,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 3),
                    if (widget.isMe) _buildStatusTicks(subtleColor),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Action button ─────────────────────────────────────────────────────────────

  Widget _buildActionButton() {
    switch (_docState) {
      // Green download arrow
      case _DocState.notDownloaded:
        return Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: HexColor('#1A7F4B'),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.download_rounded,
            color: Colors.white,
            size: 18,
          ),
        );

      // Spinner + × cancel
      case _DocState.downloading:
        return SizedBox(
          width: 34,
          height: 34,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: _downloadProgress > 0 ? _downloadProgress : null,
                strokeWidth: 2.5,
                color: HexColor('#1A7F4B'),
                backgroundColor: Colors.white12,
              ),
              const Icon(Icons.close, color: Colors.white54, size: 14),
            ],
          ),
        );

      // Open icon
      case _DocState.downloaded:
        return Container(
          width: 34,
          height: 34,
          decoration: const BoxDecoration(
            color: Colors.white12,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.open_in_new_rounded,
            color: Colors.white70,
            size: 18,
          ),
        );
    }
  }
}
