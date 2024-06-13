import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MoodTrackerPage extends StatefulWidget {
  @override
  _MoodTrackerPageState createState() => _MoodTrackerPageState();
}

class _MoodTrackerPageState extends State<MoodTrackerPage> {
  String _selectedEmoji = '';
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, String> _emojis = {};
  Map<String, Map<String, int>> _emojiCountsByMonth = {};
  List<String> arabicMonths = [
    'يناير',
    'فبراير',
    'مارس',
    'إبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];

  void _updateEmojiCountsByMonth() {
    _emojiCountsByMonth = {};

    _emojis.forEach((date, emoji) {
      String monthKey = '${date.year}-${date.month}';
      if (!_emojiCountsByMonth.containsKey(monthKey)) {
        _emojiCountsByMonth[monthKey] = {
          '😐': 0,
          '😞': 0,
          '😍': 0,
          '😇': 0,
          '😡': 0,
        };
      }

      _emojiCountsByMonth[monthKey]?[emoji] =
          (_emojiCountsByMonth[monthKey]?[emoji] ?? 0) + 1;
    });
  }

  Color _getEmojiColor(String emoji) {
    switch (emoji) {
      case '😐':
        return Color(0xffFFB73E);
      case '😞':
        return Colors.black;
      case '����':
        return Color(0xffD68FFF);
      case '😇':
        return Color(0xffFE609B);
      case '😡':
        return Color(0xffBA1A1A);
      default:
        return Colors.black;
    }
  }

  void _showMoodPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MoodPopup(
          onEmojiSelected: (emoji) {
            setState(() {
              _selectedEmoji = emoji;
              _emojis[_selectedDay!] = emoji;
              _updateEmojiCountsByMonth();
            });
            FirebaseService.saveEmojiForDay(_selectedDay!, _selectedEmoji);
          },
        );
      },
    );
  }

  String _getMostSelectedEmoji(Map<String, int> emojiCounts) {
    String mostSelectedEmoji = '😐'; // Default emoji
    int maxCount = 0;

    emojiCounts.forEach((emoji, count) {
      if (count > maxCount) {
        maxCount = count;
        mostSelectedEmoji = emoji;
      }
    });

    return mostSelectedEmoji;
  }

  @override
  Widget build(BuildContext context) {
    _updateEmojiCountsByMonth();
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(''),
        ),
        actions: <Widget>[
          Padding(padding: EdgeInsets.all(16)),
          Row(children: [
            Padding(
              padding: const EdgeInsets.only(top: 11),
              child: Text(
                'مزاجي',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
            ),
            IconButton(
              //padding: EdgeInsets.only(right: 30),
              icon: Icon(
                Icons.arrow_forward_ios,
                color: Colors.black,
              ),
              onPressed: () {
               Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext) {
                    return const come();
                  },
                ),
              );
              },
            ),
          ])
        ],
      ),
      body: Center(
        child: Column(
          children: [
            TableCalendar(
              locale: 'ar',
              firstDay: DateTime.utc(2021, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay; // update `_focusedDay` here as well
                });
                _showMoodPopup(context);
                FirebaseService.saveEmojiForDay(selectedDay, _selectedEmoji);
              },
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  final emoji = _emojis[date];
                  if (emoji != null) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 0),
                      child: Text(
                        emoji,
                        style: GoogleFonts.tajawal(fontSize: 12),
                      ),
                    );
                  }
                  return null;
                },
              ),
            ),
            Expanded(
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(
                  isInversed: true, // Reverse the axis direction
                ),
                primaryYAxis: NumericAxis(
                  opposedPosition: true, // Move the Y-axis to the right
                  numberFormat: NumberFormat
                      .percentPattern(), // Format labels as percentages
                ),
                series: _emojiCountsByMonth.entries.map((entry) {
                  String monthKey = entry.key;
                  String mostSelectedEmoji =
                      _getMostSelectedEmoji(entry.value); // Default emoji
                  int maxCount = 0;

                  entry.value.forEach((emoji, count) {
                    if (count > maxCount) {
                      maxCount = count;
                      mostSelectedEmoji = emoji;
                    }
                  });

                  return ColumnSeries<dynamic, String>(
                    dataSource: [
                      EmojiCount(monthKey, maxCount),
                    ],
                    xValueMapper: (dynamic count, _) {
                      String monthKey = count.emoji;
                      int monthIndex = int.parse(monthKey.split('-')[1]);
                      return arabicMonths[monthIndex - 1];
                    },
                    yValueMapper: (dynamic count, _) => count.count,
                    color: _getEmojiColor(mostSelectedEmoji),
                    dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                      labelAlignment: ChartDataLabelAlignment.top,
                      alignment: ChartAlignment.center,
                      textStyle: GoogleFonts.tajawal(fontSize: 12),
                      // Show the emoji with the highest count at the top of each column
                      builder: (dynamic data, dynamic point, dynamic series,
                          int pointIndex, int seriesIndex) {
                        return Text(
                          mostSelectedEmoji,
                          style: GoogleFonts.tajawal(fontSize: 25),
                        );
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmojiCount {
  final String emoji;
  final int count;

  EmojiCount(this.emoji, this.count);
}

class MoodPopup extends StatelessWidget {
  final Function(String) onEmojiSelected;

  MoodPopup({required this.onEmojiSelected});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Container(
        alignment: Alignment.center,
        child: Text('كيف تشعر اليوم ؟'),
      ),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: TextButton(
              onPressed: () {
                // Handle mood selection
                onEmojiSelected('😐');
                Navigator.pop(context);
              },
              child: Text('😐'),
            ),
          ),
          Expanded(
            child: TextButton(
              onPressed: () {
                // Handle mood selection
                onEmojiSelected('😞');
                Navigator.pop(context);
              },
              child: Text('😞'),
            ),
          ),
          Expanded(
            child: TextButton(
              onPressed: () {
                // Handle mood selection
                onEmojiSelected('😍');
                Navigator.pop(context);
              },
              child: Text('😍'),
            ),
          ),
          Expanded(
            child: TextButton(
              onPressed: () {
                // Handle mood selection
                onEmojiSelected('😇');
                Navigator.pop(context);
              },
              child: Text('😇'),
            ),
          ),
          Expanded(
            child: TextButton(
              onPressed: () {
                // Handle mood selection
                onEmojiSelected('😡');
                Navigator.pop(context);
              },
              child: Text('😡'),
            ),
          ),
        ],
      ),
    );
  }
}

