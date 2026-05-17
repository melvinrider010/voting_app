import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'admin_dashboard.dart';
import 'poll_list_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;

  const EmailVerificationScreen({
    super.key,
    required this.email,
  });

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends State<EmailVerificationScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  bool isLoading = false;

  Timer? timer;

  @override
  void initState() {
    super.initState();

    sendVerificationEmail();

    timer = Timer.periodic(
      const Duration(seconds: 3),
          (_) => checkEmailVerified(),
    );
  }

  Future<void> sendVerificationEmail() async {
    try {
      setState(() {
        isLoading = true;
      });

      UserCredential userCredential =
      await auth.createUserWithEmailAndPassword(
        email: widget.email,
        password: "VotingApp@123",
      );

      await userCredential.user!
          .sendEmailVerification();

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> checkEmailVerified() async {
    await auth.currentUser?.reload();

    final user = auth.currentUser;

    if (user != null && user.emailVerified) {
      timer?.cancel();

      checkUserRole(user.email!);
    }
  }

  Future<void> checkUserRole(String email) async {
    try {
      final query =
      await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (query.docs.isNotEmpty) {
        final userData = query.docs.first.data();

        final role = userData['role'];

        if (!mounted) return;

        if (role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) =>
              const AdminDashboard(),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) =>
              const PollListScreen(),
            ),
          );
        }
      } else {
        await FirebaseFirestore.instance
            .collection('users')
            .add({
          'email': email,
          'role': 'user',
          'hasVoted': false,
        });

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
            const PollListScreen(),
          ),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF4A00E0),
              Color(0xFF8E2DE2),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: SafeArea(
          child: Center(
            child: Padding(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 25,
              ),

              child: Column(
                mainAxisAlignment:
                MainAxisAlignment.center,

                children: [
                  const Icon(
                    Icons.mark_email_read,
                    size: 100,
                    color: Colors.white,
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    "Verify Your Email",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    widget.email,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 40),

                  Container(
                    padding:
                    const EdgeInsets.all(25),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                      BorderRadius.circular(
                          25),
                    ),

                    child: Column(
                      children: [
                        const Text(
                          "A verification email has been sent.\n\nPlease verify your email to continue.",
                          textAlign:
                          TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),

                        const SizedBox(height: 30),

                        isLoading
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                          onPressed:
                          sendVerificationEmail,
                          child: const Text(
                            "Resend Email",
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}