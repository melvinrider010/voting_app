import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'create_poll_screen.dart';
import 'poll_list_screen.dart';
import 'admin_dashboard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isAdmin = false;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    checkAdmin();
  }

  Future<void> checkAdmin() async {
    bool result = await AuthService().isAdmin();
    setState(() {
      isAdmin = result;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Voting App")),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Center(
            child: Text(
              "Welcome to Voting App",
              style: TextStyle(fontSize: 18),
            ),
          ),

          const SizedBox(height: 20),

          // 🔥 Everyone can see polls
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PollListScreen()),
              );
            },
            child: const Text("View Polls"),
          ),

          const SizedBox(height: 10),

          // 🔐 ONLY ADMIN
          if (isAdmin)
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CreatePollScreen()),
                );
              },
              child: const Text("Create Poll (Admin)"),
            ),
        ],
      ),
    );
  }
}