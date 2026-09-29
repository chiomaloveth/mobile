import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:qik_talk/features/feed/presentation/state/provider/feed_provider.dart';
import 'package:qik_talk/features/feed/data/models/unblock_user_dto.dart';

class BlockedAccountsScreen extends ConsumerStatefulWidget {
  const BlockedAccountsScreen({super.key});
 
  @override
  ConsumerState<BlockedAccountsScreen> createState() => _BlockedAccountsScreenState();
}
 
class _BlockedAccountsScreenState extends ConsumerState<BlockedAccountsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(feedProvider.notifier).getBlockedList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg(isDark),
      appBar: AppBar(
        backgroundColor: AppTheme.scaffoldBg(isDark),
        elevation: 0,
        titleSpacing: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.textPrimary(isDark)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Blocked Accounts",
          style: GoogleFonts.poppins(
            color: AppTheme.textPrimary(isDark),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.cardBg(isDark),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                style: GoogleFonts.poppins(color: AppTheme.textPrimary(isDark)),
                decoration: InputDecoration(
                  hintText: "Search blocked accounts",
                  hintStyle: GoogleFonts.poppins(
                      color: AppTheme.textSecondary(isDark), fontSize: 13),
                  prefixIcon: Icon(Icons.search,
                      color: AppTheme.textSecondary(isDark), size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
          ),
 
          // User List
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final state = ref.watch(feedProvider);
                final blockedUsers = state.blockedListResponse?.data ?? [];
 
                if (state.isBlockedListLoading && blockedUsers.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
 
                final filteredUsers = blockedUsers.where((user) {
                  final search = _searchController.text.toLowerCase();
                  return (user.username?.toLowerCase().contains(search) ??
                          false) ||
                      user.phone.toLowerCase().contains(search);
                }).toList();
 
                if (filteredUsers.isEmpty) {
                  return Center(
                    child: Text(
                      _searchController.text.isEmpty
                          ? "No blocked accounts"
                          : "No results found",
                      style: GoogleFonts.poppins(
                          color: AppTheme.textSecondary(isDark)),
                    ),
                  );
                }
 
                return ListView.builder(
                  itemCount: filteredUsers.length,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.white12,
                            backgroundImage: user.profilePicture.isNotEmpty
                                ? NetworkImage(user.profilePicture)
                                : null,
                            child: user.profilePicture.isEmpty
                                ? Text(
                                    (user.username?.isNotEmpty ?? false)
                                        ? user.username![0]
                                        : "?",
                                    style: GoogleFonts.poppins(
                                        color: AppTheme.textPrimary(isDark)),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.username ?? "User",
                                  style: GoogleFonts.poppins(
                                    color: AppTheme.textPrimary(isDark),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  user.phone,
                                  style: GoogleFonts.poppins(
                                    color: AppTheme.textSecondary(isDark),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Unblock Button
                          GestureDetector(
                            onTap: state.isUnblockLoading
                                ? null
                                : () async {
                                    final success = await ref
                                        .read(feedProvider.notifier)
                                        .unblockUser(UnblockUserDto(
                                            userIdToUnblock: user.id));
                                    if (success && context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                "User unblocked successfully")),
                                      );
                                      // Refresh the list
                                      ref
                                          .read(feedProvider.notifier)
                                          .getBlockedList();
                                    }
                                  },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: HexColor("#EA4359")
                                        .withValues(alpha: 0.5)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: state.isUnblockLoading
                                  ? const SizedBox(
                                      height: 15,
                                      width: 15,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.red),
                                    )
                                  : Text(
                                      "Unblock",
                                      style: GoogleFonts.poppins(
                                        color: HexColor("#EA4359"),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

