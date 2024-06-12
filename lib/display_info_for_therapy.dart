import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:therapy/edit_appointments_page.dart';

class TherapistProfilePage extends StatefulWidget {
  final String therapistId;

  const TherapistProfilePage({Key? key, required this.therapistId})
      : super(key: key);

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

  int _selectedIndex = 0;
  int index = 0;

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
            builder: (BuildContext) {
              return TherapistProfilePage(
                therapistId: '',
              );
              // return TherapistSessionsEmpty();
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

  bool showAppointments = false;
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
                        for (int i = 0; i < int.parse(data['rate']); i++)
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
                    const SizedBox(height: 10),
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
                                color: showAppointments
                                    ? Color(0XFFD68FFF)
                                    : Colors.grey,
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
                    const SizedBox(height: 20),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('appointment')
                          .where('therapistId', isEqualTo: widget.therapistId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return const Center(
                              child: Text('خطأ في جلب المواعيد'));
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          // Here, instead of just showing text, we show the card
                          return _buildSelectedDateTimeWidget({
                            'day': 'اليوم',
                            'date': 'التاريخ',
                            'time': 'الوقت',
                            // 'patientName': 'Default Patient' // Assuming you need a 'patientName' key as well.
                          }); // Provide default or empty data
                        }

                        var appointments = snapshot.data!.docs;

                        return ListView(
                          children: appointments.map((appointment) {
                            var data =
                                appointment.data() as Map<String, dynamic>;
                            return _buildSelectedDateTimeWidget(data);
                          }).toList(),
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext) {
                                return EditAppointmentsPage(
                                    therapistId: widget.therapistId);
                              },
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 8.0),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'اضف وتعديل الميعاد',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Tajawal',
                                  color: Color(0XFFD68FFF),
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 8, left: 5),
                                child: Icon(
                                  Icons.date_range_outlined,
                                  color: Color(0XFFD68FFF),
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
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
              Icons.notifications_none,
              color:
                  _selectedIndex == 2 ? Color(0xffD68FFF) : Color(0xffE8E0E5),
              size: 27,
            ),
            label: 'اشعارات',
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

  Widget _buildSelectedDateTimeWidget(Map<String, dynamic> data) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ListTile(
        leading: Icon(Icons.event_available),
        title: Text(data['day'] ?? 'Session Type Not Specified'),
        subtitle: Text('${data['date']} at ${data['time']}'),
        // trailing: Text(data['patientName'] ?? 'Patient Name Not Specified'),
        onTap: () {
          // Optionally, handle tap event, e.g., navigate to a detailed view
        },
      ),
    );
  }
}
