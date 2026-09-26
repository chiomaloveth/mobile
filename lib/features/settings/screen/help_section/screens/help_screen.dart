import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:iconly/iconly.dart';
import 'package:qik_talk/features/settings/screen/help_section/screens/contact_support_screen.dart';
import 'package:qik_talk/features/settings/screen/help_section/screens/faq_detail_screen.dart';
import 'package:qik_talk/features/settings/screen/help_section/screens/report_a_bug_screen.dart';
import 'package:qik_talk/features/settings/screen/help_section/screens/user_guide_screen.dart';
import 'package:qik_talk/features/settings/screen/help_section/screens/about_qiktalk_screen.dart';
import 'package:qik_talk/features/settings/screen/help_section/screens/privacy_policy_screen.dart';
import 'package:qik_talk/features/settings/screen/help_section/screens/terms_of_service_screen.dart';

import '../../../../../utilities/constants/app_colors.dart';
import '../../../../../utilities/constants/app_theme.dart';
import '../../../../authentication/provider/user_provider.dart';
import '../../../theme/provider/theme_provider.dart';

// ── FAQ content block types ───────────────────────────────────────────────────
enum FaqBlockType { paragraph, numbered, bullet, note }

class FaqBlock {
  final FaqBlockType type;
  final String text;
  final int? number; // only for [numbered]

  const FaqBlock.paragraph(this.text)
      : type = FaqBlockType.paragraph,
        number = null;

  const FaqBlock.numbered(this.number, this.text) : type = FaqBlockType.numbered;

  const FaqBlock.bullet(this.text)
      : type = FaqBlockType.bullet,
        number = null;

  const FaqBlock.note(this.text)
      : type = FaqBlockType.note,
        number = null;
}

// ── FAQ data model ────────────────────────────────────────────────────────────
class FaqCategory {
  final String icon;
  final String title;
  final String questionCount;
  final List<FaqItem> questions;

  const FaqCategory({
    required this.icon,
    required this.title,
    required this.questionCount,
    required this.questions,
  });
}

class FaqItem {
  final String question;
  final List<FaqBlock> blocks;

  const FaqItem({required this.question, required this.blocks});
}

