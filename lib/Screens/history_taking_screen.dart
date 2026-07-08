import 'package:audioplayers/audioplayers.dart';
import 'package:clinical_ai_app/Screens/review_responses_screen.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../Services/consultation_functions.dart';
import '../Services/consultation_streaming.dart';
import '../access_token.dart';
import '../colors.dart';
import 'dart:typed_data';

class HistoryTakingScreen extends StatefulWidget {
  const HistoryTakingScreen({
    super.key,
    this.question = "This is a Question",
    required this.sessionId,
  });
  final String question;
  final String sessionId;
  static const routeName = "/history-taking";
  @override
  State<HistoryTakingScreen> createState() => _HistoryTakingScreenState();
}

class _HistoryTakingScreenState extends State<HistoryTakingScreen> {
  late String question = widget.question;
  final TextEditingController answerController = TextEditingController();

  final AudioPlayer _audioPlayer = AudioPlayer();
  Future<void> playAudio(Uint8List audioBytes) async {
    await _audioPlayer.stop();
    await _audioPlayer.play(BytesSource(audioBytes));
  }

  Uint8List? audio;
  Future<void> sendAnswer() async {
    String token = await AccessTokenService.getToken() ?? "";
    // Clear previous streamed question
    question = "";
    setState(() {});

    await for (final event in submitAnswerStream(
      token: token,
      sessionId: widget.sessionId,
      answer: answerController.text,
    )) {
      if (event.event == "token") {
        question += event.data["text"];

        setState(() {});
      }

      if (event.event == "done") {
        answerController.clear();
        if (event.data["next_question"] == null) {
          if(!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ReviewResponsesScreen(
                token: token,
                sessionId: widget.sessionId,
              ),
            ),
          );
        }
        audio = await textToSpeech(
          token: token,
          text: event.data["next_question"],
        );
        await playAudio(audio!);
        question = event.data["next_question"];
        setState(() {});
      }
      answerController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyLight,
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CenterCircleSnakeEmoji(),
              const SizedBox(height: 16),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  WhiteSquareIconButton(
                    onTap: () {
                      if (_audioPlayer.volume > 0) {
                        _audioPlayer.setVolume(0);
                      } else {
                        _audioPlayer.setVolume(100);
                      }
                    },
                    icon: LucideIcons.volume2,
                  ),
                  const SizedBox(width: 16),
                  WhiteSquareIconButton(
                    onTap: () async {
                      if (audio != null) await playAudio(audio!);
                    },
                    icon: LucideIcons.rotateCcw,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text("Question "),
              const SizedBox(height: 16),
              QuestionBubble(question: question),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: Color(0xfff0eaff),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(LucideIcons.mic, size: 15),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Speak Your\nAnswer",
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "-transcribed & analyzed\ninstantly",
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {},
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.mic),
                          const SizedBox(width: 8),
                          Text("Speak Your Answer"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      color: AppColors.grey.withAlpha(100),
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text("or type"),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      color: AppColors.grey.withAlpha(100),
                      height: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: answerController,
                      keyboardType: TextInputType.multiline,
                      minLines: 3,
                      maxLines: 3,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: AppColors.grey.withAlpha(50),
                            width: 0.3,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: AppColors.grey.withAlpha(50),
                            width: 0.3,
                          ),
                        ),
                        fillColor: AppColors.white,
                        hintText: "Type your answer here...",
                        hintStyle: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: sendAnswer,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.grey.withAlpha(50),
                          width: 0.5,
                        ),
                      ),
                      width: 50,
                      height: 50,
                      child: Icon(LucideIcons.send, color: AppColors.grey),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          LucideIcons.command,
                          color: AppColors.grey,
                          size: 15,
                        ),
                        Text(" + Enter to submit"),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          LucideIcons.skipForward,
                          color: AppColors.grey,
                          size: 15,
                        ),
                        Text("Skip Question"),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuestionBubble extends StatelessWidget {
  const QuestionBubble({super.key, required this.question});

  final String question;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(50),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              question,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),
        Positioned(
          top: -10,
          left: 24,
          child: Transform.rotate(
            angle: 0.785398,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  left: BorderSide(color: Colors.grey.shade200),
                  top: BorderSide(color: Colors.grey.shade200),
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class WhiteSquareIconButton extends StatelessWidget {
  const WhiteSquareIconButton({
    super.key,
    required this.onTap,
    required this.icon,
  });
  final void Function() onTap;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 35,
        height: 35,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.grey.withAlpha(100), width: 0.5),
        ),
        child: Icon(icon, color: AppColors.grey, size: 16),
      ),
    );
  }
}

class CenterCircleSnakeEmoji extends StatelessWidget {
  const CenterCircleSnakeEmoji({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Center(
          child: Material(
            elevation: 3,
            borderRadius: BorderRadius.circular(100),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Column(
                children: [
                  Container(width: 100, height: 70, color: Colors.white),
                  Container(width: 100, height: 30, color: AppColors.grey),
                ],
              ),
            ),
          ),
        ),
        Center(child: Text("⚕️", style: TextStyle(fontSize: 40))),
      ],
    );
  }
}
