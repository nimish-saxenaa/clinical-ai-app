import 'package:clinical_ai_app/Screens/create_account_screen.dart';
import 'package:clinical_ai_app/Screens/home_screen.dart';
import 'package:clinical_ai_app/Services/auth_service.dart';
import 'package:clinical_ai_app/Services/patient_service.dart';
import 'package:clinical_ai_app/access_token.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Custom Widgets/CustomAlertDialog.dart';
import '../Custom Widgets/custom_button.dart';
import '../Custom Widgets/custom_text_field.dart';
import '../Custom Widgets/logo_text.dart';
import '../Models/patient_list_model.dart';
import '../colors.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void dispose(){
    emailController.dispose();
    passwordController.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final patientsProvider = context.read<PatientListProvider>();
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.heightOf(context),
            ),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LogoAndText(width: MediaQuery.of(context).size.width),
                  const SizedBox(height: 16),
                  Text(
                    'Welcome back.',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to your account to continue.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    hintText: 'doctor@hospital.com',
                    controller: emailController,
                    fieldName: "Email address",
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    hintText: '••••••••',
                    controller: passwordController,
                    fieldName: 'Password',
                    obscureText: true,
                    keyboardType: TextInputType.visiblePassword,
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    onPressed: () async {
                      if (emailController.text.isEmpty ||
                          !emailController.text.contains("@")) {
                        if (!context.mounted) return;
                        showCustomDialog("Enter a valid Email", context);
                        return;
                      } else if (passwordController.text.isEmpty) {
                        if (!context.mounted) return;
                        showCustomDialog("Enter a valid Password", context);
                        return;
                      }
                      var response = await login(
                        email: emailController.text,
                        password: passwordController.text,
                      );
                      if (response['access_token'] != null) {
                        AccessTokenService.saveToken(response['access_token']);
                        PatientListProvider patientList = await listPatients();

                        patientsProvider.setPatients(patientList.patients!);
                        if (!context.mounted) return;
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                HomeScreen(),
                          ),
                        );
                      } else {
                        if (!context.mounted) return;
                        showCustomDialog(
                          response['detail'].toString(),
                          context,
                        );
                      }
                    },
                    text: 'Sign In',
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: "New here?",
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(color: AppColors.grey),
                        children: [
                          TextSpan(
                            text: " Create an Account",
                            style: const TextStyle(
                              color: AppColors.primary,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.primary,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CreateAccountScreen(),
                                  ),
                                );
                              },
                          ),
                        ],
                      ),
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
}
