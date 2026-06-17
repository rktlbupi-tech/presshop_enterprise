import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/camera_data.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';

class ContentSubmittedScreen extends StatelessWidget {
  final PublishData? publishData;

  const ContentSubmittedScreen({super.key, this.publishData});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: size.width * 0.25,
                height: size.width * 0.25,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle,
                    color: AppColors.primary, size: size.width * 0.15),
              ),
              SizedBox(height: size.width * 0.06),
              Text(
                'Your Submission Has Been Received',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: size.width * 0.06,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'AirbnbCereal',
                  color: Colors.black,
                ),
              ),
              SizedBox(height: size.width * 0.03),
              Text(
                "Your content or evidence has been securely uploaded and shared with your organisation for review and further action. All submissions are automatically processed through PressHop's AI moderation tools to detect manipulated, AI-generated, or non-compliant content.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: size.width * 0.034,
                  height: 1.45,
                  color: Colors.grey[600],
                  fontFamily: 'AirbnbCereal',
                ),
              ),
              SizedBox(height: size.width * 0.1),
              SizedBox(
                width: double.infinity,
                height: size.width * 0.13,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(size.width * 0.03),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (_) => const DashboardScreen()),
                    (r) => false,
                  ),
                  child: Text(
                    'Back to Dashboard',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size.width * 0.04,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'AirbnbCereal',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
