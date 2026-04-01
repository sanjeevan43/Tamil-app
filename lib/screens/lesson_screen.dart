import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/lesson_provider.dart';
import '../models/app_models.dart';

class LessonScreen extends StatefulWidget {
  final String lessonId;
  const LessonScreen({super.key, required this.lessonId});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        context.read<LessonProvider>().fetchQuestions(widget.lessonId));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LessonProvider>();

    if (provider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (provider.questions.isEmpty) {
      return const Scaffold(body: Center(child: Text("பாடங்கள் எதுவும் இல்லை. (No lessons found.)")));
    }

    final currentQuestion = provider.questions[provider.currentIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildProgressBar(context, provider),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentQuestion.type == QuestionType.mcq 
                    ? "சரியான விடையைத் தட்டவும் (Tap the correct answer):" 
                    : "இதைக் கூறவும் (Say this):",
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                
                // Question Card
                _buildQuestionCard(currentQuestion),
                
                const Spacer(),
                
                // Question Body (Options or Speaking)
                _buildQuestionInput(currentQuestion, provider),
                
                const Spacer(),
              ],
            ),
          ),
          
          // Feedback Panel
          if (provider.isCorrect != null)
            _buildFeedbackPanel(context, provider),
            
          // Result Overlay
          if (provider.isLessonFinished)
            _buildResultOverlay(context, provider),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildProgressBar(BuildContext context, LessonProvider provider) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.close, color: Colors.grey),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Expanded(
            child: LinearProgressIndicator(
              value: provider.progress,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              minHeight: 10,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 15),
          const Icon(Icons.favorite, color: Colors.red),
          const SizedBox(width: 5),
          Text("${provider.heartsCount}", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(LessonQuestion question) {
    String text = question.tamilText ?? question.englishText ?? "Question";
    Color textColor = question.englishText != null ? Colors.blue : Colors.black;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: textColor),
      ),
    );
  }

  Widget _buildQuestionInput(LessonQuestion question, LessonProvider provider) {
    if (question.type == QuestionType.mcq) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 2.2,
        ),
        itemCount: question.options?.length ?? 0,
        itemBuilder: (context, index) {
          String option = question.options![index];
          return ElevatedButton(
            onPressed: () => provider.checkAnswer(option),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(option, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          );
        },
      );
    } else if (question.type == QuestionType.speaking) {
      return Column(
        children: [
          const Icon(Icons.mic, size: 80, color: Colors.blue),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => provider.checkAnswer(question.correctAnswer), // Mocking correct speaking for UI
            child: const Text("பேசத் தட்டவும் (Tap to speak)", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
          ),
        ],
      );
    }
    return const SizedBox();
  }

  Widget _buildFeedbackPanel(BuildContext context, LessonProvider provider) {
    bool isCorrect = provider.isCorrect!;
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        color: isCorrect ? Colors.green : Colors.red,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(isCorrect ? Icons.check_circle : Icons.error, color: Colors.white, size: 32),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    provider.feedbackMessage,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => provider.nextQuestion(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: isCorrect ? Colors.green : Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text("அடுத்தது (Next)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultOverlay(BuildContext context, LessonProvider provider) {
    return Container(
      color: Colors.black.withOpacity(0.8),
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 30),
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("பாடம் முடிந்தது! (Lesson Completed!)", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildResultStat("XP", "${provider.xpEarned}", Colors.orange),
                  _buildResultStat("Hearts", "${provider.heartsCount}", Colors.red),
                ],
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                  child: const Text("தொடரவும் (CONTINUE)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
      ],
    );
  }
}
