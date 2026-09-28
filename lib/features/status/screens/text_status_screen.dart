import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../utilities/services/app_pref_helper.dart';
import '../../../utilities/database/save_values.dart';
import '../../../utilities/constants/app_strings/api_strings.dart';

class AddTextStatusScreen extends StatefulWidget {
  const AddTextStatusScreen({super.key});

  @override
  State<AddTextStatusScreen> createState() => _AddTextStatusScreenState();
}

class _AddTextStatusScreenState extends State<AddTextStatusScreen> {
  final TextEditingController _controller = TextEditingController();

  final List<Color> backgroundColors = [
    Colors.black,
    Colors.deepPurple,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.red,
    const Color(0xFF1A1A2E),
    const Color(0xFF16213E),
    const Color(0xFF0F3460),
    Colors.teal,
    Colors.pink,
    Colors.brown,
  ];

  int selectedColorIndex = 0;
  bool isUploading = false;

  final List<String> _fontStyles = [
    'Classic',
    'Bold',
    'Modern',
    'Handwritten',
    'Typewriter',
  ];
  int _selectedFontIndex = 0;

  TextStyle _getTextStyle() {
    const double size = 28;
    switch (_fontStyles[_selectedFontIndex]) {
      case 'Bold':
        return GoogleFonts.poppins(
          fontSize: size,
          color: Colors.white,
          fontWeight: FontWeight.w900,
        );
      case 'Modern':
        return GoogleFonts.montserrat(
          fontSize: size,
          color: Colors.white,
          fontWeight: FontWeight.w300,
          letterSpacing: 2,
        );
      case 'Handwritten':
        return GoogleFonts.dancingScript(
          fontSize: size,
          color: Colors.white,
          fontWeight: FontWeight.w700,
        );
      case 'Typewriter':
        return GoogleFonts.courierPrime(fontSize: size, color: Colors.white);
      default:
        return GoogleFonts.poppins(
          fontSize: size,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        );
    }
  }

  Future<void> _postTextStatus() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please type something first")),
      );
      return;
    }
    if (isUploading) return;
    setState(() => isUploading = true);

    try {
      final SaveValues saveValues = SaveValues();
      final token = await saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);

      debugPrint("Posting text status: $text");
      debugPrint(
        "Background color: ${backgroundColors[selectedColorIndex].value}",
      );

      final dio = Dio();

      final payload = {
        'mediaType': 'text',
        'caption': text,
        'bgColor': backgroundColors[selectedColorIndex].value.toString(),
      };

      debugPrint("Sending fields: $payload");

      final response = await dio.post(
        ApiStrings.uploadStatus,
        data: payload,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      debugPrint("Text status response: ${response.statusCode}");
      debugPrint("Text status body: ${response.data}");

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Status posted!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } on DioException catch (e) {
      debugPrint("Dio error: ${e.type}");
      debugPrint("Dio response: ${e.response?.statusCode}");
      debugPrint("Dio body: ${e.response?.data}");

      if (!mounted) return;

      final errorMsg =
          e.response?.data?['message'] ?? e.message ?? 'Upload failed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed: $errorMsg"),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      debugPrint("Text status error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => isUploading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColors[selectedColorIndex];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton.icon(
              onPressed: isUploading ? null : _postTextStatus,
              icon: isUploading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send, color: Colors.white, size: 18),
              label: Text(
                isUploading ? "Posting..." : "Post",
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // ── Text input ──
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Theme(
                data: Theme.of(context).copyWith(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  inputDecorationTheme: const InputDecorationTheme(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                  ),
                ),
                child: TextField(
                  controller: _controller,
                  cursorColor: Colors.white,
                  maxLines: null,
                  textAlign: TextAlign.center,
                  style: _getTextStyle(),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    hintText: "Type a status…",
                    hintStyle: TextStyle(color: Colors.white54, fontSize: 24),
                  ),
                ),
              ),
            ),
          ),

          // ── Colour picker ──
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 16,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // ── Font style picker ──
                const Text(
                  "Font style",
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 36,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _fontStyles.length,
                    itemBuilder: (context, index) {
                      final selected = index == _selectedFontIndex;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedFontIndex = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? Colors.white.withOpacity(0.25)
                                : Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selected ? Colors.white : Colors.white30,
                              width: selected ? 1.5 : 1,
                            ),
                          ),
                          child: Text(
                            _fontStyles[index],
                            style: TextStyle(
                              color: selected ? Colors.white : Colors.white60,
                              fontSize: 12,
                              fontWeight: selected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Pick a background",
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 44,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: backgroundColors.length,
                    itemBuilder: (context, index) {
                      final isSelected = index == selectedColorIndex;
                      return GestureDetector(
                        onTap: () => setState(() => selectedColorIndex = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          width: isSelected ? 38 : 30,
                          height: isSelected ? 38 : 30,
                          decoration: BoxDecoration(
                            color: backgroundColors[index],
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.white : Colors.white30,
                              width: isSelected ? 3 : 1.5,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
