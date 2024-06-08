import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TherapyShowDetails extends StatelessWidget {
  final QueryDocumentSnapshot therapist;

  TherapyShowDetails({required this.therapist});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(therapist['name']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(therapist['imageUrl']),
            ),
            const SizedBox(height: 20),
            Text('الاسم : ${therapist['name']}', style: const TextStyle(fontSize: 18)),
            Text('التخصص : ${therapist['specialization']}', style: const TextStyle(fontSize: 18)),
            Row(
              children: [
                const Text('التقيم : ', style: TextStyle(fontSize: 18)),
                for (int i = 0; i < int.parse(therapist['rate']); i++)
                  const Icon(Icons.star, color: Colors.amber),
              ],
            ),
            Text('البلد : ${therapist['country']}', style: const TextStyle(fontSize: 18)),
            Text('عدد الجلسات : ${therapist['sessionsNumber']}', style: const TextStyle(fontSize: 18)),
            Text('مدة الجلسة التي تريدها : ${therapist['timeforsession']} ساعة', style: const TextStyle(fontSize: 18)),
            Text('سعر الجلسة : ${therapist['salary']} ج.م', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            const Text('مواعيدي المتاحة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            // Add your available times UI here
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text('الاثنين'),
                          Text('03'),
                          Text('10:00 ص'),
                  ],
                ),
                Column(
                  children: [
                    Text('الثلاثاء'),
                          Text('04'),
                          Text('11:00 ص'),
                  ],
                ),
                Column(
                  children: [
                    Text('الاربعاء'),
                          Text('05'),
                          Text('12:00 م'),
                  ],
                ),
                Column(
                  children: [
                    Text('الخميس'),
                          Text('06'),
                          Text('01:00 م'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}