import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/features/welcome/onboarding/provider/onboarding_provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';


class SlidersPage extends ConsumerWidget {
  const SlidersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sliderProvider);
    final notifier = ref.read(sliderProvider.notifier);

    return Scaffold(
      backgroundColor:HexColor("#1B1B1B"),
      appBar: AppBar(
        toolbarHeight: 0.0,
        backgroundColor:HexColor("#1B1B1B"),
      ),
      body: Stack(
        clipBehavior: Clip.none, // allows overlap
        children: [
          /// Background waves
          Container(
            margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.20),
            height: MediaQuery.of(context).size.height * 0.79,
            decoration: BoxDecoration(
              image: DecorationImage(image: AssetImage("images/waves.png",), fit: BoxFit.fill),
              borderRadius: BorderRadius.only(),
            ),
          ),

          Column(
            children: [
              const SizedBox(height: 20),

              /// ---------------- SLIDER ----------------
              Expanded(
                child: PageView.builder(
                  controller: notifier.pageController,
                  itemCount: notifier.slides.length,
                  onPageChanged: notifier.onPageChanged,
                  itemBuilder: (context, index) {
                    final slide = notifier.slides[index];

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 30, right: 30, top: 50),
                          child: Image.asset(
                            slide['img']!,
                            height:
                            MediaQuery.of(context).size.height * 0.30,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          slide['textBold1']!,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          slide['text1']!,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          slide['text2']!,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),


              GestureDetector(
                onTap: () => notifier.nextPage(context),
                child: Container(
                  width: double.infinity, // makes sure it takes the full width
                  height: 55.0,
                  margin:const EdgeInsets.only(left: 30, right: 30, top: 50.0),
                  decoration: BoxDecoration(
                    gradient:  LinearGradient(
                      colors: [HexColor("#FF00A8"), HexColor("#00D1FF")],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: HexColor("#FB8830").withOpacity(0.4),
                        blurRadius: 25, // 🔥 increase blur
                        spreadRadius: 2,
                        offset: Offset(0, 10),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 30, // 🔥 soft ambient blur
                        offset: Offset(0, 20),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    decoration: BoxDecoration(
                      color: HexColor("#1B1B1B"),
                      borderRadius: BorderRadius.circular(19),
                    ),
                    child: Center(
                      child: Text(state.isLastPage ? "Get Started" : "Next",
                        style: const TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),


              Row(
                children: [

                  Expanded(child: SizedBox()),

                  GestureDetector(
                    onTap: () => notifier.skip(context),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 70.0, right: 20.0),
                      child: Text("Skip",style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.normal, fontSize:16.0,),),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 0.0, top: 73.0),
                    child:SmoothPageIndicator(
                      controller: notifier.pageController,
                      count: notifier.slides.length,
                      effect: CustomizableEffect(
                        spacing: 8.0,

                        dotDecoration: DotDecoration(
                          width: 9.5,
                          height: 9.5,
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(50),
                        ),

                        activeDotDecoration: DotDecoration(
                          width: 12,
                          height: 12,
                          color: HexColor("#9B1A85"),
                          borderRadius: BorderRadius.circular(50),
                          dotBorder: DotBorder(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),

                  Expanded(child: SizedBox()),
                ],
              ),

              SizedBox(
                height: 60.0,
              ),

            ],
          ),
        ],
      ),
    );
  }
}

