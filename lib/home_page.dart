import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CalendarController _controller;
  Map<DateTime, List<dynamic>> _events;
  TextEditingController _eventController;
  List<dynamic> _selectedEvents;
  SharedPreferences prefs;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = CalendarController();
    _events = {};
    _eventController = TextEditingController();
    _selectedEvents = [];
    initPrefs();
  }

  initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      _events = Map<DateTime, List<dynamic>>.from(
          decodeMap(json.decode(prefs.getString("events") ?? "{}")));
    });
  }

  Map<String, dynamic> encodeMap(Map<DateTime, dynamic> map) {
    Map<String, dynamic> newMap = {};
    map.forEach((key, value) {
      newMap[key.toString()] = map[key];
    });
    return newMap;
  }

  Map<DateTime, dynamic> decodeMap(Map<String, dynamic> map) {
    Map<DateTime, dynamic> newMap = {};
    map.forEach((key, value) {
      newMap[DateTime.parse(key)] = map[key];
    });
    return newMap;
  }

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('tr');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange[300],
        title: Text(
          'Flutter Görev Yöneticisi (Günlük)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, color: Colors.black),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blue,
        selectedFontSize: 20,
        unselectedFontSize: 14,
        // backgroundColor: Colors.orange[300],
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.calendar_today,
              size: 25,
            ),
            backgroundColor: Colors.pink,
            label: "Günlük",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.calendar_today,
              size: 25,
            ),
            label: "Haftalık",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.calendar_today,
              size: 25,
            ),
            label: "Aylık",
          )
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TableCalendar(
              events: _events,
              locale: 'tr',
              initialCalendarFormat: CalendarFormat.month,
              calendarStyle: CalendarStyle(
                todayColor: Colors.orange,
                selectedColor: Theme.of(context).primaryColor,
                todayStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                    color: Colors.white),
              ),
              headerStyle: HeaderStyle(
                centerHeaderTitle: true,
                formatButtonDecoration: BoxDecoration(
                  color: Colors.pink,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                formatButtonTextStyle: TextStyle(color: Colors.white),
                formatButtonShowsNext: false,
              ),
              startingDayOfWeek: StartingDayOfWeek.monday,
              onDaySelected: (date, events, holiday) {
                setState(() {
                  _selectedEvents = events;
                });
              },
              builders: CalendarBuilders(
                selectedDayBuilder: (context, date, events) => Container(
                  margin: const EdgeInsets.all(4.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(10.0)),
                  child: Text(
                    date.day.toString(),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                todayDayBuilder: (context, date, events) => Container(
                  margin: const EdgeInsets.all(4.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(10.0)),
                  child: Text(
                    date.day.toString(),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              calendarController: _controller,
            ),
            ..._selectedEvents.map((event) => ListTile(title: Text(event)))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _showAddDialog,
      ),
    );
  }

  _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: _eventController,
        ),
        actions: [
          FlatButton(
            child: Text("Kaydet"),
            onPressed: () {
              if (_eventController.text.isEmpty) return;
              setState(() {
                if (_events[_controller.selectedDay] != null) {
                  _events[_controller.selectedDay].add(_eventController.text);
                } else {
                  _events[_controller.selectedDay] = [_eventController.text];
                }
                prefs.setString("events", json.encode(encodeMap(_events)));
                _eventController.clear();
                Navigator.pop(context);
              });
            },
          )
        ],
      ),
    );
  }
}
