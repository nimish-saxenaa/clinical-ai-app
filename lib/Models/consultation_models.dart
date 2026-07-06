

import 'package:clinical_ai_app/Models/session_model.dart';

/// ---------------------------------------------------------------------
/// POST /api/v1/consultation/start
/// ---------------------------------------------------------------------
class StartConsultationResponse {
  final String sessionId;
  final String? specialty;
  final String? stage;
  final String? openingQuestion;

  StartConsultationResponse({
    required this.sessionId,
    this.specialty,
    this.stage,
    this.openingQuestion,
  });

  factory StartConsultationResponse.fromJson(Map<String, dynamic> json) {
    return StartConsultationResponse(
      sessionId: (json['session_id'] ?? '').toString(),
      specialty: json['specialty'],
      stage: json['stage'],
      openingQuestion: json['opening_question'],
    );
  }

  Map<String, dynamic> toJson() => {
        'session_id': sessionId,
        'specialty': specialty,
        'stage': stage,
        'opening_question': openingQuestion,
      };
}

/// ---------------------------------------------------------------------
/// GET /api/v1/consultation/{session_id}
/// ---------------------------------------------------------------------
class SessionStateResponse {
  final String sessionId;
  final String? specialty;
  final String? currentStage;
  final int qaCount;
  final List<String> flags;
  final bool historyComplete;
  final bool hasSummary;
  final bool hasDiagnosis;
  final bool hasPrescription;

  SessionStateResponse({
    required this.sessionId,
    this.specialty,
    this.currentStage,
    required this.qaCount,
    required this.flags,
    required this.historyComplete,
    required this.hasSummary,
    required this.hasDiagnosis,
    required this.hasPrescription,
  });

