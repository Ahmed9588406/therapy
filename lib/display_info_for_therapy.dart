import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:therapy/edit_appointments_page.dart';

import 'notification_display_for_therapy.dart';

class TherapistProfilePage extends StatefulWidget {
  final String therapistId;
  final List<Map<String, dynamic>> appointments;

  const TherapistProfilePage(
      {Key? key, required this.therapistId, this.appointments = const []})
      : super(key: key);

  @override
  _TherapistProfilePageState createState() => _TherapistProfilePageState();
}

class _TherapistProfilePageState extends State<TherapistProfilePage> {
  late String imageUrl;
  bool showAppointments = false;
  bool Switch = false;
  double averageRate = 0.0;
  List<Map<String, dynamic>> userComments = [];

  @override
  void initState() {
    super.initState();
    imageUrl = '';
    _fetchUserComments();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      // Upload image to Firebase Storage
      String fileName =
          'therapists/${widget.therapistId}/${DateTime.now().millisecondsSinceEpoch.toString()}';
      FirebaseStorage storage = FirebaseStorage.instance;
      try {
        await storage.ref(fileName).putFile(imageFile);
        String downloadUrl = await storage.ref(fileName).getDownloadURL();
        setState(() {
          imageUrl = downloadUrl;
        });
        // Update Firestore document
        FirebaseFirestore.instance
            .collection('therapists')
            .doc(widget.therapistId)
            .update({'imageUrl': downloadUrl});
      } catch (e) {
        print(e); // Handle errors
      }
    }
  }

  Future<void> _showEditDialog(String field, String currentValue) async {
    TextEditingController _controller =
        TextEditingController(text: currentValue);
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('تعديل'),
          content: TextFormField(
            controller: _controller,
            decoration: const InputDecoration(labelText: 'القيمة الجديدة'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('therapists')
                    .doc(widget.therapistId)
                    .update({field: _controller.text});
                setState(() {});
                Navigator.of(context).pop();
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _fetchUserComments() async {
    var collection = FirebaseFirestore.instance.collection('addUserComment');
    var snapshot = await collection
        .where('therapistId', isEqualTo: widget.therapistId)
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

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (widget.therapistId.isEmpty) {
      print("Invalid therapist ID");
      return;
    }

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
                therapistId: widget.therapistId,
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
                therapistId: widget.therapistId,
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
                therapistId: widget.therapistId,
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
      appBar: AppBar(),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('therapists')
            .doc(widget.therapistId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('خطأ في جلب البيانات'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('لا توجد بيانات'));
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;
          imageUrl = data['imageUrl'] ?? '';
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Directionality(
                textDirection: TextDirection.rtl,
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
                              radius: 80,
                              backgroundImage: imageUrl.isNotEmpty
                                  ? NetworkImage(imageUrl)
                                  : null,
                              child: imageUrl.isEmpty
                                  ? const Icon(Icons.person, size: 100)
                                  : null,
                            ),
                          ),
                          Positioned(
                            bottom: -10,
                            left: 100,
                            child: IconButton(
                              icon: const Icon(Icons.add_a_photo,
                                  color: Colors.black),
                              onPressed: pickImage,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: 'الاسم : ',
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: data['name'],
                            style: const TextStyle(
                              fontFamily: 'Tajawal',
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: Color(0xff494649),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    RichText(
                      text: TextSpan(
                        children: [
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
                            text: data['specialization'],
                            style: const TextStyle(
                              fontFamily: 'Tajawal',
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: Color(0xff494649),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text(
                          'التقييم : ',
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          averageRate
                              .toStringAsFixed(1), // Display the average rate
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
                    RichText(
                      text: TextSpan(
                        children: [
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
                            text: data['country'],
                            style: const TextStyle(
                              fontFamily: 'Tajawal',
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: Color(0xff494649),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    RichText(
                      text: TextSpan(
                        children: [
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
                            text: data['sessionsNumber'].toString(),
                            style: const TextStyle(
                              fontFamily: 'Tajawal',
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: Color(0xff494649),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text: 'مدة الجلسة التي تريدها : ',
                                style: TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                              TextSpan(
                                text: '${data['timeforsession']} ساعة',
                                style: const TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  color: Color(0xff494649),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon:
                              const Icon(Icons.edit, color: Color(0xffD68FFF)),
                          onPressed: () {
                            _showEditDialog('timeforsession',
                                data['timeforsession'].toString());
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text: 'سعر الجلسة : ',
                                style: TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                              TextSpan(
                                text: '${data['salary']} ج.م',
                                style: const TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  color: Color(0xff494649),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon:
                              const Icon(Icons.edit, color: Color(0xffD68FFF)),
                          onPressed: () {
                            _showEditDialog(
                                'salary', data['salary'].toString());
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              Switch = false;
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
                              'المواعيد المتاحة',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Tajawal',
                                color: showAppointments
                                    ? Colors.grey
                                    : Color(0XFFD68FFF),
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              showAppointments = !showAppointments;
                            });
                          },
                          child: Text(showAppointments
                              ? 'إخفاء المواعيد'
                              : 'عرض المواعيد'),
                        ),
                        if (showAppointments)
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('appointments')
                                .where('therapistId',
                                    isEqualTo: widget.therapistId)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              if (snapshot.hasError) {
                                return const Center(
                                    child: Text('خطأ في جلب البيانات'));
                              }
                              if (!snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                return const Center(
                                    child: Text('لا توجد مواعيد'));
                              }

                              return ListView.builder(
                                shrinkWrap: true,
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: (context, index) {
                                  var appointment = snapshot.data!.docs[index]
                                      .data() as Map<String, dynamic>;
                                  return Card(
                                    child: ListTile(
                                      title: Text(appointment['date']),
                                      subtitle: Text(appointment['time']),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () async {
                                          await FirebaseFirestore.instance
                                              .collection('appointments')
                                              .doc(
                                                  snapshot.data!.docs[index].id)
                                              .delete();
                                        },
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditAppointmentsPage(
                                    therapistId: widget.therapistId),
                              ),
                            );
                          },
                          child: const Text('اضف المواعيد'),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          Switch = true;
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
                            color: showAppointments
                                ? Colors.grey
                                : Color(0XFFD68FFF),
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Display user comments
                    for (var comment in userComments)
                      Card(
                        color: Color.fromARGB(255, 239, 226, 243),
                        child: ListTile(
                          leading: comment['imageUrl'] != null
                              ? CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(comment['imageUrl']),
                                )
                              : const CircleAvatar(
                                  child: Icon(Icons.person),
                                ),
                          title: Text(
                            comment['comment'],
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
                                  i < int.parse(comment['rate']);
                                  i++)
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 18,
                                ),
                              // Text('التقييم: ${userComments[index]['rate']}'),
                            ],
                          ),
                          //subtitle: Text('التقييم: ${comment['rate']}'),
                        ),
                      ),
                  ],
                ),
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
