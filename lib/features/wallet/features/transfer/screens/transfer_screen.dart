import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_ce/hive.dart';
import 'package:iconly/iconly.dart';
import 'package:qik_talk/features/wallet/features/transfer/screens/search_for_recipient_screen.dart';
import '../../../../../utilities/components/buttons/custom_back_button.dart';
import '../../../../../utilities/constants/app_colors.dart';
import '../../../../authentication/provider/user_provider.dart';
import '../../../../settings/theme/provider/theme_provider.dart';
import '../components/recent_transfer_item_card.dart';

class TransferScreen extends ConsumerStatefulWidget {
  const TransferScreen({super.key});

  @override
  ConsumerState<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends ConsumerState<TransferScreen> {
  final TextEditingController _textEditingController = TextEditingController();

  int _currentTabIndex = 0;

  void _handleTabClick(int index) {
    setState(() {
      _currentTabIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    ref.read(userProfileProvider.notifier).loadUser();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProfileProvider);
    final currentThemeMode = ref.watch(themeProvider);
    final systemBrightness = MediaQuery.of(context).platformBrightness;

    final bool isDark =
        currentThemeMode == ThemeMode.dark ||
        (currentThemeMode == ThemeMode.system &&
            systemBrightness == Brightness.dark);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: isDark
            ? Color(AppColors.primaryBackgroundColor)
            : Colors.white,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: isDark
            ? Color(AppColors.primaryBackgroundColor)
            : Colors.white,
        appBar: AppBar(
          backgroundColor: isDark
              ? Color(AppColors.primaryBackgroundColor)
              : Colors.white,
          surfaceTintColor: isDark
              ? Color(AppColors.primaryBackgroundColor)
              : Colors.white,
          automaticallyImplyLeading: false,
          centerTitle: true,
          leading: CustomBackButton(buildContext: context),
          title: Text(
            "Transfer",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : null,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.history, color: isDark ? Colors.white : null),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.more_vert, color: isDark ? Colors.white : null),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Paying from",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: isDark ? Colors.white : null,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10.0,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              Container(
                                height: 42,
                                width: 42,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    width: 1,
                                    color: Colors.white,
                                  ),
                                ),
                                child: Image.network(
                                  user.profilePicture,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, err, st) {
                                    return Center(
                                      child: Icon(
                                        IconlyBold.profile,
                                        color: Colors.grey,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        user.username,
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.white.withOpacity(0.5),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0,
                                        ),
                                        child: Container(
                                          height: 7,
                                          width: 1,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              0.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Text(
                                        "Qik@user_o",
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.white.withOpacity(0.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    "₦1,230,315.15",
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Recipient’s Qiktag",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: isDark ? Colors.white : null,
                        ),
                      ),
                      const SizedBox(height: 3),
                      GestureDetector(
                        onTap: (){
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SearchForRecipientScreen()));
                        },
                        child: Container(
                          height: 47,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Row(
                              children: [
                                Icon(
                                  IconlyLight.search,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 10,),
                                Text(
                                  "Search Contact...",
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: Colors.white,
                                  ),
                                ),
                              ],

                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.0),
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: Colors.transparent
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                _defaultTab(title: "Recent", index: 0, currentIndex: _currentTabIndex, onClick: () => _handleTabClick(0)),
                                const SizedBox(width: 15,),
                                _defaultTab(title: "Saved", index: 1, currentIndex: _currentTabIndex, onClick: () => _handleTabClick(1)),
                                Spacer(),
                                IconButton(onPressed: (){}, icon: Icon(IconlyLight.search, color: Colors.white,))
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 3,),
                        Column(
                          children: [
                            for (int i = 0; i < 7; i++)
                              RecentTransferItemCard()
                          ],
                        ),
                        const SizedBox(height: 15,),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _defaultTab({required String title, required int index, required int currentIndex, required VoidCallback onClick}) {
    return GestureDetector(
      onTap: onClick,
      child: Container(
        decoration: BoxDecoration(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Colors.white
              ),
            ),
            const SizedBox(height: 5,),
            Container(
              height: 2,
              width: 45,
              decoration: BoxDecoration(
                color: index == currentIndex ? Colors.deepOrange : Colors.transparent,
                borderRadius: BorderRadius.circular(30)
              ),
            )
          ],
        ),
      ),
    );
  }
}
