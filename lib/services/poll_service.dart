import 'package:cloud_firestore/cloud_firestore.dart';

class PollService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createPoll(String question, List<String> options) async {
    Map<String, int> votes = {};

    for (var option in options) {
      if (option.isNotEmpty) {
        votes[option] = 0;
      }
    }

    await _db.collection('polls').add({
      'question': question,
      'options': options,
      'votes': votes,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}