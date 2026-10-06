import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_ce/hive.dart';
import 'package:iconly/iconly.dart';
import 'package:qik_talk/utilities/components/buttons/custom_button_one.dart';
import 'package:qik_talk/utilities/components/buttons/custom_button_two.dart';
import 'package:qik_talk/utilities/constants/app_colors.dart';

import '../../../../settings/theme/provider/theme_provider.dart';

class MakeTransferBottomSheet extends ConsumerStatefulWidget {
  const MakeTransferBottomSheet({super.key});

  @override
  ConsumerState<MakeTransferBottomSheet> createState() => _MakeTransferBottomSheetState();
}

class _MakeTransferBottomSheetState extends ConsumerState<MakeTransferBottomSheet> {
  int _currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);

  void _handlePageChange(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentThemeMode = ref.watch(themeProvider);
    final systemBrightness = MediaQuery.of(context).platformBrightness;

    final bool isDark =
        currentThemeMode == ThemeMode.dark ||
            (currentThemeMode == ThemeMode.system &&
                systemBrightness == Brightness.dark);
    return Material(
      clipBehavior: Clip.antiAlias,
      color: Colors.transparent,
      child: SafeArea(
        child: Container(
          height: 600,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              color: isDark ? Color(AppColors.primaryBackgroundColor) : AppColors.lightBackground,
              borderRadius: BorderRadius.vertical(top: Radius.circular(15))
          ),
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: _handlePageChange,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 15.0, top: 20),
                            child: Text(
                              "Choose Cards",
                              style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500
                              ),
                            ),
                          ),
                          const SizedBox(height: 10,),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: BouncingScrollPhysics(),
                            child: Row(
                              children: [
                                for (int i = 0; i < 3; i++)...[
                                  Padding(
                                    padding: EdgeInsets.only(left: i == 0 ? 15.0 : 5, right: i == 2 ? 15 : 5),
                                    child: _customCard(),
                                  )
                                ]
                              ],
                            ),
                          ),
                          const SizedBox(height: 25),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Choose recipients",
                                  style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500
                                  ),
                                ),
                                Text(
                                  "Change Account Details",
                                  style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFFE71E4E)
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          _searchBar(),
                          const SizedBox(height: 15),
                          Center(child: _recipientCard(isDark: isDark))
                        ],
                      ),
                    ),

                    SingleChildScrollView(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                height: 80,
                                width: 80,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  border: Border.all(width: 1, color: isDark ? Colors.grey : Colors.black),
                                  shape: BoxShape.circle
                                ),
                                child: Center(
                                  child: Container(
                                    height: 50,
                                    width: 50,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(

                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              CustomButtonTwo(
                title: 'Continue',
                onClick: () {
                  _pageController.animateToPage(
                      1,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut
                  );
                },
                isLoading: false,
              ),
              const SizedBox(height: 10,)
            ],
          ),
        ),
      ),
    );
  }

  Widget _customCard() {
    return Container(
      height: 150,
      width: MediaQuery.of(context).size.width / 1.3,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
          color: Colors.blueGrey[800],
          borderRadius: BorderRadius.circular(15)
      ),
      child: Column(
        children: [
          Expanded(child: Container(
            decoration: BoxDecoration(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(
                          height: 50,
                          width: 30,
                          child: Image.asset("images/icons/Group 244.png")),
                      SizedBox(
                          height: 50,
                          width: 30,
                          child: Image.asset("images/icons/Chips.png")),
                      Spacer(),
                      Container(
                        height: 20,
                        width: 20,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle
                        ),
                        child: Center(
                          child: Icon(Icons.check, color: Colors.white, size: 17,),
                        ),
                      )

                    ],
                  ),
                  Text(
                    "**** **** **** 1121",
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500
                    ),
                  )
                ],
              ),
            ),
          )),
          Container(
            height: 50,
            width: double.infinity,
            decoration: BoxDecoration(
                color: Color(0xFF323232)
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Row(
                children: [
                  Text(
                    "₦15,365.00",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500
                    ),
                  ),
                  Spacer(),
                  SizedBox(
                      height: 50,
                      width: 50,
                      child: Image.asset("images/icons/Group 18274.png"))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: TextFormField(
        decoration: InputDecoration(
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.transparent)
          ),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.transparent)
          ),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.transparent)
          ),
          focusColor: Colors.grey.withOpacity(0.2),
          filled: true,
          prefixIcon: Icon(IconlyLight.search),
          hintText: "Search contacts...",
          hintStyle: TextStyle(
              fontSize: 16,
              color: Colors.grey
          ),
        ),
      ),
    );
  }

  Widget _recipientCard({required bool isDark}) {
    return Container(
      height: 130,
      width: 120,
      decoration: BoxDecoration(
          border: Border.all(width: 1, color: Colors.red),
          borderRadius: BorderRadius.circular(15)
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Align(
                alignment: Alignment.topRight,
                child: Icon(Icons.check, color: Colors.green, size: 18,)),
            Container(
              height: 40,
              width: 40,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  shape: BoxShape.circle
              ),
              child: Center(
                child: Icon(IconlyBold.profile, color: Colors.grey, size: 18,),
              ),
            ),
            const SizedBox(height: 10,),
            Text(
              "Gloriay\nJohn",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Color(0xFF1D3A70)
              ),
            )
          ],
        ),
      ),
    );
  }
}