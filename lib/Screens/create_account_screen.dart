import 'package:clinical_ai_app/Screens/login_screen.dart';
import 'package:clinical_ai_app/Services/auth_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../Custom Widgets/CustomAlertDialog.dart';
import '../Custom Widgets/custom_button.dart';
import '../Custom Widgets/custom_text_field.dart';
import '../Custom Widgets/logo_text.dart';
import '../Models/patient_list_model.dart';
import '../Services/patient_service.dart';
import '../access_token.dart';
import '../colors.dart';
import 'home_screen.dart';
import 'package:provider/provider.dart';

class CreateAccountScreen extends StatelessWidget {
  CreateAccountScreen({super.key});
  static const routeName = "/create-account";
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

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
                    'Create Your Account',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start taking smarter clinical histories today.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    hintText: 'Dr. Priya Sharma',
                    controller: nameController,
                    fieldName: "Full Name",
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    hintText: 'dr@hospital.com',
                    controller: emailController,
                    fieldName: "Email address",
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    hintText: 'Min. 8 characters',
                    controller: passwordController,
                    fieldName: 'Password',
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
                      } else if (nameController.text.isEmpty) {
                        if (!context.mounted) return;
                        showCustomDialog("Enter a valid Name", context);
                        return;
                      }
                      var response = await createAccount(
                        name: nameController.text,
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
                    text: 'Create Account',
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: "Already have an Account?",
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(color: AppColors.grey),
                        children: [
                          TextSpan(
                            text: " Sign In",
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
                                    builder: (_) => LoginScreen(),
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
