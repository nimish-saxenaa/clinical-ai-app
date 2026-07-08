import 'package:clinical_ai_app/colors.dart';
import 'package:flutter/material.dart';

// Adjust these import paths to match your project structure.
import '../Models/consultation_models.dart';
import '../Services/consultation_functions.dart';

/// "Review Your Responses" screen, wired to the real consultation API.
///
/// Fetches the Q&A log (and any clinical flags) via `getQaLog`, lets the
/// user edit any answer via `editAnswer`, and on "Continue to Analysis"
/// calls `finalizeConsultation` before handing off via [onContinue].
class ReviewResponsesScreen extends StatefulWidget {
  final String token;
  final String sessionId;

  /// Called once `finalizeConsultation` succeeds.
  final void Function(ConsultationContext context)? onContinue;

  const ReviewResponsesScreen({
    super.key,
    required this.token,
    required this.sessionId,
    this.onContinue,
  });

  @override
  State<ReviewResponsesScreen> createState() => _ReviewResponsesScreenState();
}

class _ReviewResponsesScreenState extends State<ReviewResponsesScreen> {
  static const Color brand = AppColors.primary;
  static const Color brandLight = AppColors.primaryLight;

  bool _loading = true;
  String? _loadError;

  List<QaLogEntry> _qaLog = [];
  List<String> _flags = [];

  int? _editingIndex;
  final TextEditingController _editController = TextEditingController();
  bool _savingEdit = false;

  bool _continuing = false;

  @override
  void initState() {
    super.initState();
    _loadQaLog();
  }

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------
  // API calls
  // ---------------------------------------------------------------------

  Future<void> _loadQaLog() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final res = await getQaLog(
        token: widget.token,
        sessionId: widget.sessionId,
      );
      if (!mounted) return;
      setState(() {
        _qaLog = res.qaLog;
        _flags = res.flags;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = 'Failed to load your responses: $e';
        _loading = false;
      });
    }
  }

  void _startEdit(int index) {
    setState(() {
      _editingIndex = index;
      _editController.text = _qaLog[index].answer ?? '';
    });
  }

  void _cancelEdit() {
    setState(() => _editingIndex = null);
  }

  Future<void> _saveEdit(int index) async {
    final entry = _qaLog[index];
    final newAnswer = _editController.text.trim();
    if (newAnswer.isEmpty) return;

    setState(() => _savingEdit = true);
    try {
      final res = await editAnswer(
        token: widget.token,
        sessionId: widget.sessionId,
        questionId: entry.questionId,
        answer: newAnswer,
      );
      if (!mounted) return;
      if (res.ok) {
        setState(() {
          _qaLog[index] = QaLogEntry(
            questionId: entry.questionId,
            questionText: entry.questionText,
            answer: newAnswer,
          );
          _editingIndex = null;
        });
      } else {
        _showError('The edit wasn\'t saved — please try again.');
      }
    } catch (e) {
      _showError('Failed to save edit: $e');
    } finally {
      if (mounted) setState(() => _savingEdit = false);
    }
  }

  Future<void> _continueToAnalysis() async {
    if (_continuing) return;
    setState(() => _continuing = true);
    try {
      final context = await finalizeConsultation(
        token: widget.token,
        sessionId: widget.sessionId,
      );
      widget.onContinue?.call(context);
    } catch (e) {
      _showError('Failed to continue: $e');
    } finally {
      if (mounted) setState(() => _continuing = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  // ---------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _loadError != null
            ? _buildLoadError()
            : _buildContent(),
      ),
    );
  }

  Widget _buildLoadError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade300, size: 40),
            const SizedBox(height: 12),
            Text(
              _loadError!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadQaLog, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            children: [
              _buildHeaderCard(),
              if (_flags.isNotEmpty) ...[
                const SizedBox(height: 20),
                _buildAlertsCard(),
              ],
              const SizedBox(height: 20),
              _buildQaLogCard(),
              const SizedBox(height: 20),
              _buildContinueButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: brandLight, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.check_box_outlined, color: brand, size: 26),
          ),
          const SizedBox(height: 12),
          const Text(
            'Review Your Responses',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 6),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500, height: 1.4),
              children: [
                const TextSpan(text: 'Check what you shared. Tap '),
                TextSpan(
                  text: 'Edit',
                  style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                ),
                const TextSpan(
                  text: ' on any answer to correct it before we generate your clinical notes.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, size: 18, color: Colors.red.shade400),
              const SizedBox(width: 8),
              Text(
                'Clinical Alerts',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red.shade700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._flags.map((flag) => Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 4),
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 13, color: Colors.red.shade900, height: 1.4),
                children: [
                  const TextSpan(text: '🔴 '),
                  const TextSpan(text: 'Red Flag: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: flag),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildQaLogCard() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 560),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: _qaLog.isEmpty
          ? Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'No responses recorded yet.',
          style: TextStyle(color: Colors.grey.shade500),
        ),
      )
          : ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: _qaLog.length,
        separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade100),
        itemBuilder: (context, index) => _buildQaItem(index),
      ),
    );
  }

  Widget _buildQaItem(int index) {
    final entry = _qaLog[index];
    final isEditing = _editingIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  'Q${index + 1}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    color: Colors.grey.shade300,
                  ),
                ),
              ),
              const Spacer(),
              if (!isEditing)
                TextButton.icon(
                  onPressed: () => _startEdit(index),
                  icon: const Icon(Icons.edit_outlined, size: 14),
                  label: const Text('Edit'),
                  style: TextButton.styleFrom(
                    foregroundColor: brand,
                    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            entry.questionText ?? '',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          if (isEditing) _buildEditField(index) else _buildAnswerText(entry),
        ],
      ),
    );
  }

  Widget _buildAnswerText(QaLogEntry entry) {
    return Container(
      padding: const EdgeInsets.only(left: 12),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: brand.withOpacity(0.2), width: 2)),
      ),
      child: Text(
        (entry.answer == null || entry.answer!.isEmpty) ? '—' : entry.answer!,
        style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.4),
      ),
    );
  }

  Widget _buildEditField(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _editController,
          autofocus: true,
          maxLines: null,
          minLines: 2,
          enabled: !_savingEdit,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: brand),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: _savingEdit ? null : _cancelEdit,
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _savingEdit ? null : () => _saveEdit(index),
              style: ElevatedButton.styleFrom(
                backgroundColor: brand,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: _savingEdit
                  ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
                  : const Text('Save'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _continuing ? null : _continueToAnalysis,
        style: ElevatedButton.styleFrom(
          backgroundColor: brand,
          foregroundColor: Colors.white,
          disabledBackgroundColor: brand.withOpacity(0.6),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: _continuing
            ? const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        )
            : const Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Continue to Analysis', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            SizedBox(width: 6),
            Icon(Icons.chevron_right, size: 18),
          ],
        ),
      ),
    );
  }
}
