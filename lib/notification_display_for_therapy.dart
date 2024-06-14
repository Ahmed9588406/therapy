import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'display_info_for_therapy.dart';

class NotificationDisplayForTherapy extends StatefulWidget {
  final List<Map<String, dynamic>> appointments;
  final String therapistId; // Add this line

  NotificationDisplayForTherapy(
      {required this.appointments,
      required this.therapistId}); // Modify this line

  @override
  _NotificationDisplayForTherapyState createState() =>
      _NotificationDisplayForTherapyState();
}

class _NotificationDisplayForTherapyState
    extends State<NotificationDisplayForTherapy> {
  void _removeAppointment(int index) {
    setState(() {
      widget.appointments.removeAt(index);
    });
  }

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext) {
              return TherapistProfilePage(
                therapistId: '',
              );
              // return TherapistSettingsPage();
            },
          ),
        );
        break;

      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext) {
              return TherapistProfilePage(
                therapistId: '',
              );
              // return TherapistNotificationsEmptyPage();
            },
          ),
        );

        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) {
              return FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('appointments')
                    .where('therapistId', isEqualTo: widget.therapistId)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  var appointmentsList = snapshot.data!.docs
                      .map((doc) => doc.data() as Map<String, dynamic>)
                      .toList();
                  return NotificationDisplayForTherapy(
                      appointments: appointmentsList,
                      therapistId: widget.therapistId);
                },
              );
            },
          ),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext) {
              return TherapistProfilePage(
                therapistId: '',
              );
              // return ProfileForTherapistFlowPage();
            },
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: widget.appointments.length,
        itemBuilder: (context, index) {
          var appointment = widget.appointments[index];
          return Dismissible(
            key: Key(appointment['date'] +
                appointment['time']), // Unique key for Dismissible
            onDismissed: (direction) {
              _removeAppointment(index);
            },
            background: Container(color: Colors.red),
            child: Card(
              color: Color.fromARGB(255, 239, 226, 243),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.calendar_today),
                    // title: Text('Date: ${appointment['date']}'),
                    // subtitle: Text('Time: ${appointment['time']} - Day: ${appointment['day']}'),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                        'هناك حجز في ${appointment['date']} الساعة ${appointment['time']} يوم ${appointment['day']}',
                        style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)
                    ),
                  ),
                  ButtonBar(
                    alignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TextButton(
                        child: Text('قبول',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                            Color(0xFFD68FFF),
                          ),
                          // Set background color to green for Accept button
                        ),
                        onPressed: () {
                          // Add your acceptance action here
                        },
                      ),
                      TextButton(
                        child: Text(
                          'رفض',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                            Color(0xFFD68FFF),
                          ), // Set background color to red for Reject button
                        ),
                        onPressed: () {
                          // Add your rejection action here
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
        onTap: _onItemTapped,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person_outline_outlined,
              color:
                  _selectedIndex == 0 ? Color(0xffD68FFF) : Color(0xffE8E0E5),
              size: 27,
            ),
            label: 'الملف الشخصي',
            backgroundColor:
                _selectedIndex == 0 ? Color(0xffD68FFF) : Color(0xffE8E0E5),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.date_range_outlined,
              color:
                  _selectedIndex == 1 ? Color(0xffD68FFF) : Color(0xffE8E0E5),
              size: 23,
            ),
            label: 'الجلسات',
            backgroundColor:
                _selectedIndex == 1 ? Color(0xffD68FFF) : Color(0xffE8E0E5),
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(
          //     Icons.notifications_none,
          //     color:
          //         _selectedIndex == 2 ? Color(0xffD68FFF) : Color(0xffE8E0E5),
          //     size: 27,
          //   ),
          //   label: 'اشعارات',
          //   backgroundColor:
          //       _selectedIndex == 2 ? Color(0xffD68FFF) : Color(0xffE8E0E5),
          // ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.notifications_active,
              color:
                  _selectedIndex == 2 ? Color(0xffD68FFF) : Color(0xffE8E0E5),
              size: 27,
            ),
            label: 'اشعراتي',
            backgroundColor:
                _selectedIndex == 2 ? Color(0xffD68FFF) : Color(0xffE8E0E5),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.settings_outlined,
              color:
                  _selectedIndex == 3 ? Color(0xffD68FFF) : Color(0xffE8E0E5),
              size: 27,
            ),
            label: 'الاعدادات',
            backgroundColor:
                _selectedIndex == 3 ? Color(0xffD68FFF) : Color(0xffE8E0E5),
          ),
        ],
      ),
    );
  }
}
