import 'package:clinical_ai_app/Custom%20Widgets/custom_button.dart';
import 'package:clinical_ai_app/Custom%20Widgets/custom_name_initial.dart';
import 'package:clinical_ai_app/Custom%20Widgets/diagnosis_card.dart';
import 'package:clinical_ai_app/functions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../Models/patient_response_history_model.dart';
import '../colors.dart';
import 'consultation_screen.dart';
import 'new_consultation_screen.dart';

class PatientDataScreen extends StatelessWidget {
  const PatientDataScreen({super.key, required this.history});
  static const routeName = "/patient-data";
  final PatientHistoryResponse history;

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
            Text(
              history.patient.name,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Image.asset("assets/kuvaka_logo.png"),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                      CustomNameInitial(
                        gender: history.patient.gender ?? "",
                        name: history.patient.name,
                        size: 60,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  text: history.patient.name,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineMedium,
                                  children: [
                                    TextSpan(
                                      text:
                                          "\n${history.patient.age} Yrs · ${history.patient.gender ?? ""}",
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
                                    text: DateFormat('d MMM yy').format(
                                      DateTime.parse(
                                        history.patient.createdAt ??
                                            DateTime.now().toString(),
                                      ),
                                    ),
                                  ),
                                  IconText(
                                    icon: LucideIcons.stethoscope,
                                    text:
                                        '${history.sessions.length} Consultations',
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
                    MaterialPageRoute(
                      builder: (_) => NewConsultationScreen(
                        patientName: history.patient.name,
                        patientAge: history.patient.age,
                        patientGender: history.patient.gender ?? "",
                        onBegin: (type, complaint, language) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ConsultationScreen(),
                            ),
                          );
                          // TODO: navigate to consultation screen with these params
                        },
                      ),
                    ),
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
                      text: "${history.sessions.length}",
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: AppColors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              history.sessions.isNotEmpty
                  ? Column(
                      children: List.generate(
                        history.sessions.length,
                        (index) => DiagnosisCard(
                          title: getSpecialtyName(
                            history.sessions[index].specialty ?? "",
                          ),
                          status: getDiagnosisStatus(
                            history.sessions[index].currentStage ?? "",
                          ),
                          date: DateTime.parse(
                            history.sessions[index].createdAt ??
                                DateTime.now().toString(),
                          ),
                          description:
                              history.sessions[index].chiefComplaint ?? "",
                          redFlags:
                              history
                                  .sessions[index]
                                  .diagnosis
                                  ?.urgentConcerns ??
                              [],
                          diagnoses: List.generate(
                            (history
                                            .sessions[index]
                                            .diagnosis
                                            ?.differentialDiagnoses
                                            .length ??
                                        0) >
                                    3
                                ? 3
                                : history
                                          .sessions[index]
                                          .diagnosis
                                          ?.differentialDiagnoses
                                          .length ??
                                      0,
                            (diffDia) => DiagnosisItem(
                              severity:
                                  history
                                      .sessions[index]
                                      .diagnosis
                                      ?.differentialDiagnoses[diffDia]
                                      .likelihood ??
                                  "",
                              name:
                                  history
                                      .sessions[index]
                                      .diagnosis
                                      ?.differentialDiagnoses[diffDia]
                                      .condition ??
                                  "",
                              code:
                                  history
                                      .sessions[index]
                                      .diagnosis
                                      ?.differentialDiagnoses[diffDia]
                                      .icdCode ??
                                  "",
                            ),
                          ),
                          workup:
                              "Workup: ${history.sessions[index].diagnosis?.suggestedWorkup.take(2).join("\n") ?? ""} + ${history.sessions[index].diagnosis?.suggestedWorkup.length ?? 2 - 2} more",
                          subjective: [
                            SoapField(
                              label: 'Chief complaint',
                              value: history.sessions[index].chiefComplaint,
                            ),
                            SoapField(
                              label: 'HPI',
                              value: history
                                  .sessions[index]
                                  .summary
                                  .subjective
                                  .historyOfPresentingIllness,
                            ),
                            SoapField(
                              label: 'Past medical history',
                              value: history
                                  .sessions[index]
                                  .summary
                                  .subjective
                                  .pastMedicalHistory,
                            ),
                            SoapField(
                              label: 'Surgical history',
                              value: history
                                  .sessions[index]
                                  .summary
                                  .subjective
                                  .surgicalHistory,
                            ),
                            SoapField(
                              label: 'Medications',
                              value: history
                                  .sessions[index]
                                  .summary
                                  .subjective
                                  .medications,
                            ),
                            SoapField(
                              label: 'Allergies',
                              value: history
                                  .sessions[index]
                                  .summary
                                  .subjective
                                  .allergies,
                            ),
                            SoapField(
                              label: 'Family history',
                              value: history
                                  .sessions[index]
                                  .summary
                                  .subjective
                                  .familyHistory,
                            ),
                            SoapField(
                              label: 'Social history',
                              value: history
                                  .sessions[index]
                                  .summary
                                  .subjective
                                  .socialHistory,
                            ),
                            SoapField(
                              label: 'Review of systems',
                              value: history
                                  .sessions[index]
                                  .summary
                                  .subjective
                                  .reviewOfSystems,
                            ),
                          ],
                          objective: [
                            SoapField(
                              label: 'Vital signs',
                              value: history
                                  .sessions[index]
                                  .summary
                                  .objective
                                  .vitalSigns,
                            ),
                            SoapField(
                              label: 'Physical exam',
                              value: history
                                  .sessions[index]
                                  .summary
                                  .objective
                                  .physicalExamination,
                            ),
                          ],
                          show: history.sessions[index].diagnosis != null
                              ? true
                              : false,
                        ),
                      ),
                    )
                  : const NoConsultationsEmptyState(),
            ],
          ),
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

class NoConsultationsEmptyState extends StatelessWidget {
  const NoConsultationsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.grey.withAlpha(50), // gray-200
          width: 2,
          style: BorderStyle.solid, // see note below for true "dashed"
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primaryLight, // brand-light
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              LucideIcons.stethoscope, // stethoscope stand-in
              size: 20,
              color: AppColors.primary, // brand
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No consultations yet',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 4),
          Text(
            'Start the first one using the button above.',
            style: Theme.of(context).textTheme.bodyMedium, // gray-400
          ),
        ],
      ),
    );
  }
}
