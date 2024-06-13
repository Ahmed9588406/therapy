import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:therapy/display_info_for_therapy.dart'; 

class TableProfileTherapists extends StatefulWidget {
  final dynamic therapist;

  const TableProfileTherapists({super.key, required this.therapist});

  @override
  State<TableProfileTherapists> createState() => _TableProfileTherapistsState(therapist: therapist);
}

class _TableProfileTherapistsState extends State<TableProfileTherapists> {
  final dynamic therapist;
  int _selectedIndex = 0;  // Default index set to 0

  _TableProfileTherapistsState({required this.therapist});

  @override
  Widget build(BuildContext context) {
    return   Scaffold(
    appBar: AppBar(
        backgroundColor:
            Colors.white, // Set the AppBar background color to white
      ),
      backgroundColor: Colors.white, // Set the background color of the page
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('therapists').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No therapists found'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var therapist = snapshot.data!.docs[index];
              var imageUrl = therapist['imageUrl'] ?? 'https://via.placeholder.com/150'; // Default image URL
              var name = therapist['name'] ?? 'Unknown';
              var specialization = therapist['specialization'] ?? 'Unknown';
              var rate = therapist['rate']?.toString() ?? '0';

              return Padding(
                padding: const EdgeInsets.all(
                    8.0), // Add padding around each container
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 0,
                        blurRadius: 4,
                        offset: Offset(0, 5), // changes position of shadow
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(
                            Radius.circular(10)), // Rounded corners
                        color: Colors.grey,
                      ),
                      height: 130,
                      width: 90,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(
                            10)), // Match container's rounded corners
                        child: SizedBox(
                          height: 80, // Set your desired height here
                          width:
                              90, // Maintain the width to match the container
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit
                                .cover, // This will cover the entire space of the container
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      name,
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 14, // Set the font size
                        fontWeight: FontWeight.bold, // Make the text bold
                      ),
                    ),
                    subtitle: Text(
                      'التخصص: $specialization',
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 12, // Set the font size
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(rate),
                        Icon(Icons.star, color: Colors.amber),
                      ],
                    ),
                    onTap: () {
                      Fluttertoast.showToast(
                          msg: "أهلا بيك في صفحة الاطباء",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity:
                              ToastGravity.TOP, // Changed from BOTTOM to TOP
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.grey[800],
                          textColor: Colors.white,
                          fontSize: 16.0);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TherapistProfilePage(
                            therapistId: therapist.id, // Assuming 'id' is the field name for the therapist's ID in Firestore
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      
    );
  }
}
