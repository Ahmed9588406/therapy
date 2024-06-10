import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class EditAppointmentsPage extends StatefulWidget {
  final String therapistId;
  const EditAppointmentsPage({super.key, required this.therapistId});

  @override
  State<EditAppointmentsPage> createState() => _EditAppointmentsPageState();
}

class _EditAppointmentsPageState extends State<EditAppointmentsPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  TimeOfDay? _selectedTime;
  List<Map<String, dynamic>> _appointmentCards = [];

  @override
  void initState() {
    super.initState();
    _loadAppointmentsFromFirestore();
  }

  Future<void> _loadAppointmentsFromFirestore() async {
    var collection = FirebaseFirestore.instance.collection('appointments');
    var snapshot = await collection.where('therapistId', isEqualTo: widget.therapistId).get();
    for (var doc in snapshot.docs) {
      Map<String, dynamic> appointment = {
        'day': doc['day'],
        'date': doc['date'],
        'time': doc['time'],
        'id': doc.id,
      };
      setState(() {
        _appointmentCards.add(appointment);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(''),
        ),
        actions: <Widget>[
          Row(
            children: [
            Padding(
              padding: const EdgeInsets.only(left: 16), // Reduced padding
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.black,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ])
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                TableCalendar(
                  locale: 'ar',
                  firstDay: DateTime.utc(2021, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });

                    _showTimePicker(context);
                  },
                ),
                ..._appointmentCards.map((appointment) => Card(
                  color: Color.fromARGB(255, 235, 207, 242), // Set the background color here
                  child: ListTile(
                    title: Text(
                      'اليوم: ${appointment['day']}', style: TextStyle(fontFamily: 'Tajawal'),),
                    subtitle: Text('التاريخ: ${appointment['date']} الوقت: ${appointment['time']}', style: TextStyle(fontFamily: 'Tajawal')),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteAppointment(appointment),
                    ),
                  ),
                )).toList(),
              ],
            ),
          ),
          if (_selectedDay != null && _selectedTime != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Selected Date: ${DateFormat.yMMMMd('ar').format(_selectedDay!)}\n'
                'Selected Time: ${_selectedTime!.format(context)}',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _showTimePicker(BuildContext context) async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime != null && _selectedDay != null) {
      String formattedDay = DateFormat.EEEE('ar').format(_selectedDay!);
      String formattedDate = DateFormat.yMMMMd('ar').format(_selectedDay!);
      String formattedTime = selectedTime.format(context);

      bool alreadyExists = _appointmentCards.any((appointment) =>
        appointment['day'] == formattedDay &&
        appointment['date'] == formattedDate &&
        appointment['time'] == formattedTime);

      if (!alreadyExists) {
        Map<String, dynamic> newAppointment = {
          'day': formattedDay,
          'date': formattedDate,
          'time': formattedTime,
          'therapistId': widget.therapistId, // Include therapistId when creating a new appointment
        };

        setState(() {
          _selectedTime = selectedTime;
          _appointmentCards.add(newAppointment);
        });

        // Add to Firestore and store the document ID
        FirebaseFirestore.instance.collection('appointments').add(newAppointment).then((docRef) {
          newAppointment['id'] = docRef.id; // Store the Firestore document ID
          setState(() {
            _appointmentCards[_appointmentCards.length - 1] = newAppointment;
          });
        });
      }
    }
  }

  void _deleteAppointment(Map<String, dynamic> appointment) {
    setState(() {
      _appointmentCards.remove(appointment);
    });

    // Delete from Firestore using the stored document ID
    FirebaseFirestore.instance.collection('appointments').doc(appointment['id']).delete();
  }
}
