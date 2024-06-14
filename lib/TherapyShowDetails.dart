import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'add_user_comments.dart'; // Import the AddUserComment widget
import 'booking_done.dart'; // Import the BookingDoneForFirstSessionPage class

class TherapyShowDetails extends StatefulWidget {
  final QueryDocumentSnapshot therapist;

  TherapyShowDetails({required this.therapist});

  @override
  _TherapyShowDetailsState createState() => _TherapyShowDetailsState();
}

class _TherapyShowDetailsState extends State<TherapyShowDetails> {
  bool showAppointments = false;
  List<Map<String, dynamic>> appointments = [];
  Map<String, dynamic>? selectedAppointment;
  List<Map<String, dynamic>> userComments = [];
  double averageRate = 0.0; // Added to store the average rate

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
    _fetchUserComments();
  }

  Future<void> _fetchAppointments() async {
    var collection = FirebaseFirestore.instance.collection('appointments');
    var snapshot = await collection
        .where('therapistId', isEqualTo: widget.therapist.id)
        .get();
    var fetchedAppointments = snapshot.docs
        .map((doc) => {
              'date': doc['date'],
              'time': doc['time'],
              'day': doc['day'],
            })
        .toList();

    setState(() {
      appointments = fetchedAppointments;
    });
  }

  Future<void> _fetchUserComments() async {
    var collection = FirebaseFirestore.instance.collection('addUserComment');
    var snapshot = await collection
        .where('therapistId', isEqualTo: widget.therapist.id)
        .get();
    var fetchedComments = snapshot.docs
        .map((doc) => {
              'comment': doc['comment'],
              'rate': doc['rate'],
              'imageUrl': doc['imageUrl'],
            })
        .toList();

    if (fetchedComments.isNotEmpty) {
      double totalRate = 0.0;
      fetchedComments.forEach((comment) {
        totalRate += double.parse(comment['rate']);
      });
      averageRate = totalRate / fetchedComments.length;
    }

    setState(() {
      userComments = fetchedComments;
    });
  }

  Future<void> _bookAppointment() async {
    if (selectedAppointment != null) {
      // Add the appointment to the 'users' collection and capture the DocumentReference
      DocumentReference appointmentRef =
          await FirebaseFirestore.instance.collection('users').add({
        'therapistId': widget.therapist.id,
        'day': selectedAppointment!['day'],
        'date': selectedAppointment!['date'],
        'time': selectedAppointment!['time'],
      });

      // Use the DocumentReference to get the ID of the newly created document
      String userId = appointmentRef.id;

      // Optionally, update the user's document with the appointment ID if needed
      // For example, if you have a specific user document to update, you can do:
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'userId': userId});

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookingDoneForFirstSessionPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          widget.therapist['name'],
          style: const TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              // Navigator.of(context).push(
              //   MaterialPageRoute(
              //     builder: (context) => NotificationDisplayForTherapy(appointments: []),
              //   ),
              // );
            },
            child: Text(
              'اظهر اشعراتي',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Tajawal',
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: 16, right: 16, bottom: 8, top: 30),
              child: CircleAvatar(
                radius: 90,
                backgroundColor: Colors.grey,
                child: CircleAvatar(
                  radius: 87,
                  backgroundImage: NetworkImage(widget.therapist['imageUrl']),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(children: [
                    const TextSpan(
                      text: 'التخصص : ',
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: '${widget.therapist['specialization']}',
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: Color(0xff494649),
                      ),
                    ),
                  ]),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text(
                  'التقيم : ',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                Text(
                  averageRate.toStringAsFixed(1), // Display the average rate
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: Colors.amber,
                  ),
                ),
                const Icon(Icons.star, color: Colors.amber),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(children: [
                    const TextSpan(
                      text: 'البلد : ',
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: '${widget.therapist['country']}',
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: Color(0xff494649),
                      ),
                    ),
                  ]),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(children: [
                    const TextSpan(
                      text: 'عدد الجلسات : ',
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: '${widget.therapist['sessionsNumber']}',
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: Color(0xff494649),
                      ),
                    ),
                  ]),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(children: [
                    const TextSpan(
                      text: ' سعر الجلسة : ',
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: '${widget.therapist['salary']}ج.م',
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: Color(0xff494649),
                      ),
                    ),
                  ]),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      showAppointments = false;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 8.0),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0XFFD68FFF),
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Text(
                      'التعليقات',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Tajawal',
                        color:
                            showAppointments ? Colors.grey : Color(0XFFD68FFF),
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      showAppointments = true;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 8.0),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0XFFD68FFF),
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Text(
                      'المواعيد المتاحة',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Tajawal',
                        color:
                            showAppointments ? Color(0XFFD68FFF) : Colors.grey,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
                child: showAppointments
                    ? GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // Number of columns
                          crossAxisSpacing:
                              10, // Horizontal space between cards
                          mainAxisSpacing: 10, // Vertical space between cards
                          childAspectRatio: 3 / 2, // Aspect ratio of the cards
                        ),
                        itemCount: appointments.length,
                        itemBuilder: (context, index) {
                          bool isSelected =
                              selectedAppointment == appointments[index];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedAppointment = appointments[index];
                              });
                            },
                            child: Card(
                              color: isSelected
                                  ? const Color(0xffD68FFF)
                                  : const Color.fromARGB(255, 235, 207, 242),
                              margin: const EdgeInsets.all(16.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${appointments[index]['day']}',
                                      style: const TextStyle(
                                        fontFamily: 'Tajawal',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${appointments[index]['date']}',
                                      style: const TextStyle(
                                        fontFamily: 'Tajawal',
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${appointments[index]['time']}',
                                      style: const TextStyle(
                                        fontFamily: 'Tajawal',
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : ListView.builder(
                        itemCount: userComments.length,
                        itemBuilder: (context, index) {
                          return Card(
                            child: ListTile(
                              title: Text(
                                userComments[index]['comment'],
                                style: const TextStyle(
                                      fontFamily: 'Tajawal',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                ),
                              subtitle: Row(
                                children: [
                                  const Text(
                                    'التقييم:',
                                    style: TextStyle(
                                      fontFamily: 'Tajawal',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                  for (int i = 0;
                                      i <
                                          int.parse(
                                              userComments[index]['rate']);
                                      i++)
                                    const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 18,
                                    ),
                                  // Text('التقييم: ${userComments[index]['rate']}'),
                                ],
                              ),
                              leading: CircleAvatar(
                                backgroundImage:
                                    userComments[index]['imageUrl'] != null
                                        ? NetworkImage(
                                            userComments[index]['imageUrl'])
                                        : null,
                              ),
                            ),
                          );
                        },
                      )),
            const SizedBox(height: 10),
            Container(
              width: 500,
              height: 45,
              child: ElevatedButton(
                onPressed: selectedAppointment == null
                    ? null
                    : () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text(
                                ' :سعر الجلسة',
                                style: TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              content: Text(
                                '${widget.therapist['salary']} ج.م',
                                style: const TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('إغلاق'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                        _bookAppointment();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0XFFD68FFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                ),
                child: const Text(
                  'احجز الآن',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  addUserComment(therapistId: widget.therapist.id),
            ),
          );
        },
        tooltip: 'Add Comment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
