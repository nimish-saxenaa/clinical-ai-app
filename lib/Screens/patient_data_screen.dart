import 'package:clinical_ai_app/Custom%20Widgets/custom_button.dart';
import 'package:clinical_ai_app/Custom%20Widgets/diagnosis_card.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../colors.dart';
import 'new_consultation_screen.dart';

class PatientDataScreen extends StatelessWidget {
  const PatientDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            InkWell(
              onTap: () => Navigator.pop(context),
              child: Row(
                children: [
                  Icon(Icons.arrow_back),
                  Text(
                    "Patients  /  ",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Text("Patient Name", style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Image.asset("assets/kuvaka_logo.png"),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Material(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.red,
                      ),
                      width: 50,
                      height: 50,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                text: "Nimish",
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineLarge?.copyWith(height: 1),
                                children: [
                                  TextSpan(
                                    text: "\n22 Years · Male",
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: [
                                IconText(
                                  icon: LucideIcons.calendar,
                                  text: "Registered 3 Jul 2026",
                                ),
                                IconText(
                                  icon: LucideIcons.stethoscope,
                                  text: '0 Consultations',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            CustomButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => NewConsultationScreen()),
                );
              },
              text: "+ New Consultation",
            ),
            const SizedBox(height: 16),
            RichText(
              text: TextSpan(
                text: "Consultation History  ",
                style: Theme.of(context).textTheme.displaySmall,
                children: [
                  TextSpan(
                    text: "3",
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: AppColors.grey),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: DiagnosisCard(
                  title: "Women's Health",
                  status: 'Diagnosed',
                  date: DateTime(2026, 7, 3, 13, 43),
                  description: 'periods pain',
                  redFlags: const [
                    '⚠️ HIGH PAIN SEVERITY (8/10) with 2-week duration of dysmenorrhoea — this exceeds typical primary dysmenorrhoea and mandates urgent evaluation for underlying structural or inflammatory pathology.',
                    '⚠️ OCP use without adequate pain control is a significant red flag for secondary dysmenorrhoea (e.g., endometriosis, adenomyosis, fibroids) — hormonal therapy failure should prompt expedited investigation.',
                    '⚠️ PID must be actively excluded: absence of documented pelvic examination, temperature, cervical motion tenderness assessment, and vaginal/cervical swab results represents a critical clinical gap.',
                    '⚠️ Vital signs and physical/pelvic examination findings are not documented — these are essential for risk stratification and must be completed urgently.',
                    '⚠️ No review of systems documented — associated symptoms (fever, abnormal vaginal discharge, dyspareunia, dyschezia, urinary symptoms, GI symptoms) are critical to narrowing the differential and must be elicited.',
                  ],
                  diagnoses: const [
                    DiagnosisItem(
                      severity: 'High',
                      name: 'Endometriosis',
                      code: 'N80.9',
                    ),
                    DiagnosisItem(
                      severity: 'Moderate',
                      name: 'Primary Dysmenorrhoea',
                      code: 'N94.4',
                    ),
                    DiagnosisItem(
                      severity: 'Moderate',
                      name: 'Uterine Fibroids (Leiomyomata)',
                      code: 'D25.9',
                    ),
                  ],
                  workup:
                      'Workup: 1. COMPLETE PELVIC EXAMINATION — bimanual and speculum exam to assess '
                      'uterine size/tenderness, adnexal masses, cervical motion tenderness, and abnormal '
                      'discharge., 2. TRANSVAGINAL ULTRASOUND (TVUS) — first-line imaging to evaluate for '
                      'fibroids, adenomyosis, ovarian cysts/endometriomas, and uterine anomalies. +10 more',
                  subjective: const [
                    SoapField(label: 'Chief complaint', value: 'Period pain'),
                    SoapField(
                      label: 'HPI',
                      value:
                          'Patient Shantanu presents with a 2-week history of period pain '
                          'rated 8/10 in severity.',
                    ),
                    SoapField(label: 'Past medical history'),
                    SoapField(label: 'Surgical history'),
                    SoapField(
                      label: 'Medications',
                      value: 'Oral contraceptive (birth control)',
                    ),
                    SoapField(label: 'Allergies'),
                    SoapField(label: 'Family history'),
                    SoapField(
                      label: 'Social history',
                      value: 'Work-related stress reported.',
                    ),
                    SoapField(label: 'Review of systems'),
                  ],
                  objective: const [
                    SoapField(label: 'Vital signs'),
                    SoapField(label: 'Physical exam'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class IconText extends StatelessWidget {
  const IconText({super.key, required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.grey, size: 14),
        SizedBox(width: 8),
        Text(text),
      ],
    );
  }
}