  factory SessionStateResponse.fromJson(Map<String, dynamic> json) {
    return SessionStateResponse(
      sessionId: (json['session_id'] ?? '').toString(),
      specialty: json['specialty'],
      currentStage: json['current_stage'],
      qaCount: json['qa_count'] is int
          ? json['qa_count']
          : int.tryParse(json['qa_count']?.toString() ?? '') ?? 0,
      flags: (json['flags'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      historyComplete: json['history_complete'] == true,
      hasSummary: json['has_summary'] == true,
      hasDiagnosis: json['has_diagnosis'] == true,
      hasPrescription: json['has_prescription'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'session_id': sessionId,
        'specialty': specialty,
        'current_stage': currentStage,
        'qa_count': qaCount,
        'flags': flags,
        'history_complete': historyComplete,
        'has_summary': hasSummary,
        'has_diagnosis': hasDiagnosis,
        'has_prescription': hasPrescription,
      };
}

/// ---------------------------------------------------------------------
/// POST /api/v1/consultation/{session_id}/answer
/// (also used for /answer-audio, and the final "done" event of /answer-stream)
/// ---------------------------------------------------------------------
class SubmitAnswerResponse {
  final List<String> newFlags;
  final String? nextQuestion;
  final bool historyComplete;

  SubmitAnswerResponse({
    required this.newFlags,
    this.nextQuestion,
    required this.historyComplete,
  });

  factory SubmitAnswerResponse.fromJson(Map<String, dynamic> json) {
    return SubmitAnswerResponse(
      newFlags: (json['new_flags'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      nextQuestion: json['next_question'],
      historyComplete: json['history_complete'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'new_flags': newFlags,
        'next_question': nextQuestion,
        'history_complete': historyComplete,
      };
}

/// ---------------------------------------------------------------------
/// GET /api/v1/consultation/{session_id}/qa-log
/// ---------------------------------------------------------------------
class QaLogEntry {
  final String questionId;
  final String? questionText;
  final String? answer;

  QaLogEntry({required this.questionId, this.questionText, this.answer});

  factory QaLogEntry.fromJson(Map<String, dynamic> json) {
    return QaLogEntry(
      questionId: (json['question_id'] ?? '').toString(),
      questionText: json['question_text'],
      answer: json['answer'],
    );
  }

  Map<String, dynamic> toJson() => {
        'question_id': questionId,
        'question_text': questionText,
        'answer': answer,
      };
}

class QaLogResponse {
  final List<QaLogEntry> qaLog;
  final List<String> flags;
  final String? rawTranscript;
  final String? translatedTranscript;

  QaLogResponse({
    required this.qaLog,
    required this.flags,
    this.rawTranscript,
    this.translatedTranscript,
  });

  factory QaLogResponse.fromJson(Map<String, dynamic> json) {
    return QaLogResponse(
      qaLog: (json['qa_log'] as List<dynamic>? ?? [])
          .map((e) => QaLogEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      flags: (json['flags'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      rawTranscript: json['raw_transcript'],
      translatedTranscript: json['translated_transcript'],
    );
  }

  Map<String, dynamic> toJson() => {
        'qa_log': qaLog.map((e) => e.toJson()).toList(),
        'flags': flags,
        'raw_transcript': rawTranscript,
        'translated_transcript': translatedTranscript,
      };
}

/// ---------------------------------------------------------------------
/// PATCH /api/v1/consultation/{session_id}/answer/{question_id}
/// ---------------------------------------------------------------------
class EditAnswerResponse {
  final bool ok;

  EditAnswerResponse({required this.ok});

  factory EditAnswerResponse.fromJson(Map<String, dynamic> json) {
    return EditAnswerResponse(ok: json['ok'] == true);
  }

  Map<String, dynamic> toJson() => {'ok': ok};
}

/// ---------------------------------------------------------------------
/// POST /api/v1/consultation/{session_id}/prescribe
/// Shape of "prescription" is not yet specified by the API, kept raw.
/// ---------------------------------------------------------------------
class PrescribeResponse {
  final dynamic prescription;

  PrescribeResponse({this.prescription});

  factory PrescribeResponse.fromJson(Map<String, dynamic> json) {
    return PrescribeResponse(prescription: json['prescription']);
  }

  Map<String, dynamic> toJson() => {'prescription': prescription};
}

/// ---------------------------------------------------------------------
/// POST /api/v1/consultation/{session_id}/finalize
/// Full ConsultationContext object.
/// ---------------------------------------------------------------------
class ConsultationContext {
  final String sessionId;
  final String? specialty;
  final String? stage;
  final List<QaLogEntry> qaLog;
  final List<String> flags;
  final SessionSummary? summary;
  final Diagnosis? diagnosis;
  final dynamic prescription; // raw, shape not yet specified
  final Map<String, dynamic>? overrides;
  final Map<String, dynamic> raw; // full raw payload for any extra fields

  ConsultationContext({
    required this.sessionId,
    this.specialty,
    this.stage,
    required this.qaLog,
    required this.flags,
    this.summary,
    this.diagnosis,
    this.prescription,
    this.overrides,
    required this.raw,
  });

  factory ConsultationContext.fromJson(Map<String, dynamic> json) {
    return ConsultationContext(
      sessionId: (json['session_id'] ?? '').toString(),
      specialty: json['specialty'],
      stage: json['stage'],
      qaLog: (json['qa_log'] as List<dynamic>? ?? [])
          .map((e) => QaLogEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      flags: (json['flags'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      summary: json['summary'] != null
          ? SessionSummary.fromJson(json['summary'] as Map<String, dynamic>)
          : null,
      diagnosis: json['diagnosis'] != null
          ? Diagnosis.fromJson(json['diagnosis'] as Map<String, dynamic>)
          : null,
      prescription: json['prescription'],
      overrides: json['overrides'] as Map<String, dynamic>?,
      raw: json,
    );
  }

  Map<String, dynamic> toJson() => raw;
}

/// ---------------------------------------------------------------------
/// POST /api/v1/consultation/{session_id}/override
/// ---------------------------------------------------------------------
class OverrideFieldResponse {
  final String overridden;
  final dynamic newValue;

  OverrideFieldResponse({required this.overridden, this.newValue});

  factory OverrideFieldResponse.fromJson(Map<String, dynamic> json) {
    return OverrideFieldResponse(
      overridden: (json['overridden'] ?? '').toString(),
      newValue: json['new_value'],
    );
  }

  Map<String, dynamic> toJson() => {
        'overridden': overridden,
        'new_value': newValue,
      };
}

/// ---------------------------------------------------------------------
/// DELETE /api/v1/consultation/{session_id}
/// ---------------------------------------------------------------------
class DeleteConsultationResponse {
  final String deleted;

  DeleteConsultationResponse({required this.deleted});

  factory DeleteConsultationResponse.fromJson(Map<String, dynamic> json) {
    return DeleteConsultationResponse(deleted: (json['deleted'] ?? '').toString());
  }

  Map<String, dynamic> toJson() => {'deleted': deleted};
}
