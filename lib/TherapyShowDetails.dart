import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'notification_display_for_therapy.dart';

class TherapyShowDetails extends StatefulWidget {
  final QueryDocumentSnapshot therapist;

  TherapyShowDetails({required this.therapist});

  @override
  _TherapyShowDetailsState createState() => _TherapyShowDetailsState();
}

class _TherapyShowDetailsState extends State<TherapyShowDetails> {
  bool showAppointments = false;
  List<Map<String, dynamic>> appointments = [];
  Map<String, dynamic>? selectedAppointment; // Variable to store selected appointment

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    var collection = FirebaseFirestore.instance.collection('appointments');
    var snapshot = await collection.where('therapistId', isEqualTo: widget.therapist.id).get();
    var fetchedAppointments = snapshot.docs.map((doc) => {
      'date': doc['date'],
      'time': doc['time'],
      'day': doc['day'],
    }).toList();

    setState(() {
      appointments = fetchedAppointments;
    });
  }

  void _bookAppointment() async {
    if (selectedAppointment != null) {
      // Create a new document in the 'users' collection
      DocumentReference docRef = await FirebaseFirestore.instance.collection('users').add({
        'date': selectedAppointment!['date'],
        'time': selectedAppointment!['time'],
        'day': selectedAppointment!['day'],
      });

      // Update the newly created document with its own document ID
      await docRef.update({
        'userId': docRef.id, // Setting the 'userId' field to the document's ID
      });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('تأكيد الحجز'),
            content: Text(
              'تم حجز موعدك بنجاح!\n'
              'التاريخ: ${selectedAppointment!['date']}\n'
              'اليوم: ${selectedAppointment!['day']}\n'
              'الوقت: ${selectedAppointment!['time']}\n'
              
            ),
            actions: [
              TextButton(
                child: Text('إغلاق'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
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
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => NotificationDisplayForTherapy(appointments: []),
                ),
              );
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
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8, top: 30),
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
                for (int i = 0; i < int.parse(widget.therapist['rate']); i++)
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
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0XFFD68FFF),
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Text(
                      'التعليقت',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Tajawal',
                        color: showAppointments ? Colors.grey : Color(0XFFD68FFF),
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
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0XFFD68FFF),
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Text(
                      'المواعيد المتاحه',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Tajawal',
                        color: showAppointments ? Color(0XFFD68FFF) : Colors.grey,
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
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // Number of columns
                        crossAxisSpacing: 10, // Horizontal space between cards
                        mainAxisSpacing: 10, // Vertical space between cards
                        childAspectRatio: 3 / 2, // Aspect ratio of the cards
                      ),
                      itemCount: appointments.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedAppointment = appointments[index];
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xFFD68FFF),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  appointments[index]['day'],
                                  style: TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                  appointments[index]['date'],
                                  style: TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                  appointments[index]['time'],
                                  style: TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        'اختر "المواعيد المتاحه" لعرض المواعيد',
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 20),
            Spacer(
              flex: 1,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GestureDetector(
                onTap: _bookAppointment,
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xffD68FFF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'احجز الآن',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
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
