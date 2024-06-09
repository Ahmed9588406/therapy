import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'TherapyShowDetails.dart'; // Import the details page
import 'package:fluttertoast/fluttertoast.dart';

class TableTherapySelection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Table Therapy Selection'),
      ),
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
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(therapist['imageUrl']),
                ),
                title: Text(therapist['name']),
                subtitle: Text('التخصص: ${therapist['specialization']}'),
                trailing: Row(
                  
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(therapist['rate'].toString()),
                    Icon(Icons.star, color: Colors.amber),
                  ],
                ),
                onTap: () {
                  Fluttertoast.showToast(
                    msg: "أهلا بيك في صفحة الاطباء",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.TOP, // Changed from BOTTOM to TOP
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.grey[800],
                    textColor: Colors.white,
                    fontSize: 16.0
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TherapyShowDetails(therapist: therapist), // Pass the therapist data
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}