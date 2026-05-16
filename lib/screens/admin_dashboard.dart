import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Dashboard")),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('polls')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No polls available"));
          }

          final polls = snapshot.data!.docs;

          return ListView.builder(
            itemCount: polls.length,
            itemBuilder: (context, index) {
              final poll = polls[index];
              final data = poll.data() as Map<String, dynamic>;

              String question = data['question'] ?? "";
              List options = data['options'] ?? [];
              Map votes = data['votes'] ?? {};
              String status = data['status'] ?? 'active';

              // 🔥 Calculate total votes
              int totalVotes = 0;
              for (var v in votes.values) {
                totalVotes += (v as int);
              }

              return Card(
                margin:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ExpansionTile(
                  title: Text(
                    question,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("Status: $status"),

                  children: [
                    // 🔥 Show vote details
                    ...options.map<Widget>((option) {
                      int count = votes[option] ?? 0;

                      double percent =
                      totalVotes == 0 ? 0 : (count / totalVotes);

                      return ListTile(
                        title: Text(option),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Votes: $count (${(percent * 100).toStringAsFixed(1)}%)",
                            ),
                            const SizedBox(height: 5),
                            LinearProgressIndicator(
                              value: percent,
                              backgroundColor: Colors.grey.shade300,
                              color: Colors.blue,
                            ),
                          ],
                        ),
                      );
                    }).toList(),

                    const Divider(),

                    // 🔒 ACTIVE STATE
                    if (status == 'active') ...[
                      const Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          "Voting in progress - admin actions restricted",
                          style: TextStyle(color: Colors.orange),
                        ),
                      ),

                      TextButton.icon(
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('polls')
                              .doc(poll.id)
                              .update({'status': 'closed'});

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Voting closed")),
                          );
                        },
                        icon: const Icon(Icons.lock),
                        label: const Text("Close Voting"),
                      ),
                    ],

                    // 🔓 CLOSED STATE
                    if (status == 'closed') ...[
                      TextButton.icon(
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('polls')
                              .doc(poll.id)
                              .delete();

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Poll deleted")),
                          );
                        },
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: const Text(
                          "Delete Poll",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}