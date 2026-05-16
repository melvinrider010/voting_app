import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/location_service.dart';

class PollDetailScreen extends StatelessWidget {
  final DocumentSnapshot poll;

  const PollDetailScreen({super.key, required this.poll});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: Text(poll['question'])),

      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('polls')
            .doc(poll.id)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;
          final Map<String, dynamic> map =
          data.data() as Map<String, dynamic>;

          List options = map['options'] ?? [];
          Map votes = map['votes'] ?? {};
          String status = map['status'] ?? 'active';

          Map voters =
          map.containsKey('voters') ? map['voters'] : {};

          String? userVote =
          user != null && voters.containsKey(user.uid)
              ? voters[user.uid]['option']
              : null;

          int totalVotes = 0;
          for (var v in votes.values) {
            totalVotes += (v as int);
          }

          return ListView(
            padding: const EdgeInsets.all(10),
            children: [
              if (status == 'closed')
                const Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    "Voting Closed",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              if (userVote != null)
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    "You voted for: $userVote",
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),

              ...options.map<Widget>((option) {
                int count = votes[option] ?? 0;

                double percent =
                totalVotes == 0 ? 0 : (count / totalVotes);

                bool isSelected = option == userVote;

                return Card(
                  color: isSelected
                      ? Colors.green.shade100
                      : Colors.white,
                  child: ListTile(
                    title: Text(option),

                    subtitle: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Votes: $count (${(percent * 100).toStringAsFixed(1)}%)",
                        ),
                        const SizedBox(height: 5),
                        LinearProgressIndicator(
                          value: percent,
                          backgroundColor:
                          Colors.grey.shade300,
                          color: Colors.green,
                        ),
                      ],
                    ),

                    trailing: ElevatedButton(
                      onPressed:
                      (userVote != null ||
                          status == 'closed')
                          ? null
                          : () async {
                        try {
                          // 📍 GET LOCATION
                          final position =
                          await LocationService()
                              .getLocation();

                          // 🔥 NULL SAFETY FIX
                          if (position == null) {
                            ScaffoldMessenger.of(
                                context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                    "Location required to vote"),
                              ),
                            );
                            return;
                          }

                          final docRef =
                          FirebaseFirestore
                              .instance
                              .collection(
                              'polls')
                              .doc(poll.id);

                          await FirebaseFirestore
                              .instance
                              .runTransaction(
                                  (transaction) async {
                                final fresh =
                                await transaction
                                    .get(docRef);

                                final freshData =
                                fresh.data() as Map<
                                    String,
                                    dynamic>;

                                Map newVotes =
                                Map.from(
                                    freshData[
                                    'votes']);

                                Map newVoters =
                                freshData.containsKey(
                                    'voters')
                                    ? Map.from(
                                    freshData[
                                    'voters'])
                                    : {};

                                // 🔥 UPDATE VOTES
                                newVotes[option] =
                                    (newVotes[
                                    option] ??
                                        0) +
                                        1;

                                // 📍 SAVE VOTE + LOCATION
                                newVoters[user!.uid] = {
                                  'option': option,
                                  'lat':
                                  position.latitude,
                                  'lng':
                                  position.longitude,
                                  'time': DateTime.now()
                                      .toString(),
                                };

                                transaction.update(
                                    docRef, {
                                  'votes': newVotes,
                                  'voters': newVoters,
                                });
                              });

                          ScaffoldMessenger.of(
                              context)
                              .showSnackBar(
                            const SnackBar(
                              content: Text(
                                  "Vote submitted successfully"),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(
                              context)
                              .showSnackBar(
                            SnackBar(
                              content: Text(
                                  "Error: $e"),
                            ),
                          );
                        }
                      },
                      child: const Text("Vote"),
                    ),
                  ),
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }
}