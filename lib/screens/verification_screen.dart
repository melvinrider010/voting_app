import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'user_dashboard.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() =>
      _VerificationScreenState();
}

class _VerificationScreenState
    extends State<VerificationScreen> {

  String selectedId = "Aadhaar Card";

  File? selectedImage;

  bool loading = false;

  // PICK IMAGE
  Future<void> pickImage(
      ImageSource source) async {

    final picker = ImagePicker();

    final pickedFile =
    await picker.pickImage(
      source: source,
      imageQuality: 70,
    );

    if (pickedFile != null) {

      setState(() {
        selectedImage =
            File(pickedFile.path);
      });
    }
  }

  // SHOW OPTIONS
  void showPickerOptions() {

    showModalBottomSheet(
      context: context,

      builder: (context) {

        return SafeArea(
          child: Wrap(
            children: [

              ListTile(
                leading:
                const Icon(Icons.camera_alt),

                title:
                const Text("Camera"),

                onTap: () {

                  Navigator.pop(context);

                  pickImage(
                    ImageSource.camera,
                  );
                },
              ),

              ListTile(
                leading:
                const Icon(Icons.photo),

                title:
                const Text("Gallery"),

                onTap: () {

                  Navigator.pop(context);

                  pickImage(
                    ImageSource.gallery,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // SUBMIT VERIFICATION
  Future<void> submitVerification()
  async {

    if (selectedImage == null) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Please upload ID image",
          ),
        ),
      );

      return;
    }

    try {

      setState(() {
        loading = true;
      });

      User? user =
          FirebaseAuth.instance.currentUser;

      // CONVERT IMAGE TO BASE64
      List<int> imageBytes =
      await selectedImage!.readAsBytes();

      String base64Image =
      base64Encode(imageBytes);

      // SAVE TO FIRESTORE
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .update({

        "idType": selectedId,
        "idImage": base64Image,
        "verified": false,

      });

      setState(() {
        loading = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Verification submitted successfully",
          ),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
          const UserDashboard(),
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

      appBar: AppBar(
        backgroundColor: Colors.indigo,

        title: const Text(
          "ID Verification",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),

      body: Padding(
        padding:
        const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            const Text(
              "Verify Your Identity",

              style: TextStyle(
                fontSize: 32,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Upload your Aadhaar, PAN or Voter ID for secure voting verification.",
            ),

            const SizedBox(height: 30),

            DropdownButtonFormField(
              value: selectedId,

              items: const [

                DropdownMenuItem(
                  value: "Aadhaar Card",
                  child:
                  Text("Aadhaar Card"),
                ),

                DropdownMenuItem(
                  value: "PAN Card",
                  child:
                  Text("PAN Card"),
                ),

                DropdownMenuItem(
                  value: "Voter ID",
                  child:
                  Text("Voter ID"),
                ),
              ],

              onChanged: (value) {

                setState(() {
                  selectedId = value!;
                });
              },
            ),

            const SizedBox(height: 30),

            GestureDetector(

              onTap: showPickerOptions,

              child: Container(
                height: 220,
                width: double.infinity,

                decoration: BoxDecoration(
                  borderRadius:
                  BorderRadius.circular(20),

                  border: Border.all(
                    color: Colors.grey,
                  ),
                ),

                child: selectedImage != null

                    ? ClipRRect(
                  borderRadius:
                  BorderRadius.circular(
                    20,
                  ),

                  child: Image.file(
                    selectedImage!,
                    fit: BoxFit.cover,
                  ),
                )

                    : const Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,

                  children: [

                    Icon(
                      Icons.upload_file,
                      size: 60,
                      color: Colors.grey,
                    ),

                    SizedBox(height: 10),

                    Text(
                      "Tap to Upload ID",
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 60,

              child: ElevatedButton(

                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  Colors.indigo,
                ),

                onPressed: loading
                    ? null
                    : submitVerification,

                child: loading

                    ? const CircularProgressIndicator(
                  color: Colors.white,
                )

                    : const Text(
                  "Submit Verification",

                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}