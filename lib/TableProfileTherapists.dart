import 'package:flutter/material.dart';

class TableProfileTherapists extends StatefulWidget {
  const TableProfileTherapists({super.key});

  @override
  State<TableProfileTherapists> createState() => _TableProfileTherapistsState();
}

class _TableProfileTherapistsState extends State<TableProfileTherapists> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Therapists'),
      ),
      body: const Center(
        child: Text('This is the TableProfileTherapists page'),
      ),
    );
  }
}

class DisplayInformationForTherapy extends StatelessWidget {
  final dynamic therapist;

  DisplayInformationForTherapy({required this.therapist});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Therapy Information'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Name: ${therapist['name']}'),
            Text('Specialization: ${therapist['specialization']}'),
            Text('Rate: ${therapist['rate']}'),
            // Add more fields as needed
          ],
        ),
      ),
    );
  }
}
