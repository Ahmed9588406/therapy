import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class TherapistProfilePage extends StatefulWidget {
  final String therapistId;

  const TherapistProfilePage({Key? key, required this.therapistId}) : super(key: key);

  @override
  _TherapistProfilePageState createState() => _TherapistProfilePageState();
}

class _TherapistProfilePageState extends State<TherapistProfilePage> {
  late String imageUrl;

  @override
  void initState() {
    super.initState();
    imageUrl = '';
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      // Upload image to Firebase Storage
      String fileName = 'therapists/${widget.therapistId}/${DateTime.now().millisecondsSinceEpoch.toString()}';
      FirebaseStorage storage = FirebaseStorage.instance;
      try {
        await storage.ref(fileName).putFile(imageFile);
        String downloadUrl = await storage.ref(fileName).getDownloadURL();
        setState(() {
          imageUrl = downloadUrl;
        });
        // Update Firestore document
        FirebaseFirestore.instance.collection('therapists').doc(widget.therapistId).update({'imageUrl': downloadUrl});
      } catch (e) {
        print(e); // Handle errors
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Therapist Profile'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('therapists').doc(widget.therapistId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching data'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No data found'));
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;
          imageUrl = data['imageUrl'] ?? '';
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        GestureDetector(
                          onTap: pickImage,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                            child: imageUrl.isEmpty ? const Icon(Icons.person, size: 50) : null,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: pickImage,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('الاسم : ${data['name']}', style: const TextStyle(fontSize: 18)),
                  Text('التخصص : ${data['specialization']}', style: const TextStyle(fontSize: 18)),
                  Row(
                    children: [
                      const Text('التقيم : ', style: TextStyle(fontSize: 18)),
                      for (int i = 0; i < int.parse(data['rate']); i++)
                        const Icon(Icons.star, color: Colors.amber),
                    ],
                  ),
                  Text('البلد : ${data['country']}', style: const TextStyle(fontSize: 18)),
                  Text('عدد الجلسات : ${data['sessionsNumber']}', style: const TextStyle(fontSize: 18)),
                  Text('مدة الجلسة التي تريدها : ${data['timeforsession']} ساعة', style: const TextStyle(fontSize: 18)),
                  Text('سعر الجلسة : ${data['salary']} ج.م', style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 20),
                  const Text('مواعيدي المتاحة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  // Add your available times UI here
                  const SizedBox(height: 20),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                       Column(
                        children: [
                          Text('الاثنين'),
                          Text('03'),
                          Text('10:00 ص'),
                        ],
                      ),
                      const Column(
                        children: [
                          Text('الثلاثاء'),
                          Text('04'),
                          Text('11:00 ص'),
                        ],
                      ),
                       Column(
                        children: [
                          Text('الاربعاء'),
                          Text('05'),
                          Text('12:00 م'),
                        ],
                      ),
                       Column(
                        children: [
                          Text('الخميس'),
                          Text('06'),
                          Text('01:00 م'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
