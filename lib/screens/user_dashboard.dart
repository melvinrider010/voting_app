import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'login_screen.dart';

class UserDashboard extends StatelessWidget {
  const UserDashboard({super.key});

  @override
  Widget build(BuildContext context) {

    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(

      backgroundColor: const Color(0xFFF5F5F5),

      appBar: AppBar(
        backgroundColor: Colors.indigo,

        title: const Text(
          "User Dashboard",
          style: TextStyle(
            color: Colors.white,
          ),
        ),

        actions: [

          IconButton(
            onPressed: () async {

              await FirebaseAuth.instance
                  .signOut();

              if (!context.mounted) return;

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                  const LoginScreen(),
                ),
              );
            },

            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(

        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [

              /// PROFILE CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: Colors.indigo,

                  borderRadius:
                  BorderRadius.circular(25),
                ),

                child: Column(
                  children: [

                    const CircleAvatar(
                      radius: 40,
                      backgroundColor:
                      Colors.white,

                      child: Icon(
                        Icons.person,
                        size: 45,
                        color: Colors.indigo,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Text(
                      user?.displayName ??
                          "User",

                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      user?.email ?? "",

                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              /// LIVE STATUS CARD
              StreamBuilder<DocumentSnapshot>(

                stream: FirebaseFirestore.instance
                    .collection("users")
                    .doc(user!.uid)
                    .snapshots(),

                builder: (context, snapshot) {

                  if (!snapshot.hasData) {

                    return const Center(
                      child:
                      CircularProgressIndicator(),
                    );
                  }

                  var data =
                  snapshot.data!;

                  bool verified =
                      data["verified"] ?? false;

                  return Container(
                    padding:
                    const EdgeInsets.all(18),

                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius:
                      BorderRadius.circular(20),

                      boxShadow: [
                        BoxShadow(
                          color:
                          Colors.black.withOpacity(
                            0.05,
                          ),
                          blurRadius: 10,
                        ),
                      ],
                    ),

                    child: Row(
                      children: [

                        Icon(
                          verified
                              ? Icons.verified
                              : Icons.pending,

                          color: verified
                              ? Colors.green
                              : Colors.orange,

                          size: 40,
                        ),

                        const SizedBox(width: 15),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,

                            children: [

                              Text(
                                verified
                                    ? "Verified User"
                                    : "Verification Pending",

                                style:
                                const TextStyle(
                                  fontSize: 20,
                                  fontWeight:
                                  FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 5),

                              Text(
                                verified
                                    ? "You can participate in voting."
                                    : "Admin verification is pending.",
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),

              /// ACTIVE ELECTIONS TITLE
              const Text(
                "Active Elections",

                style: TextStyle(
                  fontSize: 24,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              /// ACTIVE POLLS
              StreamBuilder<QuerySnapshot>(

                stream: FirebaseFirestore
                    .instance
                    .collection("polls")
                    .where(
                  "active",
                  isEqualTo: true,
                )
                    .snapshots(),

                builder: (context, snapshot) {

                  if (!snapshot.hasData) {

                    return const Center(
                      child:
                      CircularProgressIndicator(),
                    );
                  }

                  var polls =
                      snapshot.data!.docs;

                  if (polls.isEmpty) {

                    return Container(
                      width: double.infinity,
                      padding:
                      const EdgeInsets.all(20),

                      decoration: BoxDecoration(
                        color: Colors.white,

                        borderRadius:
                        BorderRadius.circular(20),
                      ),

                      child: const Text(
                        "No active elections available.",
                      ),
                    );
                  }

                  return Column(

                    children: polls.map((poll) {

                      return Container(

                        margin:
                        const EdgeInsets.only(
                          bottom: 15,
                        ),

                        padding:
                        const EdgeInsets.all(18),

                        decoration: BoxDecoration(
                          color: Colors.white,

                          borderRadius:
                          BorderRadius.circular(
                            20,
                          ),

                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withOpacity(
                                0.05,
                              ),

                              blurRadius: 8,
                            ),
                          ],
                        ),

                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,

                          children: [

                            Text(
                              poll["title"],

                              style:
                              const TextStyle(
                                fontSize: 22,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),

                            const SizedBox(
                              height: 10,
                            ),

                            Text(
                              poll["description"],
                            ),

                            const SizedBox(
                              height: 15,
                            ),

                            SizedBox(
                              width:
                              double.infinity,

                              child:
                              ElevatedButton(

                                style:
                                ElevatedButton
                                    .styleFrom(
                                  backgroundColor:
                                  Colors.indigo,
                                ),

                                onPressed: () {

                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(

                                    const SnackBar(
                                      content: Text(
                                        "Voting screen coming next.",
                                      ),
                                    ),
                                  );
                                },

                                child: const Text(
                                  "Vote Now",

                                  style: TextStyle(
                                    color:
                                    Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: 30),

              /// NEWS TITLE
              const Text(
                "Latest News",

                style: TextStyle(
                  fontSize: 24,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              /// NEWS SECTION
              StreamBuilder<QuerySnapshot>(

                stream: FirebaseFirestore
                    .instance
                    .collection("news")
                    .snapshots(),

                builder: (context, snapshot) {

                  if (!snapshot.hasData) {

                    return const Center(
                      child:
                      CircularProgressIndicator(),
                    );
                  }

                  var news =
                      snapshot.data!.docs;

                  if (news.isEmpty) {

                    return const Text(
                      "No news available",
                    );
                  }

                  return Column(

                    children: news.map((item) {

                      return Container(

                        margin:
                        const EdgeInsets.only(
                          bottom: 15,
                        ),

                        padding:
                        const EdgeInsets.all(18),

                        decoration: BoxDecoration(
                          color: Colors.white,

                          borderRadius:
                          BorderRadius.circular(
                            20,
                          ),

                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withOpacity(
                                0.05,
                              ),

                              blurRadius: 8,
                            ),
                          ],
                        ),

                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,

                          children: [

                            Text(
                              item["title"],

                              style:
                              const TextStyle(
                                fontSize: 20,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),

                            const SizedBox(
                              height: 10,
                            ),

                            Text(
                              item["description"],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}