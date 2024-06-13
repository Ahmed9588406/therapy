import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Added import for flutter_svg
import 'package:fluttertoast/fluttertoast.dart';
import 'TherapyShowDetails.dart'; // Import the TherapistProfilePage

class TableTherapySelection extends StatefulWidget {
  @override
  _TableTherapySelectionState createState() => _TableTherapySelectionState();
}

class _TableTherapySelectionState extends State<TableTherapySelection> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  dynamic getFieldFromDocument(DocumentSnapshot doc, String fieldName) {
    if (doc.exists) {
      var data = doc.data() as Map<String, dynamic>;
      return data[fieldName]; // Return null if fieldName does not exist
    } else {
      throw StateError('Document does not exist');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              var imageUrl = getFieldFromDocument(therapist, 'imageUrl') ??
                  'https://via.placeholder.com/150'; // Default image URL
              var name = getFieldFromDocument(therapist, 'name') ?? 'Unknown';
              var specialization = getFieldFromDocument(therapist, 'specialization') ?? 'Unknown';
              var rate = getFieldFromDocument(therapist, 'rate')?.toString() ?? '0';

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
                          builder: (context) => TherapyShowDetails(
                            therapist: therapist, // Pass the entire therapist DocumentSnapshot
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
        bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Color(0xFF1D1B1E),
        selectedItemColor: Color(0xFFD68FFF),
        unselectedItemColor: Color(0xFFE8E0E5),
        selectedFontSize: 14,
        unselectedFontSize: 14,
        currentIndex: _selectedIndex,
        onTap: (index) => _onItemTapped(index),
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/images/home.svg',
              width: 24.0,
              height: 24.0,
              color:
                  _selectedIndex == 4 ? Color(0xffD68FFF) : Color(0xffE8E0E5),
            ),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/images/mynotes.svg',
              width: 24.0,
              height: 24.0,
              color:
                  _selectedIndex == 3 ? Color(0xffD68FFF) : Color(0xffE8E0E5),
            ),
            label: 'ملاحظاتي',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/images/yourmessage.svg',
              width: 24.0,
              height: 24.0,
              color:
                  _selectedIndex == 2 ? Color(0xffD68FFF) : Color(0xffE8E0E5),
            ),
            label: 'رساله لك',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/images/learn.svg',
              width: 24.0,
              height: 24.0,
              color:
                  _selectedIndex == 1 ? Color(0xffD68FFF) : Color(0xffE8E0E5),
            ),
            label: 'تعلم',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/images/therapist.svg',
              width: 24.0,
              height: 24.0,
              color:
                  _selectedIndex == 0 ? Color(0xffD68FFF) : Color(0xffE8E0E5),
            ),
            label: 'المعالج',
          ),
        ],
      ),
    );
  }
}