// ── Static FAQ data ───────────────────────────────────────────────────────────
final List<FaqCategory> _faqCategories = [
  // ── Getting Started ─────────────────────────────────────────────────────────
  FaqCategory(
    icon: 'doc_icon.png',
    title: 'Getting Started',
    questionCount: '4 Questions',
    questions: [
      FaqItem(
        question: 'How do I create an account?',
        blocks: [
          FaqBlock.paragraph('To create an account:'),
          FaqBlock.numbered(1, 'Open Qikchat and tap "Create New Account"'),
          FaqBlock.numbered(2, 'Enter your phone number with country code'),
          FaqBlock.numbered(3, 'Verify the OTP sent to your number'),
          FaqBlock.numbered(4, 'Set up your profile with name and photo'),
          FaqBlock.numbered(5, 'Start chatting!'),
          FaqBlock.note('Your phone number is your unique identifier on Qikchat'),
        ],
      ),
      FaqItem(
        question: 'How to add contacts?',
        blocks: [
          FaqBlock.paragraph('You can add contacts in several ways:'),
          FaqBlock.numbered(1, 'Sync your phone contacts automatically'),
          FaqBlock.numbered(2, 'Search by phone number in the app'),
          FaqBlock.numbered(3, 'Scan someone\'s QR code'),
          FaqBlock.numbered(4, 'Share your contact link'),
          FaqBlock.note('Contacts who use Qikchat will appear automatically when you sync.'),
        ],
      ),
      FaqItem(
        question: 'How to start a conversation?',
        blocks: [
          FaqBlock.paragraph('To start a new chat:'),
          FaqBlock.numbered(1, 'Tap the chat icon on the Chats tab'),
          FaqBlock.numbered(2, 'Select a contact from your list'),
          FaqBlock.numbered(3, 'Type your message and send'),
          FaqBlock.paragraph('You can also:'),
          FaqBlock.bullet('Send voice messages'),
          FaqBlock.bullet('Share photos and videos'),
          FaqBlock.bullet('Share your location'),
          FaqBlock.bullet('Send documents'),
        ],
      ),
      FaqItem(
        question: 'How do I customise my profile?',
        blocks: [
          FaqBlock.paragraph('To edit your profile:'),
          FaqBlock.numbered(1, 'Go to Settings'),
          FaqBlock.numbered(2, 'Tap on your profile at the top'),
          FaqBlock.numbered(3, 'Update your photo, name, or about'),
          FaqBlock.numbered(4, 'Save changes'),
          FaqBlock.note(
              'You can also add links and customise your profile appearance in Settings → Account.'),
        ],
      ),
    ],
  ),

  // ── Privacy & Security ──────────────────────────────────────────────────────
  FaqCategory(
    icon: 'lock_icon.png',
    title: 'Privacy & Security',
    questionCount: '5 Questions',
    questions: [
      FaqItem(
        question: 'How does end-to-end encryption work?',
        blocks: [
          FaqBlock.paragraph('Qikchat uses end-to-end encryption for all messages:'),
          FaqBlock.bullet('Messages are encrypted on your device'),
          FaqBlock.bullet('Only you and the recipient can read them'),
          FaqBlock.bullet('Not even Qikchat can access your messages'),
          FaqBlock.bullet('Applies to text, media, and calls'),
          FaqBlock.note('You\'ll see a lock icon indicating encryption is active.'),
        ],
      ),
      FaqItem(
        question: 'How to enable two-factor authentication?',
        blocks: [
          FaqBlock.paragraph('Enable 2FA for extra security:'),
          FaqBlock.numbered(1, 'Go to Settings → Account → Security'),
          FaqBlock.numbered(2, 'Tap "Two-Step Verification"'),
          FaqBlock.numbered(3, 'Create a 6-digit PIN'),
          FaqBlock.numbered(4, 'Confirm your PIN'),
          FaqBlock.numbered(5, 'Add email (optional but recommended)'),
          FaqBlock.note(
              'You\'ll need this PIN when registering your number on a new device'),
        ],
      ),
      FaqItem(
        question: 'How to block someone?',
        blocks: [
          FaqBlock.paragraph('To block a contact:'),
          FaqBlock.numbered(1, 'Open the chat with that person'),
          FaqBlock.numbered(2, 'Tap their name at the top'),
          FaqBlock.numbered(3, 'Scroll down and tap "Block Contact"'),
          FaqBlock.numbered(4, 'Confirm your choice'),
          FaqBlock.paragraph('Blocked contacts:'),
          FaqBlock.bullet('Cannot call or message you'),
          FaqBlock.bullet('Won\'t see your status updates'),
          FaqBlock.bullet('Won\'t see your profile changes'),
        ],
      ),
      FaqItem(
        question: 'Who can see my last seen status?',
        blocks: [
          FaqBlock.paragraph('Control your last seen visibility:'),
          FaqBlock.numbered(1, 'Go to Settings → Account → Privacy'),
          FaqBlock.numbered(2, 'Tap "Last Seen & Online"'),
          FaqBlock.numbered(3, 'Choose: Everyone, Contacts, Contacts Except, or Nobody'),
          FaqBlock.note(
              'Note: If you hide your last seen, you won\'t see others\' last seen either'),
        ],
      ),
      FaqItem(
        question: 'How secure is QikTalk',
        blocks: [
          FaqBlock.paragraph('QikTalk security features:'),
          FaqBlock.bullet('End-to-end encryption for all messages'),
          FaqBlock.bullet('Two-factor authentication available'),
          FaqBlock.bullet('Fingerprint/Face ID lock option'),
          FaqBlock.bullet('No message storage on our servers'),
          FaqBlock.bullet('Regular security audits'),
          FaqBlock.bullet('Open security documentation'),
          FaqBlock.note('Your privacy is our top priority.'),
        ],
      ),
    ],
  ),

  // ── Features ────────────────────────────────────────────────────────────────
  FaqCategory(
    icon: 'message_icon.png',
    title: 'Features',
    questionCount: '6 Questions',
    questions: [
      FaqItem(
        question: 'How to create a group?',
        blocks: [
          FaqBlock.paragraph('Create a group chat:'),
          FaqBlock.numbered(1, 'Tap the + icon on Chats tab'),
          FaqBlock.numbered(2, 'Select "New Group"'),
          FaqBlock.numbered(3, 'Choose participants (up to 256)'),
          FaqBlock.numbered(4, 'Set group name and icon'),
          FaqBlock.numbered(5, 'Tap Create'),
          FaqBlock.paragraph('As admin, you can:'),
          FaqBlock.bullet('Add/remove members'),
          FaqBlock.bullet('Change group settings'),
          FaqBlock.bullet('Delete the group'),
        ],
      ),
      FaqItem(
        question: 'How to share status?',
        blocks: [
          FaqBlock.paragraph('Share a status update:'),
          FaqBlock.numbered(1, 'Go to Status tab'),
          FaqBlock.numbered(2, 'Tap "My Status" or the + icon'),
          FaqBlock.numbered(3, 'Choose photo, video, or text'),
          FaqBlock.numbered(4, 'Add caption or drawings'),
          FaqBlock.numbered(5, 'Share'),
          FaqBlock.paragraph('Status updates:'),
          FaqBlock.bullet('Disappear after 24 hours'),
          FaqBlock.bullet('Can be viewed by selected contacts'),
          FaqBlock.bullet('Show who viewed'),
        ],
      ),
      FaqItem(
        question: 'How to make Voice/Video calls?',
        blocks: [
          FaqBlock.paragraph('Make calls in Qikchat:'),
          FaqBlock.numbered(1, 'Open a chat'),
          FaqBlock.numbered(2, 'Tap the phone icon for voice call'),
          FaqBlock.numbered(3, 'Tap the video icon for video call'),
          FaqBlock.paragraph('For group calls:'),
          FaqBlock.numbered(1, 'Open group chat'),
          FaqBlock.numbered(2, 'Tap call icon'),
          FaqBlock.numbered(3, 'Select participants'),
          FaqBlock.numbered(4, 'Choose voice or video'),
          FaqBlock.note('Calls are end-to-end encrypted.'),
        ],
      ),
      FaqItem(
        question: 'What are disappearing messages?',
        blocks: [
          FaqBlock.paragraph('Disappearing messages auto-delete after a set time:'),
          FaqBlock.numbered(1, 'Open chat settings'),
          FaqBlock.numbered(2, 'Enable "Disappearing Messages"'),
          FaqBlock.numbered(3, 'Choose duration (24h, 7d, or 90d)'),
          FaqBlock.paragraph('Messages disappear:'),
          FaqBlock.bullet('After the set time period'),
          FaqBlock.bullet('For both sender and recipient'),
          FaqBlock.bullet('But can still be screenshotted'),
          FaqBlock.note('Set a default timer in Settings → Account → Privacy.'),
        ],
      ),
      FaqItem(
        question: 'How to use Communities?',
        blocks: [
          FaqBlock.paragraph('Communities help organize group conversations:'),
          FaqBlock.numbered(1, 'Go to Communities tab'),
          FaqBlock.numbered(2, 'Tap "Create Community"'),
          FaqBlock.numbered(3, 'Add name and description'),
          FaqBlock.numbered(4, 'Create topic channels'),
          FaqBlock.numbered(5, 'Invite members'),
          FaqBlock.paragraph('Features:'),
          FaqBlock.bullet('Multiple topic-based channels'),
          FaqBlock.bullet('Up to 5000 members'),
          FaqBlock.bullet('Admin controls'),
          FaqBlock.bullet('Announcements channel'),
        ],
      ),
      FaqItem(
        question: 'How does the AI Assistant work?',
        blocks: [
          FaqBlock.paragraph('The AI Assistant helps you:'),
          FaqBlock.bullet('Translate messages'),
          FaqBlock.bullet('Answer questions'),
          FaqBlock.bullet('Organize information'),
          FaqBlock.bullet('Provide suggestions'),
          FaqBlock.paragraph('To use:'),
          FaqBlock.numbered(1, 'Go to Settings → AI Assistant'),
          FaqBlock.numbered(2, 'Start chatting with the AI'),
          FaqBlock.numbered(3, 'Ask anything you need help with'),
          FaqBlock.note('Your conversations with AI are private and not stored'),
        ],
      ),
    ],
  ),

  // ── Account Management ──────────────────────────────────────────────────────
  FaqCategory(
    icon: 'info_icon.png',
    title: 'Account Management',
    questionCount: '4 Questions',
    questions: [
      FaqItem(
        question: 'How to change my phone number?',
        blocks: [
          FaqBlock.paragraph('Change your number:'),
          FaqBlock.numbered(1, 'Go to Settings → Account'),
          FaqBlock.numbered(2, 'Tap "Change Number"'),
          FaqBlock.numbered(3, 'Verify your old number'),
          FaqBlock.numbered(4, 'Enter new number'),
          FaqBlock.numbered(5, 'Verify with OTP'),
          FaqBlock.paragraph('Your account data transfers:'),
          FaqBlock.bullet('All chats and groups'),
          FaqBlock.bullet('Settings and preferences'),
          FaqBlock.bullet('Profile information'),
          FaqBlock.note('Contacts will see your new number.'),
        ],
      ),
      FaqItem(
        question: 'How to delete my account?',
        blocks: [
          FaqBlock.paragraph('Delete your account permanently:'),
          FaqBlock.numbered(1, 'Go to Settings → Account'),
          FaqBlock.numbered(2, 'Tap "Delete My Account"'),
          FaqBlock.numbered(3, 'Read the warning carefully'),
          FaqBlock.numbered(4, 'Type DELETE to confirm'),
          FaqBlock.numbered(5, 'Enter your password'),
          FaqBlock.paragraph('This will:'),
          FaqBlock.bullet('Delete all messages'),
          FaqBlock.bullet('Remove you from groups'),
          FaqBlock.bullet('Delete profile and media'),
          FaqBlock.bullet('Cannot be undone'),
          FaqBlock.note('You have 30 days to cancel by logging in.'),
        ],
      ),
      FaqItem(
        question: 'How to backup my chats?',
        blocks: [
          FaqBlock.paragraph('Backup your chat history:'),
          FaqBlock.numbered(1, 'Go to Settings → Backup'),
          FaqBlock.numbered(2, 'Enable "Auto Backup"'),
          FaqBlock.numbered(3, 'Choose frequency (daily/weekly)'),
          FaqBlock.numbered(4, 'Select backup content'),
          FaqBlock.numbered(5, 'Connect cloud account'),
          FaqBlock.paragraph('Backup includes:'),
          FaqBlock.bullet('All messages'),
          FaqBlock.bullet('Media (photos/videos)'),
          FaqBlock.bullet('Documents'),
          FaqBlock.note('Backups are end-to-end encrypted.'),
        ],
      ),
      FaqItem(
        question: 'How to download my data?',
        blocks: [
          FaqBlock.paragraph('Request your account information:'),
          FaqBlock.numbered(1, 'Go to Settings → Account'),
          FaqBlock.numbered(2, 'Tap "Request Account Info"'),
          FaqBlock.numbered(3, 'Submit request'),
          FaqBlock.numbered(4, 'Wait 3 days for processing'),
          FaqBlock.numbered(5, 'Download when ready'),
          FaqBlock.paragraph('Report includes:'),
          FaqBlock.bullet('Account information'),
          FaqBlock.bullet('Profile data'),
          FaqBlock.bullet('Groups list'),
          FaqBlock.bullet('Contacts'),
          FaqBlock.note('Does not include message content.'),
        ],
      ),
    ],
  ),

  // ── Payments & Wallet ───────────────────────────────────────────────────────
  FaqCategory(
    icon: 'wallet_icon.png',
    title: 'Payments & Wallet',
    questionCount: '3 Questions',
    questions: [
      FaqItem(
        question: 'How to add money to wallet?',
        blocks: [
          FaqBlock.paragraph('Add funds to your wallet:'),
          FaqBlock.numbered(1, 'Go to Settings → Wallet'),
          FaqBlock.numbered(2, 'Tap "Add Money"'),
          FaqBlock.numbered(3, 'Enter amount'),
          FaqBlock.numbered(4, 'Select payment method'),
          FaqBlock.numbered(5, 'Confirm transaction'),
          FaqBlock.paragraph('Payment methods:'),
          FaqBlock.bullet('Credit/Debit cards'),
          FaqBlock.bullet('Bank account'),
          FaqBlock.bullet('Digital wallets'),
          FaqBlock.note('All transactions are secure and encrypted.'),
        ],
      ),
      FaqItem(
        question: 'How to send money to contacts?',
        blocks: [
          FaqBlock.numbered(1, 'Open wallet or chat'),
          FaqBlock.numbered(2, 'Tap "Send Money"'),
          FaqBlock.numbered(3, 'Enter amount'),
          FaqBlock.numbered(4, 'Select recipient'),
          FaqBlock.numbered(5, 'Add note (optional)'),
          FaqBlock.numbered(6, 'Confirm'),
          FaqBlock.note('Money is transferred instantly. No fees for peer-to-peer transfers.'),
        ],
      ),
      FaqItem(
        question: 'Is my payment information secure?',
        blocks: [
          FaqBlock.paragraph('Your payment security:'),
          FaqBlock.bullet('Bank-level encryption'),
          FaqBlock.bullet('PCI DSS compliant'),
          FaqBlock.bullet('No card details stored'),
          FaqBlock.bullet('Two-factor authentication'),
          FaqBlock.bullet('Transaction monitoring'),
          FaqBlock.bullet('Fraud protection'),
          FaqBlock.note('We never share your financial information'),
        ],
      ),
    ],
  ),

  // ── Premium Features ────────────────────────────────────────────────────────
  FaqCategory(
    icon: 'award_icon.png',
    title: 'Premium Features',
    questionCount: '2 Questions',
    questions: [
      FaqItem(
        question: 'What is Qikchat Premium?',
        blocks: [
          FaqBlock.paragraph('Premium benefits:'),
          FaqBlock.bullet('Ad-free experience'),
          FaqBlock.bullet('Custom themes and colors'),
          FaqBlock.bullet('Verified badge'),
          FaqBlock.bullet('Larger group sizes (500 members)'),
          FaqBlock.bullet('Priority support'),
          FaqBlock.bullet('Advanced analytics'),
          FaqBlock.bullet('Early access to features'),
          FaqBlock.note('Plans start at \$4.99/month.'),
          FaqBlock.note('Upgrade in Settings → Premium'),
        ],
      ),
      FaqItem(
        question: 'How to cancel Premium subscription?',
        blocks: [
          FaqBlock.paragraph('Cancel your subscription:'),
          FaqBlock.numbered(1, 'Go to Settings → Premium'),
          FaqBlock.numbered(2, 'Tap "Manage Subscription"'),
          FaqBlock.numbered(3, 'Select "Cancel Subscription"'),
          FaqBlock.numbered(4, 'Confirm cancellation'),
          FaqBlock.note(
              'You keep premium features until the end of your billing period. No refunds for partial months.'),
        ],
      ),
    ],
  ),

  // ── Troubleshooting ─────────────────────────────────────────────────────────
  FaqCategory(
    icon: 'bug_icon.png',
    title: 'Troubleshooting',
    questionCount: '4 Questions',
    questions: [
      FaqItem(
        question: 'Messages not sending?',
        blocks: [
          FaqBlock.numbered(1, 'Check internet connection'),
          FaqBlock.numbered(2, 'Restart the app'),
          FaqBlock.numbered(3, 'Update to latest version'),
          FaqBlock.numbered(4, 'Clear app cache'),
          FaqBlock.numbered(5, 'Check storage space'),
          FaqBlock.paragraph('If issue persists:'),
          FaqBlock.bullet('Settings → Data and Storage → Clear Cache'),
          FaqBlock.bullet('Reinstall the app'),
          FaqBlock.bullet('Contact support'),
        ],
      ),
      FaqItem(
        question: 'Can\'t receive notifications?',
        blocks: [
          FaqBlock.paragraph('Fix notification issues:'),
          FaqBlock.numbered(1, 'Enable notifications in phone settings'),
          FaqBlock.numbered(2, 'Check QikTalk notification settings'),
          FaqBlock.numbered(3, 'Disable battery optimization for QikTalk'),
          FaqBlock.numbered(4, 'Restart your device'),
          FaqBlock.paragraph('Settings path:'),
          FaqBlock.note('Settings → Notifications → Enable all options'),
        ],
      ),
      FaqItem(
        question: 'App crashes frequently?',
        blocks: [
          FaqBlock.paragraph('Resolve app crashes:'),
          FaqBlock.numbered(1, 'Update to latest version'),
          FaqBlock.numbered(2, 'Clear app cache and data'),
          FaqBlock.numbered(3, 'Restart your device'),
          FaqBlock.numbered(4, 'Free up storage space'),
          FaqBlock.numbered(5, 'Check for OS updates'),
          FaqBlock.numbered(6, 'Reinstall the app'),
          FaqBlock.note('If crashes continue, report via Settings → Help → Report Bug.'),
        ],
      ),
      FaqItem(
        question: 'Can\'t restore backup?',
        blocks: [
          FaqBlock.paragraph('Backup restoration issues:'),
          FaqBlock.numbered(1, 'Use same phone number'),
          FaqBlock.numbered(2, 'Use same cloud account'),
          FaqBlock.numbered(3, 'Check internet connection'),
          FaqBlock.numbered(4, 'Verify backup exists'),
          FaqBlock.numbered(5, 'Update the app'),
          FaqBlock.note('Backup restore happens during setup. If missed, reinstall the app.'),
        ],
      ),
    ],
  ),
];

