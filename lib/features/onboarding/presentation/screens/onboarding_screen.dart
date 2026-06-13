import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../config/routes/app_router.dart';
import '../../../../core/constants/app_colors.dart';

/// Faithful port of the old app's WalkThrough screen: 6 pages with full-bleed
/// rounded photos (alternating above/below the text), a pink marker highlight
/// behind the first title line, Skip / Next controls and a pink pill button.
class _WalkData {
  final String image;
  final String title1;
  final String title2;
  final String description;
  final String buttonText;
  final bool showButton;

  const _WalkData({
    required this.image,
    required this.title1,
    required this.title2,
    required this.description,
    required this.buttonText,
    required this.showButton,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController controller = PageController();

  static const String _img = 'assets/images/';
  static const String _titleBg = 'assets/images/walkTitleBackGround.png';

  final List<_WalkData> walkthroughList = const [
    _WalkData(
      image: '${_img}walk1.png',
      title1: 'CONNECT DIRECTLY',
      title2: 'WITH THE PRESS',
      description:
          'Sell your content, and directly interact with leading publications around the World',
      buttonText: '',
      showButton: false,
    ),
    _WalkData(
      image: '${_img}walk2.png',
      title1: 'TAKE A PIC OR',
      title2: 'VIDEO',
      description:
          'Shoot pics and videos of incidents you see in your everyday life, on your mobile',
      buttonText: 'Go on, take a pic',
      showButton: true,
    ),
    _WalkData(
      image: '${_img}walk3.png',
      title1: 'SELL YOUR CONTENT',
      title2: 'TO THE PRESS',
      description:
          'Upload, and sell your content anonymously to hundreds of registered publications on our market-place',
      buttonText: 'Sell your pics now',
      showButton: true,
    ),
    _WalkData(
      image: '${_img}walk4.png',
      title1: 'ACCEPT TASKS',
      title2: '& EARN MONEY ',
      description:
          'Accept broadcasted tasks, take pics, videos and interviews for the press & earn thousands of Pounds instantly',
      buttonText: 'Start accepting tasks',
      showButton: true,
    ),
    _WalkData(
      image: '${_img}walk5.png',
      title1: 'KEEP TRACK OF YOUR',
      title2: ' FUNDS',
      description:
          'View your earnings, payments due to you, and keep track of your money on the app',
      buttonText: 'Start earning money',
      showButton: true,
    ),
    _WalkData(
      image: '${_img}walk6.png',
      title1: 'CONNECT WITH OUR',
      title2: 'GROWING TRIBE',
      description:
          'View sold content, check what other users have earned, interact, learn & grow with the community',
      buttonText: 'Join our tribe',
      showButton: true,
    ),
  ];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
    if (!mounted) return;
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: PageView.builder(
          controller: controller,
          itemCount: walkthroughList.length,
          itemBuilder: (context, index) {
            final item = walkthroughList[index];
            final bool imageOnTop = index % 2 == 0;
            return Padding(
              key: ValueKey('walk_$index'),
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: size.width * 0.02),
                  imageOnTop
                      ? Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(size.width * 0.1),
                            child: Image.asset(
                              item.image,
                              fit: BoxFit.cover,
                              width: size.width,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                  SizedBox(height: imageOnTop ? size.width * 0.04 : 0),

                  // Title line 1 with the pink marker highlight behind it.
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        top: size.width * 0.04,
                        child: Image.asset(
                          _titleBg,
                          fit: BoxFit.fill,
                        ),
                      ),
                      Text(
                        item.title1,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'AirbnbCereal',
                          fontSize: size.width * 0.07,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    item.title2,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'AirbnbCereal',
                      fontSize: size.width * 0.07,
                    ),
                  ),
                  Text(
                    item.description,
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'AirbnbCereal',
                      fontSize: size.width * 0.035,
                    ),
                  ),
                  SizedBox(height: imageOnTop ? 0 : size.width * 0.04),

                  !imageOnTop
                      ? Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(size.width * 0.1),
                            child: Image.asset(
                              item.image,
                              fit: BoxFit.cover,
                              width: size.width,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                  SizedBox(height: size.width * 0.04),

                  // Skip / pill button / Next row.
                  SizedBox(
                    height: size.width * 0.12,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (index == 0)
                          Positioned(
                            left: 0,
                            child: InkWell(
                              onTap: _finish,
                              splashColor: Colors.grey.shade300,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: size.width * 0.02,
                                  vertical: size.width * 0.03,
                                ),
                                child: Text(
                                  'Skip',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal,
                                    fontFamily: 'AirbnbCereal',
                                    fontSize: size.width * 0.03,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (item.showButton)
                          ElevatedButton(
                            onPressed: _finish,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                vertical: size.width * 0.012,
                                horizontal: size.width * 0.04,
                              ),
                              backgroundColor: AppColors.employeeBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  size.width * 0.05,
                                ),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              item.buttonText,
                              style: TextStyle(
                                fontSize: size.width * 0.035,
                                color: Colors.white,
                                fontFamily: 'AirbnbCereal',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        Positioned(
                          right: 0,
                          child: InkWell(
                            onTap: () {
                              if (index == walkthroughList.length - 1) {
                                _finish();
                              } else {
                                controller.animateToPage(
                                  index + 1,
                                  duration: const Duration(milliseconds: 100),
                                  curve: Curves.linear,
                                );
                              }
                            },
                            splashColor: Colors.grey.shade300,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: size.width * 0.02,
                                vertical: size.width * 0.03,
                              ),
                              child: Text(
                                'Next',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: size.width * 0.03,
                                  fontWeight: FontWeight.normal,
                                  fontFamily: 'AirbnbCereal',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: size.width * 0.03),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
