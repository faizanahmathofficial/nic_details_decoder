import 'package:flutter/material.dart';

// NIC Decoder Utility for Old and New NIC formats
class NICDecoder {
  static Map<String, String>? decode(String nic) {
    if (nic.length == 10 && (nic.endsWith('V') || nic.endsWith('X'))) {
      return _decodeOldFormat(nic);
    } else if (nic.length == 12) {
      return _decodeNewFormat(nic);
    } else {
      return null;
    }
  }

  static Map<String, String>? _decodeOldFormat(String nic) {
    String year = '19${nic.substring(0, 2)}';
    int dayOfYear = int.parse(nic.substring(2, 5));
    String gender = dayOfYear > 500 ? 'Female' : 'Male';
    if (dayOfYear > 500) dayOfYear -= 500;

    DateTime? date = _getDateFromDayOfYear(int.parse(year), dayOfYear);
    if (date == null) return null;

    return {
      'dateOfBirth':
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${(date.day - 1).toString().padLeft(2, '0')}',
      'weekday': _getWeekdayName(date.weekday),
      'age': _calculateAge(date).toString(),
      'gender': gender
    };
  }

  static Map<String, String>? _decodeNewFormat(String nic) {
    String year = nic.substring(0, 4);
    int dayOfYear = int.parse(nic.substring(4, 7));
    String gender = dayOfYear > 500 ? 'Female' : 'Male';
    if (dayOfYear > 500) dayOfYear -= 500;

    DateTime? date = _getDateFromDayOfYear(int.parse(year), dayOfYear);
    if (date == null) return null;

    return {
      'dateOfBirth':
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${(date.day - 1).toString().padLeft(2, '0')}',
      'weekday': _getWeekdayName(date.weekday),
      'age': _calculateAge(date).toString(),
      'gender': gender
    };
  }

  static DateTime? _getDateFromDayOfYear(int year, int dayOfYear) {
    List<int> daysInMonth = [
      31, // January
      _isLeapYear(year) ? 29 : 28, // February
      31, // March
      30, // April
      31, // May
      30, // June
      31, // July
      31, // August
      30, // September
      31, // October
      30, // November
      31, // December
    ];

    if (dayOfYear < 1 || dayOfYear > (daysInMonth.reduce((a, b) => a + b))) {
      return null;
    }

    int month = 0;
    while (dayOfYear > daysInMonth[month]) {
      dayOfYear -= daysInMonth[month];
      month++;
    }
    return DateTime(year, month + 1, dayOfYear);
  }

  static bool _isLeapYear(int year) {
    if (year % 4 != 0) return false;
    if (year % 100 == 0 && year % 400 != 0) return false;
    return true;
  }

  static String _getWeekdayName(int weekday) {
    List<String> days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return days[weekday - 1];
  }

  static int _calculateAge(DateTime birthDate) {
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}

// Main Entry Point of the Application
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NIC Details Decoder',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.blue[50],
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue, width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blueAccent, width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[800],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          ),
        ),
      ),
      home: InputScreen(),
    );
  }
}

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  _InputScreenState createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  TextEditingController nicInputController = TextEditingController();

  void decodeNIC() {
    var nic = nicInputController.text.trim();

    if (nic.isEmpty ||
        (!RegExp(r'^\d{9}[VXvx]$').hasMatch(nic) &&
            !RegExp(r'^\d{12}$').hasMatch(nic))) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid NIC Number'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    var result = NICDecoder.decode(nic);

    if (result != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(decodedData: result),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid NIC Number'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NIC Decoder'),
        backgroundColor: Colors.blue[800],
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: nicInputController,
              decoration: InputDecoration(
                labelText: 'Enter NIC Number',
                labelStyle: TextStyle(color: Colors.blue[800]),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: decodeNIC,
              child: Text('Decode'),
            ),
          ],
        ),
      ),
    );
  }
}

class ResultScreen extends StatelessWidget {
  final Map<String, String> decodedData;

  const ResultScreen({super.key, required this.decodedData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NIC Details'),
        backgroundColor: Colors.blue[800],
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text('Date of Birth: ${decodedData['dateOfBirth']}'),
            Text('Weekday: ${decodedData['weekday']}'),
            Text('Age: ${decodedData['age']}'),
            Text('Gender: ${decodedData['gender']}'),
          ],
        ),
      ),
    );
  }
}
