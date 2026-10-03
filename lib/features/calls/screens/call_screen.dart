import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:qik_talk/utilities/constants/app_colors.dart';
import 'package:hive_ce/hive.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

import '../../settings/screen/settings_screen.dart';
import '../models/call_log_model.dart';
import '../../chat/single_chat/screens/message_screen.dart';
import '../../../utilities/services/app_pref_helper.dart';
import '../../../utilities/database/save_values.dart';
import '../../../utilities/constants/app_strings/api_strings.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final SaveValues _saveValues = SaveValues();

  List<CallLogItem> _allCalls = [];
  List<CallLogItem> _missedCalls = [];
  List<CallLogItem> _incomingCalls = [];
  List<CallLogItem> _outgoingCalls = [];

  // Search state
  bool isSearchActive = false;
  TextEditingController searchController = TextEditingController();
  List<CallLogItem> _filteredCalls = [];

  bool _isLoading = false;
  String _myUserId = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadUserId();
    _loadCallLogs();

    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = searchController.text.toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _filteredCalls = [];
      } else {
        _filteredCalls = _allCalls.where((call) {
          return call.userName.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  Future<void> _loadUserId() async {
    final userId = await _saveValues.getString(AppPreferenceHelper.ID);
    setState(() {
      _myUserId = userId ?? '';
    });
  }

  /// ✅ Load call logs from Hive ONLY (backend has no GET endpoint)
  Future<void> _loadCallLogs() async {
    // Never block UI — Hive is local so this is instant
    try {
      final box = await Hive.openBox<CallLog>('call_logs');
      final hiveLogs = box.values.toList();

      final callLogs = hiveLogs
          .map((log) => CallLogItem.fromHive(log, _myUserId))
          .toList();

      callLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      if (mounted) {
        setState(() {
          _allCalls = callLogs;
          _missedCalls = callLogs.where((c) => c.status == 'missed').toList();
          _incomingCalls = callLogs
              .where((c) => c.isIncoming && c.status != 'missed')
              .toList();
          _outgoingCalls = callLogs.where((c) => !c.isIncoming).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading call logs: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Clear all call logs
  Future<void> _clearCallLogs() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        final bool isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: AppTheme.cardBg(isDark),
          title: Text(
            'Clear call log',
            style: TextStyle(color: AppTheme.textPrimary(isDark)),
          ),
          content: Text(
            'Are you sure you want to clear all call logs?',
            style: TextStyle(color: AppTheme.textSecondary(isDark)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Clear', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        final box = await Hive.openBox<CallLog>('call_logs');
        await box.clear();

        setState(() {
          _allCalls.clear();
          _missedCalls.clear();
          _incomingCalls.clear();
          _outgoingCalls.clear();
          _filteredCalls.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Call logs cleared'),
            backgroundColor: HexColor("#1A7F4B"),
          ),
        );
      } catch (e) {
        print('❌ Error clearing logs: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final double topPadding = MediaQuery.of(context).padding.top + 10;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg(isDark),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(isSearchActive ? 120 : 110),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: HexColor("#3A1D07"),
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF3A1D07),
              image: DecorationImage(
                image: AssetImage("images/app_bar_gredient.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Top bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: topPadding, left: 16.0),
                      child: Text(
                        "QikTalk",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),

                    Expanded(child: SizedBox()),

                    InkWell(
                      onTap: () {
                        setState(() {
                          isSearchActive = !isSearchActive;
                          if (!isSearchActive) {
                            searchController.clear();
                            _filteredCalls.clear();
                          }
                        });
                      },
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: topPadding,
                          bottom: 0.0,
                          right: 10.0,
                        ),
                        child: Icon(
                          isSearchActive ? Icons.close : Icons.search,
                          color: Colors.white.withOpacity(0.85),
                          size: 25.0,
                        ),
                      ),
                    ),

                    InkWell(
                      onTap: () async {
                        final selected = await showMenu<String>(
                          context: context,
                          position: RelativeRect.fromLTRB(
                            MediaQuery.of(context).size.width - 160,
                            75,
                            10,
                            20,
                          ),
                          color: AppTheme.scaffoldBg(isDark),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2),
                          ),
                          items: [
                            PopupMenuItem<String>(
                              value: 'clear_logs',
                              child: Row(
                                children: [
                                  SizedBox(width: 8),
                                  Text(
                                    "Clear call log",
                                    style: GoogleFonts.poppins(
                                      color: AppTheme.textPrimary(isDark),
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'settings',
                              child: Row(
                                children: [
                                  SizedBox(width: 8),
                                  Text(
                                    "Settings",
                                    style: GoogleFonts.poppins(
                                      color: AppTheme.textPrimary(isDark),
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );

                        if (selected == 'clear_logs') {
                          _clearCallLogs();
                        } else if (selected == 'settings') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => SettingsScreen()),
                          );
                        }
                      },
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: topPadding,
                          bottom: 0.0,
                          right: 20.0,
                        ),
                        child: Icon(
                          Icons.more_vert,
                          color: Colors.white.withOpacity(0.85),
                          size: 25.0,
                        ),
                      ),
                    ),
                  ],
                ),

                // Search bar
                if (isSearchActive)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: TextField(
                      controller: searchController,
                      autofocus: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Search contacts...",
                        hintStyle: const TextStyle(color: Colors.white60),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.white60,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.15),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),

                // Tab bar
                if (!isSearchActive) ...[
                  SizedBox(height: 10),
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    indicatorColor: HexColor("#1A7F4B"),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white60,
                    labelStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    tabs: [
                      Tab(text: 'All'),
                      Tab(text: 'Missed'),
                      Tab(text: 'Incoming'),
                      Tab(text: 'Outgoing'),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),

      body: RefreshIndicator(
        onRefresh: _loadCallLogs,
        color: HexColor("#1A7F4B"),
        child: isSearchActive
            ? _buildSearchResults()
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildCallList(_allCalls),
                  _buildCallList(_missedCalls),
                  _buildCallList(_incomingCalls),
                  _buildCallList(_outgoingCalls),
                ],
              ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (searchController.text.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Search for contacts',
              style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (_filteredCalls.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No results found',
              style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Try searching with a different name',
              style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.only(top: 10.0),
      itemCount: _filteredCalls.length,
      itemBuilder: (context, index) {
        final call = _filteredCalls[index];
        return _buildCallItem(call);
      },
    );
  }

  Widget _buildCallList(List<CallLogItem> calls) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    if (calls.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.call_end, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No calls yet',
              style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.only(top: 10.0),
      itemCount: calls.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            children: [
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Group calls coming soon!'),
                      backgroundColor: HexColor("#1A7F4B"),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 10.0,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30.0,
                        backgroundColor: HexColor("#2D6714"),
                        child: Icon(
                          Icons.videocam_outlined,
                          color: Colors.white,
                          size: 35,
                        ),
                      ),
                      SizedBox(width: 20),
                      Text(
                        "Create a Group call",
                        style: GoogleFonts.poppins(
                          color: AppTheme.textPrimary(isDark),
                          fontSize: 16.0,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
            ],
          );
        }

        final call = calls[index - 1];
        return _buildCallItem(call);
      },
    );
  }

  Widget _buildCallItem(CallLogItem call) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MessageScreen(
              chatId: call.chatId ?? '',
              userId: call.userId,
              username: call.userName,
              lastSeenActive: '',
              profilePicture: call.userPhoto,
              about: '',
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, top: 10.0),
                  child: CircleAvatar(
                    radius: 30.0,
                    backgroundImage: call.userPhoto.isNotEmpty
                        ? NetworkImage(_getFullImageUrl(call.userPhoto))
                        : null,
                    backgroundColor: HexColor("#FB8830"),
                    child: call.userPhoto.isEmpty
                        ? Text(
                            call.userName.isNotEmpty
                                ? call.userName[0].toUpperCase()
                                : 'U',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                ),

                SizedBox(width: 10.0),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        call.userName,
                        style: GoogleFonts.poppins(
                          color: AppTheme.textPrimary(
                            Theme.of(context).brightness == Brightness.dark,
                          ),
                          fontSize: 16.0,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      Row(
                        children: [
                          Transform.rotate(
                            angle: call.isIncoming ? 0.5 : -0.5,
                            child: Icon(
                              call.isIncoming
                                  ? Icons.call_received
                                  : Icons.call_made,
                              color: call.status == 'missed'
                                  ? Colors.red
                                  : HexColor("#05DE6D"),
                              size: 15.0,
                            ),
                          ),
                          SizedBox(width: 3),
                          Text(
                            _formatTimestamp(call.timestamp),
                            style: GoogleFonts.poppins(
                              color: call.status == 'missed'
                                  ? Colors.red
                                  : AppTheme.textSecondary(
                                      Theme.of(context).brightness ==
                                          Brightness.dark,
                                    ),
                              fontSize: 13.5,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Icon(
                        call.isVideo
                            ? Icons.videocam_outlined
                            : Icons.phone_outlined,
                        color: HexColor("#2D6714"),
                        size: 28.0,
                      ),
                    ),
                    if (call.duration > 0)
                      Padding(
                        padding: const EdgeInsets.only(right: 16.0, top: 4.0),
                        child: Text(
                          _formatDuration(call.duration),
                          style: GoogleFonts.poppins(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  String _getFullImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return '';
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }
    return ApiStrings.baseUriImage + imageUrl;
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(timestamp);
    } else if (difference.inDays == 1) {
      return 'Yesterday, ${DateFormat('HH:mm').format(timestamp)}';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE, HH:mm').format(timestamp);
    } else {
      return DateFormat('MMM dd, HH:mm').format(timestamp);
    }
  }

  String _formatDuration(int seconds) {
    if (seconds == 0) return '';

    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }
}

// Call Log Item Model
class CallLogItem {
  final String id;
  final String userId;
  final String userName;
  final String userPhoto;
  final String? chatId;
  final bool isVideo;
  final bool isIncoming;
  final String status;
  final DateTime timestamp;
  final int duration;

  CallLogItem({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhoto,
    this.chatId,
    required this.isVideo,
    required this.isIncoming,
    required this.status,
    required this.timestamp,
    required this.duration,
  });

  factory CallLogItem.fromHive(CallLog log, String myUserId) {
    return CallLogItem(
      id: log.id,
      userId: log.callerId,
      userName: log.callerName,
      userPhoto: log.callerPhoto,
      chatId: null,
      isVideo: log.callType == CallType.video,
      isIncoming: log.callStatus == CallStatus.incoming,
      status: log.callStatus.toString().split('.').last,
      timestamp: log.timestamp,
      duration: log.duration,
    );
  }

  CallLog toHiveModel() {
    return CallLog(
      id: id,
      callerId: userId,
      callerName: userName,
      callerPhoto: userPhoto,
      callType: isVideo ? CallType.video : CallType.audio,
      callStatus: status == 'missed'
          ? CallStatus.missed
          : (isIncoming ? CallStatus.incoming : CallStatus.outgoing),
      timestamp: timestamp,
      duration: duration,
    );
  }
}
