import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

class DocumentPreviewScreen extends StatefulWidget {
  final File file;

  const DocumentPreviewScreen({super.key, required this.file});

  @override
  State<DocumentPreviewScreen> createState() => _DocumentPreviewScreenState();
}

class _DocumentPreviewScreenState extends State<DocumentPreviewScreen> {
  final TextEditingController _captionController = TextEditingController();
  File? _localFileCopy;

  @override
  void initState() {
    super.initState();
    _prepareFile();
  }

  // Copy file to app directory to ensure it's readable
  Future<void> _prepareFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final localFile = File('${dir.path}/${widget.file.path.split('/').last}');
    if (!await localFile.exists()) {
      await widget.file.copy(localFile.path);
    }
    setState(() {
      _localFileCopy = localFile;
    });
  }

  String get fileName => widget.file.path.split('/').last;

  String _formatSize(int bytes) {
    if (bytes < 1024) return "$bytes B";
    if (bytes < 1024 * 1024) return "${(bytes / 1024).toStringAsFixed(1)} KB";
    return "${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB";
  }

  String get fileExtension => widget.file.path.split('.').last.toLowerCase();

  bool get _isPdf => fileExtension == 'pdf';

  @override
  Widget build(BuildContext context) {
    final size = widget.file.lengthSync();

    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: BackButton(color: Colors.white),
          title: const Text(
            "Preview Document",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Column(
          children: [
            // 📄 DOCUMENT PREVIEW
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: _localFileCopy == null
                    ? const Center(child: CircularProgressIndicator())
                    : GestureDetector(
                  onTap: () async {
                    if (_localFileCopy != null) {
                      await OpenFilex.open(_localFileCopy!.path);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isPdf
                              ? Icons.picture_as_pdf
                              : Icons.insert_drive_file,
                          size: 40,
                          color: Colors.redAccent,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fileName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatSize(size),
                                style: const TextStyle(
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _isPdf ? "PDF Document" : "File Document",
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.open_in_new,
                          color: Colors.white70,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _captionController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "Add a caption…",
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.green),
                    onPressed: () {
                      Navigator.pop(
                        context,
                        _captionController.text.trim(),
                      );
                    },
                  ),
                ],
              ),
            ),


          ],
        ),
      ),
    );
  }
}