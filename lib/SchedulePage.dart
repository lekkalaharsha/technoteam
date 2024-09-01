import 'package:flutter/material.dart';

class SchedulePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Schedule'),
      ),
      body: Center(
        child: Text(
          'Your exercise schedule will appear here.',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}
