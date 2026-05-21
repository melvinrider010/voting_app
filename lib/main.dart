import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(const VotingApp());
}

class VotingApp extends StatelessWidget {
  const VotingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Secure Voting App',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        backgroundColor: Colors.indigo,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Secure Voting App",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 20),

            // APP LOGO + TITLE
            const Center(
              child: Column(
                children: [

                  Icon(
                    Icons.how_to_vote,
                    size: 110,
                    color: Colors.indigo,
                  ),

                  SizedBox(height: 20),

                  Text(
                    "Welcome to Secure Voting",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 12),

                  Text(
                    "A modern, secure and transparent online voting platform for everyone.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // ABOUT SECTION
            const Text(
              "About The App",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            const Text(
              "This app allows citizens to participate in secure online elections using verified authentication methods such as Aadhaar, PAN card, or Voter ID verification.",
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 35),

            // FEATURES TITLE
            const Text(
              "Features",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // FEATURE CARDS
            featureCard(
              Icons.security,
              "Highly Secure",
              "Encrypted voting system with secure authentication.",
            ),

            featureCard(
              Icons.verified_user,
              "Verified Users",
              "Only verified users can participate in elections.",
            ),

            featureCard(
              Icons.bar_chart,
              "Transparent Results",
              "Monitor voting statistics in real-time.",
            ),

            featureCard(
              Icons.phone_android,
              "Easy To Use",
              "Vote from anywhere using your smartphone.",
            ),

            featureCard(
              Icons.lock,
              "One Vote Per User",
              "Prevent duplicate and fake voting attempts.",
            ),

            const SizedBox(height: 120),
          ],
        ),
      ),

      // FLOATING BUTTON
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.indigo,

        onPressed: () {

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ),
          );

        },

        icon: const Icon(
          Icons.login,
          color: Colors.white,
        ),

        label: const Text(
          "Login / Register",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // FEATURE CARD WIDGET
  static Widget featureCard(
      IconData icon,
      String title,
      String subtitle,
      ) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 20),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),

      child: Padding(
        padding: const EdgeInsets.all(18),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Icon(
              icon,
              size: 40,
              color: Colors.indigo,
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}