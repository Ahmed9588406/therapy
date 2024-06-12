import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class EditAppointmentsPage extends StatefulWidget {
  final String therapistId;
  const EditAppointmentsPage({Key? key, required this.therapistId})
      : super(key: key);

  @override
  State<EditAppointmentsPage> createState() => _EditAppointmentsPageState();
}

class _EditAppointmentsPageState extends State<EditAppointmentsPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  List<DateTime> _selectedDays = [];
  List<TimeOfDay> _selectedTimes = [];
  List<Map<String, dynamic>> _appointmentCards = [];
  List<Widget> _selectedDateTimeWidgets = [];

  @override
  void initState() {
    super.initState();
    _loadAppointmentsFromFirestore();
  }

  Future<void> _loadAppointmentsFromFirestore() async {
    var collection = FirebaseFirestore.instance.collection('appointments');
    var snapshot = await collection
        .where('therapistId', isEqualTo: widget.therapistId)
        .get();
    for (var doc in snapshot.docs) {
      Map<String, dynamic> appointment = {
        'day': doc['day'],
        'date': doc['date'],
        'time': doc['time'],
        'id': doc.id,
      };
      setState(() {
        _appointmentCards.add(appointment);
        _selectedDateTimeWidgets.add(_buildSelectedDateTimeWidget(
          appointment['day'],
          appointment['date'],
          appointment['time'],
          appointment,
        ));
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
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
                  selectedDayPredicate: (day) => _selectedDays
                      .any((selectedDay) => isSameDay(selectedDay, day)),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      if (!_selectedDays
                          .any((d) => isSameDay(d, selectedDay))) {
                        _selectedDays.add(selectedDay);
                      }
                      _focusedDay = focusedDay;
                    });

                    _showTimePicker(context);
                  },
                ),
                Wrap(
                  children: _selectedDateTimeWidgets,
                ),
              ],
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

    if (selectedTime != null) {
      List<Map<String, dynamic>> newAppointments = [];
      for (var selectedDay in _selectedDays) {
        String formattedDay = DateFormat.EEEE('ar').format(selectedDay);
        String formattedDate = DateFormat.yMMMMd('ar').format(selectedDay);
        String formattedTime = selectedTime.format(context);

        bool alreadyExists = _appointmentCards.any((appointment) =>
            appointment['date'] == formattedDate &&
            appointment['time'] == formattedTime &&
            appointment['therapistId'] == widget.therapistId);

        if (!alreadyExists) {
          Map<String, dynamic> newAppointment = {
            'day': formattedDay,
            'date': formattedDate,
            'time': formattedTime,
            'therapistId': widget.therapistId,
          };

          newAppointments.add(newAppointment);
        }
      }

      if (newAppointments.isNotEmpty) {
        for (var newAppointment in newAppointments) {
          DocumentReference docRef = await FirebaseFirestore.instance
              .collection('appointments')
              .add(newAppointment);
          newAppointment['id'] = docRef.id;

          setState(() {
            _appointmentCards.add(newAppointment);
            _selectedDateTimeWidgets.add(_buildSelectedDateTimeWidget(
              newAppointment['day'],
              newAppointment['date'],
              newAppointment['time'],
              newAppointment,
            ));
          });
        }

        _selectedDays.clear();
      }
    }
  }

  Widget _buildSelectedDateTimeWidget(
      String day, String date, String time, Map<String, dynamic> appointment) {
    return Card(
      key: ValueKey(appointment['id']), // Use ValueKey to identify the widget
      color: const Color.fromARGB(255, 235, 207, 242),
      margin: const EdgeInsets.all(4.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(day, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 16)),
            Text(date, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 16)),
            Text(time, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 16)),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => _deleteAppointment(appointment),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteAppointment(Map<String, dynamic> appointment) {
    setState(() {
      _appointmentCards.remove(appointment);
      _selectedDateTimeWidgets.removeWhere((widget) =>
          widget.key == ValueKey(appointment['id'])); // Use ValueKey to identify widget
    });

    FirebaseFirestore.instance
        .collection('appointments')
        .doc(appointment['id'])
        .delete();
  }
}
