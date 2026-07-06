import 'package:clinical_ai_app/Models/patient_model.dart';
import 'package:flutter/cupertino.dart';

class PatientListProvider extends ChangeNotifier{
  List<Patient>? patients;

  PatientListProvider({this.patients});

  factory PatientListProvider.fromJson(Map<String, dynamic> json) {
    return PatientListProvider(
      patients: (json['patients'] as List<dynamic>? ?? [])
          .map((e) => Patient.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
  void addPatient(Patient patient) {
    patients?.add(patient);
    notifyListeners();
  }
  void setPatients(List<Patient> newPatients) {
    patients = newPatients;
    notifyListeners();
  }
}