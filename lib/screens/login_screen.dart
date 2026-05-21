import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'admin_verification_screen.dart';
import 'register_screen.dart';
import 'user_dashboard.dart';
import 'verification_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {

  final TextEditingController emailController =
  TextEditingController();

  final TextEditingController passwordController =
  TextEditingController();

  bool obscurePassword = true;
  bool loading = false;

  // LOGIN USER
  Future<void> loginUser() async {

    try {

      setState(() {
        loading = true;
      });

      UserCredential userCredential =
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // RELOAD USER
      await userCredential.user!.reload();

      User? user =
          FirebaseAuth.instance.currentUser;

      print("AUTH UID: ${user?.uid}");

      if (!mounted) return;

      setState(() {
        loading = false;
      });

      // CHECK EMAIL VERIFIED
      if (user != null &&
          user.emailVerified) {

        // GET USER DATA FROM FIRESTORE
        DocumentSnapshot userDoc =
        await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .get();

        print("DOCUMENT EXISTS: ${userDoc.exists}");
        print("DOCUMENT DATA: ${userDoc.data()}");

        if (!mounted) return;

        // USER DOCUMENT EXISTS
        if (userDoc.exists) {

          Map<String, dynamic> data =
          userDoc.data()
          as Map<String, dynamic>;

          String role =
          data["role"]
              .toString()
              .trim()
              .toLowerCase();

          bool verified =
              data["verified"] ?? false;

          print("ROLE VALUE = $role");
          print("VERIFIED = $verified");

          // ADMIN LOGIN
          if (role == "admin") {

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) =>
                const AdminVerificationScreen(),
              ),
            );

          }

          // VERIFIED USER
          else if (verified == true) {

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) =>
                const UserDashboard(),
              ),
            );

          }

          // NORMAL USER
          else {

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) =>
                const VerificationScreen(),
              ),
            );
          }

        }

        // DOCUMENT NOT FOUND
        else {

          ScaffoldMessenger.of(context)
              .showSnackBar(
            const SnackBar(
              content: Text(
                "User data not found in Firestore",
              ),
            ),
          );
        }

      }

      // EMAIL NOT VERIFIED
      else {

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              "Please verify your email first.",
            ),
          ),
        );
      }

    }

    on FirebaseAuthException catch (e) {

      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e.message ?? "Login Failed",
          ),
        ),
      );
    }

    catch (e) {

      if (!mounted) return;

      setState(() {
        loading = false;
      });

      print("ERROR: $e");

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(

          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 25,
              vertical: 20,
            ),

            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                /// IMAGE
                Center(
                  child: Image.asset(
                    'assets/login.png',
                    height: 250,
                  ),
                ),

                const SizedBox(height: 20),

                /// TITLE
                const Text(
                  "Login",
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0B1D26),
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Please Login to continue.",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 40),

                /// EMAIL FIELD
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F2),
                    borderRadius:
                    BorderRadius.circular(18),
                  ),

                  child: TextField(
                    controller: emailController,

                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      prefixIcon:
                      Icon(Icons.email_outlined),
                      hintText: "Enter your Email",

                      contentPadding:
                      EdgeInsets.symmetric(
                        vertical: 22,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// PASSWORD FIELD
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F2),
                    borderRadius:
                    BorderRadius.circular(18),
                  ),

                  child: TextField(
                    controller: passwordController,
                    obscureText: obscurePassword,

                    decoration: InputDecoration(
                      border: InputBorder.none,

                      prefixIcon:
                      const Icon(Icons.lock_outline),

                      hintText: "Enter Password",

                      contentPadding:
                      const EdgeInsets.symmetric(
                        vertical: 22,
                      ),

                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),

                        onPressed: () {

                          setState(() {
                            obscurePassword =
                            !obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                /// FORGOT PASSWORD
                Align(
                  alignment: Alignment.centerRight,

                  child: TextButton(
                    onPressed: () {},

                    child: const Text(
                      "Forgot Password?",
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// LOGIN BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 65,

                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      const Color(0xFF2F78C4),

                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(20),
                      ),
                    ),

                    onPressed:
                    loading ? null : loginUser,

                    child: loading

                        ? const CircularProgressIndicator(
                      color: Colors.white,
                    )

                        : const Text(
                      "Log In",

                      style: TextStyle(
                        fontSize: 26,
                        fontWeight:
                        FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                /// REGISTER TEXT
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.center,

                  children: [

                    const Text(
                      "Don't have account? ",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 18,
                      ),
                    ),

                    GestureDetector(
                      onTap: () {

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                            const RegisterScreen(),
                          ),
                        );
                      },

                      child: const Text(
                        "Register Now",

                        style: TextStyle(
                          color: Color(0xFF2F78C4),
                          fontSize: 18,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}