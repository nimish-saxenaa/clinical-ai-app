import 'package:clinical_ai_app/Screens/Authentication/login_screen.dart';
import 'package:flutter/material.dart';

import '../../Custom Widgets/custom_button.dart';
import '../../Custom Widgets/logo_text.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
  static const routeName = "/welcome";

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.heightOf(context),
            ),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LogoAndText(width: width),
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Smarter histories.\nBetter outcomes.",
                            style: Theme.of(context).textTheme.displayLarge,
                            textAlign: TextAlign.left,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "AI-powered medical history taking that helps you diagnose with confidence and document without the burden.",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Column(
                        children: [

                          IconText(
                            text: "Structured patient history in under 5 minutes",
                          ),
                          const SizedBox(height: 16),
                          IconText(text: 'AI-generated differential diagnoses'),
                          const SizedBox(height: 16),
                          IconText(text: 'Instant SOAP note documentation'),
                          const SizedBox(height: 16),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                  CustomButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginScreen(),
                        ),
                      );
                    },
                    child: Text('Get Started'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class IconText extends StatelessWidget {
  const IconText({super.key, required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.check_circle,
          color: Theme.of(context).colorScheme.primary,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}