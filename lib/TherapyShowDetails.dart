import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TherapyShowDetails extends StatefulWidget {
  final QueryDocumentSnapshot therapist;

  TherapyShowDetails({required this.therapist});

  @override
  _TherapyShowDetailsState createState() => _TherapyShowDetailsState();
}

class _TherapyShowDetailsState extends State<TherapyShowDetails> {
  bool showAppointments = false;
  List<Map<String, dynamic>> appointments = [];

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
      'day': doc['day'],  // Add this line to fetch the 'day' attribute
    }).toList();

    setState(() {
      appointments = fetchedAppointments;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set the background color to white
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          widget.therapist['name'],
          style: const TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 23, // Set the font size
            fontWeight: FontWeight.bold, // Make the text bold
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios), // Use the iOS-style back arrow
          onPressed: () {
            Navigator.of(context).pop(); // Go back to the previous screen
          },
        ),
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
            // Text('مدة الجلسة التي تريدها : ${widget.therapist['timeforsession']} ساعة',
            //     style: const TextStyle(fontSize: 18)),
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
                      'المواعيد المتاحه',
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
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: showAppointments
                              ? const Color(0XFFD68FFF)
                              : Colors.transparent,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Text(
                      ' التعليقات',
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
                const SizedBox(
                  width: 20,
                ),
              ],
            ),
            if (showAppointments)
              Expanded(
                child: ListView.builder(
                  itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text('التاريخ: ${appointments[index]['date']}'),
                      subtitle: Text('الوقت: ${appointments[index]['time']} - اليوم: ${appointments[index]['day']}'),
                    );
                  },
                ),
              ),
            // Add your available times UI here
            const SizedBox(height: 20),
            // ElevatedButton(
            //   onPressed: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //           builder: (context) => CalendarAppointment()),
            //     );
            //   },
            //   child: Text('View Calendar Appointment'),
            // ),
          ],
        ),
      ),
    );
  }
}
