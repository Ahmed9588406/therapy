import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

final FirebaseStorage _storage = FirebaseStorage.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class StoreData {
  Future<String> uploadImageToStorage(String childName, Uint8List file) async {
    Reference ref = _storage.ref().child(childName);
    UploadTask uploadTask = ref.putData(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<String> saveData({
    required String comment,
    required Uint8List file,
    required String rate,
  }) async {
    String resp = "Some Error Occurred";
    try {
      if (comment.isNotEmpty) {
        String imageUrl = await uploadImageToStorage('profileImage', file);
        // Create a new document reference with a unique ID
        DocumentReference docRef = _firestore.collection('addUserComment').doc();

        // Set the document with the new ID also stored in 'userCommentId'
        await docRef.set({
          'comment': comment,
          'imageLink': imageUrl,
          'rate': rate,
          'userCommentId': docRef.id, // Store the document's own ID in 'userCommentId'
        });

        resp = 'success';
      }
    } catch (err) {
      resp = err.toString();
    }
    return resp;
  }
}


class addUserComment extends StatefulWidget {
  final String therapistId;
  const addUserComment({super.key, required this.therapistId});

  @override
  State<addUserComment> createState() => _addUserCommentState();
}

class _addUserCommentState extends State<addUserComment> {

  final commentController = TextEditingController();
  final rateController = TextEditingController();
  File? _image;

  @override
  void dispose() {
    commentController.dispose();
    rateController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
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
      Reference ref = storage.ref().child('profileImages/${image.path.split('/').last}');
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
      imageUrl = await _uploadImage(_image!); // Upload the image and get the URL
    }

    // Add to addUserComment collection
    CollectionReference collRef = FirebaseFirestore.instance.collection('addUserComment');
    await collRef.add({
      'comment': commentController.text,
      'rate': rateController.text,
      'imageUrl': imageUrl,
      'userId': 'your_user_doc_id', // This should be fetched or passed as needed
      'therapistId': widget.therapistId, // Use the passed therapistId
    });

    // Optionally, handle navigation or user feedback here
  }

  Future<String?> getUserId() async {
    try {
      var collection = FirebaseFirestore.instance.collection('addUserComment');
      var doc = await collection.doc('users').get(); // You need to know the document ID or have a query to get it
      return doc.data()?['usertId']; // Assuming 'therapistId' is a field in the document
    } catch (e) {
      print("Failed to fetch therapist ID: $e");
      return null;
    }
  }


  @override
  Widget build(BuildContext context) {
       return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Add User Comment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView( // Wrap the column in a SingleChildScrollView
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
                controller: commentController,
                decoration: const InputDecoration(hintText: 'اكتب تعليق'),
              ),
            
              TextFormField(
                controller: rateController,
                decoration: const InputDecoration(hintText: 'التقيم'),
              ),
              
      
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}