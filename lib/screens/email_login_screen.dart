import 'package:flutter/material.dart';
import 'email_verification_screen.dart';

class EmailLoginScreen extends StatefulWidget {
  const EmailLoginScreen({super.key});

  @override
  State<EmailLoginScreen> createState() =>
      _EmailLoginScreenState();
}

class _EmailLoginScreenState
    extends State<EmailLoginScreen> {
  final TextEditingController emailController =
  TextEditingController();

  final GlobalKey<FormState> _formKey =
  GlobalKey<FormState>();

  bool isLoading = false;

  bool isValidEmail(String email) {
    return RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+\-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    ).hasMatch(email);
  }

  Future<void> continueToEmailVerification() async {
    final email = emailController.text.trim();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    await Future.delayed(
      const Duration(seconds: 1),
    );

    setState(() {
      isLoading = false;
    });

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EmailVerificationScreen(
          email: email,
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
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
            child: SingleChildScrollView(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 25,
              ),

              child: Column(
                children: [
                  const Icon(
                    Icons.how_to_vote_rounded,
                    size: 100,
                    color: Colors.white,
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Voting App",
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Secure Email Verification",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 50),

                  Container(
                    padding:
                    const EdgeInsets.all(25),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                      BorderRadius.circular(25),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withOpacity(0.1),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),

                    child: Form(
                      key: _formKey,

                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,

                        children: [
                          const Text(
                            "Enter Your Email",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 10),

                          const Text(
                            "A verification email will be sent securely",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),

                          const SizedBox(height: 30),

                          TextFormField(
                            controller:
                            emailController,

                            keyboardType:
                            TextInputType
                                .emailAddress,

                            decoration:
                            InputDecoration(
                              hintText:
                              "Enter your email",

                              prefixIcon:
                              const Icon(
                                Icons
                                    .email_outlined,
                              ),

                              filled: true,

                              fillColor:
                              Colors.grey
                                  .shade100,

                              border:
                              OutlineInputBorder(
                                borderRadius:
                                BorderRadius
                                    .circular(
                                    15),

                                borderSide:
                                BorderSide
                                    .none,
                              ),
                            ),

                            validator:
                                (value) {
                              if (value ==
                                  null ||
                                  value
                                      .isEmpty) {
                                return "Please enter email";
                              }

                              if (!isValidEmail(
                                  value)) {
                                return "Enter valid email";
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 30),

                          SizedBox(
                            width:
                            double.infinity,
                            height: 55,

                            child:
                            ElevatedButton(
                              style:
                              ElevatedButton
                                  .styleFrom(
                                backgroundColor:
                                Colors
                                    .deepPurple,

                                shape:
                                RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius
                                      .circular(
                                      15),
                                ),
                              ),

                              onPressed:
                              isLoading
                                  ? null
                                  : continueToEmailVerification,

                              child: isLoading
                                  ? const CircularProgressIndicator(
                                color:
                                Colors
                                    .white,
                              )
                                  : const Text(
                                "Continue",
                                style:
                                TextStyle(
                                  fontSize:
                                  18,
                                  fontWeight:
                                  FontWeight
                                      .bold,
                                  color: Colors
                                      .white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    "Powered by Firebase Authentication",
                    style: TextStyle(
                      color: Colors.white70,
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