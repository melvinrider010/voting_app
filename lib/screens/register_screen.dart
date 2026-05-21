import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends State<RegisterScreen> {

  final TextEditingController nameController =
  TextEditingController();

  final TextEditingController emailController =
  TextEditingController();

  final TextEditingController passwordController =
  TextEditingController();

  bool obscurePassword = true;
  bool loading = false;

  // REGISTER USER
  Future<void> registerUser() async {

    try {

      setState(() {
        loading = true;
      });

      UserCredential userCredential =
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      User? user = userCredential.user;

      // SAVE NAME
      await user!.updateDisplayName(
        nameController.text.trim(),
      );

      // SAVE USER DATA TO FIRESTORE
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .set({

        "name": nameController.text.trim(),
        "email": emailController.text.trim(),
        "role": "user",
        "verified": false,
        "idType": "",
        "idImage": "",

      });

      // SEND EMAIL VERIFICATION
      await user.sendEmailVerification();

      setState(() {
        loading = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Verification email sent. Please verify and login.",
          ),
        ),
      );

      Navigator.pop(context);

    } on FirebaseAuthException catch (e) {

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e.message ?? "Registration Failed",
          ),
        ),
      );

    } catch (e) {

      setState(() {
        loading = false;
      });

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
                  "Register",
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0B1D26),
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Create your secure voting account.",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 40),

                /// NAME FIELD
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F2),
                    borderRadius:
                    BorderRadius.circular(18),
                  ),

                  child: TextField(
                    controller: nameController,

                    decoration: const InputDecoration(
                      border: InputBorder.none,

                      prefixIcon:
                      Icon(Icons.person_outline),

                      hintText: "Enter your Name",

                      contentPadding:
                      EdgeInsets.symmetric(
                        vertical: 22,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

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

                      hintText: "Create Password",

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

                const SizedBox(height: 35),

                /// REGISTER BUTTON
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

                    onPressed: loading
                        ? null
                        : registerUser,

                    child: loading
                        ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                        : const Text(
                      "Register",
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

                /// LOGIN TEXT
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.center,

                  children: [

                    const Text(
                      "Already have account? ",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 18,
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },

                      child: const Text(
                        "Login",
                        style: TextStyle(
                          color: Color(0xFF2F78C4),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
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