// ── Main Help Screen ──────────────────────────────────────────────────────────
class HelpScreen extends ConsumerStatefulWidget {
  const HelpScreen({super.key});

  @override
  ConsumerState<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends ConsumerState<HelpScreen> {
  // Tracks which FAQ category is expanded (-1 = none)
  int _expandedFaqIndex = -1;

  @override
  void initState() {
    super.initState();
    ref.read(userProfileProvider.notifier).loadUser();
  }

  @override
  Widget build(BuildContext context) {
    final currentThemeMode = ref.watch(themeProvider);
    final systemBrightness = MediaQuery.of(context).platformBrightness;

    final bool isDark =
        currentThemeMode == ThemeMode.dark ||
        (currentThemeMode == ThemeMode.system &&
            systemBrightness == Brightness.dark);

    final double topPadding = MediaQuery.of(context).padding.top + 10;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: isDark
            ? Color(AppColors.primaryBackgroundColor)
            : AppTheme.scaffoldBg(isDark),
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: isDark
            ? Color(AppColors.primaryBackgroundColor)
            : AppTheme.scaffoldBg(isDark),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: isDark ? HexColor('#3A1D07') : AppTheme.scaffoldBg(isDark),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                image: isDark ? const DecorationImage(
                  image: AssetImage('images/app_bar_gredient.png'),
                  fit: BoxFit.cover,
                ) : null,
                color: isDark ? null : AppTheme.scaffoldBg(isDark),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: topPadding,
                            left: 16.0,
                            right: 16.0,
                          ),
                          child: Icon(
                            Icons.arrow_back,
                            size: 22.0,
                            color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: topPadding),
                        child: Text(
                          'Help & Support',
                          style: GoogleFonts.poppins(
                            color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 14),
                        // ── Search bar ──────────────────────────────────────
                        SizedBox(
                          height: 44,
                          child: TextFormField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  width: 1,
                                  color: isDark
                                      ? Colors.white.withOpacity(0.25)
                                      : Colors.grey.shade300,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  width: 1,
                                  color: isDark
                                      ? Colors.white.withOpacity(0.25)
                                      : Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  width: 1,
                                  color: isDark
                                      ? Colors.white.withOpacity(0.4)
                                      : Colors.grey,
                                ),
                              ),
                              hintText: 'Search for help.......',
                              hintStyle: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: isDark
                                    ? Colors.white.withOpacity(0.4)
                                    : Colors.grey,
                              ),
                              prefixIcon: Icon(
                                IconlyLight.search,
                                color: isDark
                                    ? Colors.white.withOpacity(0.5)
                                    : Colors.grey,
                                size: 20,
                              ),
                              contentPadding: EdgeInsets.zero,
                              filled: true,
                              fillColor: isDark
                                  ? Colors.white.withOpacity(0.05)
                                  : Colors.grey.shade50,
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),

                        // ── QUICK ACTION ────────────────────────────────────
                        _sectionHeader('QUICK ACTION', isDark),
                        const SizedBox(height: 8),
                        _helpOptionCard(
                          icon: 'Vector.png',
                          title: 'Contact Support',
                          message: 'Get help from our Team',
                          onClick: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ContactSupportScreen(),
                            ),
                          ),
                          isDark: isDark,
                        ),
                        _divider(isDark),
                        _helpOptionCard(
                          icon: 'bug_icon.png',
                          title: 'Report a Bug',
                          message: 'Help us improve the app',
                          onClick: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ReportABugScreen(),
                            ),
                          ),
                          isDark: isDark,
                        ),
                        _divider(isDark),
                        _helpOptionCard(
                          icon: 'doc_icon.png',
                          title: 'User Guide',
                          message: 'Learn how to use Qikchat',
                          onClick: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const UserGuideScreen(),
                            ),
                          ),
                          isDark: isDark,
                        ),
                        const SizedBox(height: 22),

                        // ── FREQUENTLY ASKED QUESTIONS ──────────────────────
                        _sectionHeader('FREQUENTLY ASKED QUESTIONS', isDark),
                        const SizedBox(height: 8),
                        ..._faqCategories.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final cat = entry.value;
                          final isExpanded = _expandedFaqIndex == idx;
                          return _faqCategoryTile(
                            category: cat,
                            isExpanded: isExpanded,
                            isDark: isDark,
                            onTap: () {
                              setState(() {
                                _expandedFaqIndex = isExpanded ? -1 : idx;
                              });
                            },
                          );
                        }),
                        const SizedBox(height: 22),

                        // ── LEGAL & POLICIES ────────────────────────────────
                        _sectionHeader('LEGAL & POLICIES', isDark),
                        const SizedBox(height: 8),
                        _legalOptionRow(
                          icon: 'lock_icon.png',
                          title: 'Privacy Policy',
                          isDark: isDark,
                          onClick: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const PrivacyPolicyScreen(),
                            ),
                          ),
                        ),
                        _divider(isDark),
                        _legalOptionRow(
                          icon: 'doc_icon.png',
                          title: 'Terms Of Service',
                          isDark: isDark,
                          onClick: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const TermsOfServiceScreen(),
                            ),
                          ),
                        ),
                        _divider(isDark),
                        _legalOptionRow(
                          icon: 'info_icon.png',
                          title: 'About QikTalk',
                          isDark: isDark,
                          onClick: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const AboutQikTalkScreen(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Support footer ──────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: 14,
                bottom: MediaQuery.of(context).padding.bottom + 14,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? Color(AppColors.primaryColor).withOpacity(0.6)
                    : Colors.grey.shade100,
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? Colors.white.withOpacity(0.08)
                        : Colors.grey.shade200,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.mail_outline_rounded,
                    color: isDark
                        ? Colors.white.withOpacity(0.7)
                        : Colors.grey.shade600,
                    size: 18,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Support@QikTalk',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    'Available 24/7',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: isDark
                          ? Colors.white.withOpacity(0.5)
                          : Colors.grey,
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

  // ── Section header ──────────────────────────────────────────────────────────
  Widget _sectionHeader(String text, bool isDark) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: isDark ? Colors.white.withOpacity(0.5) : Colors.grey.shade600,
      ),
    );
  }

  // ── Thin divider ────────────────────────────────────────────────────────────
  Widget _divider(bool isDark) {
    return Container(
      height: 1,
      color: isDark ? Colors.white.withOpacity(0.07) : Colors.grey.shade200,
    );
  }

  // ── Quick-action card ───────────────────────────────────────────────────────
  Widget _helpOptionCard({
    required String icon,
    required String title,
    required String message,
    required VoidCallback onClick,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onClick,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            SizedBox(
              height: 22,
              width: 22,
              child: Image.asset(
                'images/icons/$icon',
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    message,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: isDark
                          ? Colors.white.withOpacity(0.45)
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: isDark ? Colors.white.withOpacity(0.5) : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  // ── FAQ expandable category tile ────────────────────────────────────────────
  Widget _faqCategoryTile({
    required FaqCategory category,
    required bool isExpanded,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              children: [
                SizedBox(
                  height: 22,
                  width: 22,
                  child: Image.asset(
                    'images/icons/${category.icon}',
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.title,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        category.questionCount,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: isDark
                              ? Colors.white.withOpacity(0.45)
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: isExpanded ? 0.25 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: isDark ? Colors.white.withOpacity(0.5) : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Expanded question list
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Column(
            children: category.questions.map((faq) {
              return GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => FaqDetailScreen(faqItem: faq),
                  ),
                ),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 36.0,
                    top: 4,
                    bottom: 4,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          faq.question,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: isDark
                                ? Colors.white.withOpacity(0.75)
                                : Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 13,
                        color: isDark
                            ? Colors.white.withOpacity(0.35)
                            : Colors.grey.shade400,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          crossFadeState: isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
        _divider(isDark),
      ],
    );
  }

  // ── Legal row ───────────────────────────────────────────────────────────────
  Widget _legalOptionRow({
    required String icon,
    required String title,
    required bool isDark,
    required VoidCallback onClick,
  }) {
    return GestureDetector(
      onTap: onClick,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13.0),
        child: Row(
          children: [
            SizedBox(
              height: 20,
              width: 20,
              child: Image.asset(
                'images/icons/$icon',
                color: isDark ? Colors.white.withOpacity(0.7) : Colors.black54,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: isDark ? Colors.white.withOpacity(0.8) : Colors.black87,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: isDark ? Colors.white.withOpacity(0.5) : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
