import 'package:clinical_ai_app/Models/patient_list_model.dart';
import 'package:clinical_ai_app/Models/patient_model.dart';
import 'package:clinical_ai_app/Screens/patient_data_screen.dart';
import 'package:clinical_ai_app/colors.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../Custom Widgets/new_patient_form.dart';
import '../functions.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.patientList});

  final PatientListResponse patientList;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyLight,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Image.asset("assets/kuvaka_logo.png"),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(LucideIcons.logOut, color: AppColors.grey),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showNewPatientDialog(context);
        },
        child: const Icon(Icons.person_add_alt_1_rounded),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                text: "Patients  ",
                style: Theme.of(context).textTheme.headlineLarge,
                children: [
                  TextSpan(
                    text: "3",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Manage and view your patient records",
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                fillColor: Colors.white,
                hintText: "Search Patients...",
                hintStyle: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.grey),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: patientList.patients.length,
                itemBuilder: (context, index) {
                  return CustomPatientBubble(
                    patient: patientList.patients[index],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomPatientBubble extends StatelessWidget {
  const CustomPatientBubble({super.key, required this.patient});

  final Patient patient;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(16),
      color: Colors.white,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PatientDataScreen()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: patient.gender == "Male"
                            ? AppColors.secondaryMale
                            : patient.gender == "Female"
                            ? AppColors.secondaryFemale
                            : AppColors.secondaryOther,
                      ),
                      width: 50,
                      height: 50,
                      child: Center(
                        child: Text(
                          getInitials(patient.name),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: patient.gender == "Male"
                                    ? AppColors.primaryMale
                                    : patient.gender == "Female"
                                    ? AppColors.primaryFemale
                                    : AppColors.primaryOther,
                              ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: RichText(
                          text: TextSpan(
                            text: patient.name,
                            style: Theme.of(context).textTheme.bodyLarge,
                            children: [
                              TextSpan(
                                text:
                                    "\n${patient.age} Yrs · ${patient.gender}",
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_right_rounded,
                      color: AppColors.grey,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    GenderLabel(patient: patient),
                    Expanded(child: SizedBox()),
                    Text(
                      DateFormat(
                        'd MMM yy',
                      ).format(DateTime.parse(patient.createdAt!)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GenderLabel extends StatelessWidget {
  const GenderLabel({super.key, required this.patient});

  final Patient patient;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          width: 1,
          color: patient.gender == "Male"
              ? AppColors.primaryMale
              : patient.gender == "Female"
              ? AppColors.primaryFemale
              : AppColors.primaryOther,
        ),
        color: patient.gender == "Male"
            ? AppColors.secondaryMale
            : patient.gender == "Female"
            ? AppColors.secondaryFemale
            : AppColors.secondaryOther,
      ),
      child: Text(
        patient.gender ?? "",
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: patient.gender == "Male"
              ? AppColors.primaryMale
              : patient.gender == "Female"
              ? AppColors.primaryFemale
              : AppColors.primaryOther,
        ),
      ),
    );
  }
}
