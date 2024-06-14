import 'package:flutter/material.dart';

class NotificationDisplayForTherapy extends StatefulWidget {
  final List<Map<String, dynamic>> appointments;

  NotificationDisplayForTherapy({required this.appointments});

  @override
  _NotificationDisplayForTherapyState createState() => _NotificationDisplayForTherapyState();
}

class _NotificationDisplayForTherapyState extends State<NotificationDisplayForTherapy> {
  void _removeAppointment(int index) {
    setState(() {
      widget.appointments.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('اشعراتي'),
      ),
      body: ListView.builder(
        itemCount: widget.appointments.length,
        itemBuilder: (context, index) {
          var appointment = widget.appointments[index];
          return Dismissible(
            key: Key(appointment['date'] + appointment['time']), // Unique key for Dismissible
            onDismissed: (direction) {
              _removeAppointment(index);
            },
            background: Container(color: Colors.red),
            child: Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.calendar_today),
                    title: Text('Date: ${appointment['date']}'),
                    subtitle: Text('Time: ${appointment['time']} - Day: ${appointment['day']}'),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('هناك حجز في ${appointment['date']} الساعة ${appointment['time']} يوم ${appointment['day']}'),
                  ),
                  ButtonBar(
                    alignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TextButton(
                        child: Text('قبول'),
                        onPressed: () {
                          // Add your acceptance action here
                        },
                      ),
                      TextButton(
                        child: Text('رفض'),
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
    );
  }
}