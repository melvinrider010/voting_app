import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminVerificationScreen extends StatelessWidget {
  const AdminVerificationScreen({super.key});

  // APPROVE USER
  Future<void> approveUser(String uid) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .update({
      "verified": true,
    });
  }

  // REJECT USER
  Future<void> rejectUser(String uid) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        backgroundColor: Colors.indigo,

        title: const Text(
          "Admin Verification",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .where("role", isEqualTo: "user")
            .snapshots(),

        builder: (context, snapshot) {

          if (snapshot.connectionState ==
              ConnectionState.waiting) {

            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {

            return const Center(
              child: Text(
                "No verification requests",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(15),

            itemCount: users.length,

            itemBuilder: (context, index) {

              final user = users[index];

              final data =
              user.data() as Map<String, dynamic>;

              String name =
                  data["name"] ?? "No Name";

              String email =
                  data["email"] ?? "No Email";

              String idType =
                  data["idType"] ?? "Unknown ID";

              String idImage =
                  data["idImage"] ?? "";

              bool verified =
                  data["verified"] ?? false;

              return Container(
                margin:
                const EdgeInsets.only(bottom: 20),

                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius:
                  BorderRadius.circular(24),

                  boxShadow: [
                    BoxShadow(
                      color:
                      Colors.black.withOpacity(0.06),

                      blurRadius: 10,
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    /// TOP ROW
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,

                      children: [

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,

                            children: [

                              Text(
                                name,

                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight:
                                  FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                email,

                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          padding:
                          const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),

                          decoration: BoxDecoration(
                            color: verified
                                ? Colors.green
                                .withOpacity(0.15)
                                : Colors.orange
                                .withOpacity(0.15),

                            borderRadius:
                            BorderRadius.circular(30),
                          ),

                          child: Text(
                            verified
                                ? "VERIFIED"
                                : "PENDING",

                            style: TextStyle(
                              color: verified
                                  ? Colors.green
                                  : Colors.orange,

                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    /// ID TYPE
                    Row(
                      children: [

                        const Icon(
                          Icons.badge,
                          color: Colors.indigo,
                        ),

                        const SizedBox(width: 10),

                        Text(
                          "ID Type: $idType",

                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight:
                            FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    /// IMAGE
                    ClipRRect(
                      borderRadius:
                      BorderRadius.circular(18),

                      child: Container(
                        height: 230,
                        width: double.infinity,
                        color: Colors.grey.shade200,

                        child: idImage.isNotEmpty

                            ? Image.file(
                          File(idImage),
                          fit: BoxFit.cover,

                          errorBuilder:
                              (
                              context,
                              error,
                              stackTrace,
                              ) {

                            return Column(
                              mainAxisAlignment:
                              MainAxisAlignment.center,

                              children: const [

                                Icon(
                                  Icons.broken_image,
                                  size: 70,
                                  color: Colors.grey,
                                ),

                                SizedBox(height: 10),

                                Text(
                                  "Image Not Found",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            );
                          },
                        )

                            : Column(
                          mainAxisAlignment:
                          MainAxisAlignment.center,

                          children: const [

                            Icon(
                              Icons.image_not_supported,
                              size: 70,
                              color: Colors.grey,
                            ),

                            SizedBox(height: 10),

                            Text(
                              "No Image Uploaded",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// BUTTONS
                    Row(
                      children: [

                        /// APPROVE
                        Expanded(
                          child: ElevatedButton(
                            style:
                            ElevatedButton.styleFrom(
                              backgroundColor:
                              Colors.green,

                              padding:
                              const EdgeInsets.symmetric(
                                vertical: 15,
                              ),

                              shape:
                              RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(
                                  18,
                                ),
                              ),
                            ),

                            onPressed: () async {

                              await approveUser(
                                user.id,
                              );

                              if (!context.mounted) return;

                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "User Approved Successfully",
                                  ),
                                ),
                              );
                            },

                            child: const Text(
                              "Approve",

                              style: TextStyle(
                                color: Colors.white,
                                fontWeight:
                                FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 15),

                        /// REJECT
                        Expanded(
                          child: ElevatedButton(
                            style:
                            ElevatedButton.styleFrom(
                              backgroundColor:
                              Colors.red,

                              padding:
                              const EdgeInsets.symmetric(
                                vertical: 15,
                              ),

                              shape:
                              RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(
                                  18,
                                ),
                              ),
                            ),

                            onPressed: () async {

                              await rejectUser(
                                user.id,
                              );

                              if (!context.mounted) return;

                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "User Rejected",
                                  ),
                                ),
                              );
                            },

                            child: const Text(
                              "Reject",

                              style: TextStyle(
                                color: Colors.white,
                                fontWeight:
                                FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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