import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:therapy/TableProfileTherapists.dart';
import 'package:therapy/mood_tracker.dart';
import 'package:therapy/wallet_page.dart';

import 'TableTherapySelection.dart';
import 'display_info_for_therapy.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initializeDateFormatting('ar', null); // Initialize Arabic locale

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
      locale: const Locale('ar', ''), // Set Arabic as the default locale
      supportedLocales: [
        const Locale('ar', ''), // Arabic
        const Locale('en', ''), // English
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final nameController = TextEditingController();
  final specializationController = TextEditingController();
  final rateController = TextEditingController();
  final sessionsNumberController = TextEditingController();
  final salaryController = TextEditingController();
  final countryController = TextEditingController();
  final timeforsessionController = TextEditingController();
  File? _image;

  @override
  void dispose() {
    nameController.dispose();
    specializationController.dispose();
    rateController.dispose();
    sessionsNumberController.dispose();
    salaryController.dispose();
    countryController.dispose();
    timeforsessionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(File image) async {
    try {
      final FirebaseStorage storage = FirebaseStorage.instance;
      final Uint8List imageData = await image.readAsBytes();
      Reference ref =
          storage.ref().child('profileImages/${image.path.split('/').last}');
      UploadTask uploadTask = ref.putData(imageData);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _submitForm() async {
    String? imageUrl;
    if (_image != null) {
      imageUrl =
          await _uploadImage(_image!); // Upload the image and get the URL
    }

    CollectionReference collRef =
        FirebaseFirestore.instance.collection('therapists');
    DocumentReference docRef = await collRef.add({
      'name': nameController.text,
      'specialization': specializationController.text,
      'rate': rateController.text,
      'sessionsNumber': sessionsNumberController.text,
      'salary': salaryController.text,
      'country': countryController.text,
      'timeforsession': timeforsessionController.text,
      'imageUrl': imageUrl, // Add the imageUrl to the Firestore document
    });

    // Use the document ID from the newly created document
    String therapistId = docRef.id;

    // Update the document with the therapistId
    await docRef.update({'therapistId': therapistId});

    // Navigate to the TherapistProfilePage with the new therapistId
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => TherapistProfilePage(therapistId: therapistId)),
    );
  }

  Future<String?> getTherapistId() async {
    try {
      var collection = FirebaseFirestore.instance.collection('therapists');
      var doc = await collection
          .doc('specific_doc_id')
          .get(); // You need to know the document ID or have a query to get it
      return doc.data()?[
          'therapistId']; // Assuming 'therapistId' is a field in the document
    } catch (e) {
      print("Failed to fetch therapist ID: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> getTherapist() async {
    try {
      var collection = FirebaseFirestore.instance.collection('therapists');
      var querySnapshot =
          await collection.where('someField', isEqualTo: 'someValue').get();
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first
            .data(); // Returns the first therapist's data as a map
      }
      return null;
    } catch (e) {
      print("Failed to fetch therapist: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          // Wrap the column in a SingleChildScrollView
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _image != null ? FileImage(_image!) : null,
                  child: _image == null
                      ? const Icon(Icons.add_a_photo, size: 50)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(hintText: 'الاسم'),
              ),
              TextFormField(
                controller: specializationController,
                decoration: const InputDecoration(hintText: 'التخصص'),
              ),
              TextFormField(
                controller: rateController,
                decoration: const InputDecoration(hintText: 'التقيم'),
              ),
              TextFormField(
                controller: sessionsNumberController,
                decoration: const InputDecoration(hintText: 'عدد الجلسات'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: salaryController,
                decoration: const InputDecoration(hintText: 'سعر الجلسة'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: countryController,
                decoration: const InputDecoration(hintText: 'البلد'),
              ),
              TextFormField(
                controller: timeforsessionController,
                decoration:
                    const InputDecoration(hintText: 'مدة اجلسة التس تريدها'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Submit'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TableTherapySelection()),
                  );
                },
                child: const Text('Display Info for Therapy'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  var therapist =
                      await getTherapist(); // Ensure you have a method to fetch or create a therapist object
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            TableProfileTherapists(therapist: therapist)),
                  );
                },
                child: const Text('Table Profile Therapist'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MoodTrackerPage()),
                  );
                },
                child: const Text('Mood Tracker'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => WalletScreen()),
                  );
                },
                child: const Text('E Wallet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
