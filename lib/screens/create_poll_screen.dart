import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreatePollScreen extends StatefulWidget {
  const CreatePollScreen({super.key});

  @override
  State<CreatePollScreen> createState() => _CreatePollScreenState();
}

class _CreatePollScreenState extends State<CreatePollScreen> {
  final TextEditingController questionController = TextEditingController();
  final TextEditingController option1 = TextEditingController();
  final TextEditingController option2 = TextEditingController();
  final TextEditingController option3 = TextEditingController();

  bool isLoading = false;

  void createPoll() async {
    String question = questionController.text.trim();

    List<String> options = [
      option1.text.trim(),
      option2.text.trim(),
      option3.text.trim(),
    ].where((opt) => opt.isNotEmpty).toList(); // 🔥 remove empty options

    // ✅ Validation
    if (question.isEmpty || options.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter question & at least 2 options")),
      );
      return;
    }

    setState(() => isLoading = true);

    // ✅ Create votes map
    Map<String, int> votes = {};
    for (var opt in options) {
      votes[opt] = 0;
    }

    await FirebaseFirestore.instance.collection('polls').add({
      'question': question,
      'options': options,
      'votes': votes,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'active', // 🔥 IMPORTANT
      'voters': {},       // 🔥 for tracking who voted
    });

    setState(() => isLoading = false);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Poll Created Successfully")),
    );

    Navigator.pop(context);
  }

  @override
  void dispose() {
    questionController.dispose();
    option1.dispose();
    option2.dispose();
    option3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Poll")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: questionController,
              decoration: const InputDecoration(labelText: "Question"),
            ),
            TextField(
              controller: option1,
              decoration: const InputDecoration(labelText: "Option 1"),
            ),
            TextField(
              controller: option2,
              decoration: const InputDecoration(labelText: "Option 2"),
            ),
            TextField(
              controller: option3,
              decoration: const InputDecoration(labelText: "Option 3"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: isLoading ? null : createPoll,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Create Poll"),
            ),
          ],
        ),
      ),
    );
  }
}