class FirebaseService {
  static final _firestore = FirebaseFirestore.instance;

  static final List<String> arabicMonths = [
    'يناير',
    'فبراير',
    'مارس',
    'إبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر'
  ];

  static Future<void> saveEmojiForDay(DateTime day, String emoji) async {
    final docRef =
        _firestore.collection('mood').doc('${day.year}-${day.month}');

    // Get the current counts for the emojis
    final docSnapshot = await docRef.get();
    final data = docSnapshot.data();

    int count1 = data?['😐'] ?? 0;
    int count2 = data?['😞'] ?? 0;
    int count3 = data?['😍'] ?? 0;
    int count4 = data?['😇'] ?? 0;
    int count5 = data?['😡'] ?? 0;

    // Get the previously selected emoji for that day
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? previousEmoji = prefs.getString(day.toString()) ?? '';
    // Update counts based on selected emoji and previous emoji
    switch (emoji) {
      case '😐':
        count1++;
        break;
      case '����':
        count2++;
        break;
      case '😍':
        count3++;
        break;
      case '😇':
        count4++;
        break;
      case '😡':
        count5++;
        break;
    }

    switch (previousEmoji) {
      case '😐':
        count1--;
        break;
      case '😞':
        count2--;
        break;
      case '😍':
        count3--;
        break;
      case '😇':
        count4--;
        break;
      case '😡':
        count5--;
        break;
    }

    // Save updated counts
    await docRef.set({
      '😐': count1,
      '😞': count2,
      '😍': count3,
      '😇': count4,
      '😡': count5,
      'emojis': {
        ...data?['emojis'] ?? {},
        '${day.day}': emoji,
      },
      'month': arabicMonths[day.month - 1], // Use Arabic month name
      'year': day.year.toString(), // Use year
    }, SetOptions(merge: true));

     // Save selected emoji locally
    await prefs.setString(day.toString(), emoji);
  }
}

class come extends StatelessWidget {
  const come({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(''),
        ),
        actions: <Widget>[
          IconButton(
            padding: const EdgeInsets.only(right: 30),
            icon: const Icon(
              Icons.close,
              color: Color(0xffD68FFF),
            ),
            onPressed: () {
               Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }
}