import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Example health metrics
    final int steps = 7500;
    final int heartRate = 72;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            'Welcome to Your Dashboard',
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
          SizedBox(height: 20),
          Card(
            color: Colors.white.withOpacity(0.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Icon(Icons.directions_walk, color: Colors.white),
              title: Text(
                'Steps Today',
                style: TextStyle(color: Colors.white),
              ),
              trailing: Text(
                '$steps',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
          SizedBox(height: 10),
          Card(
            color: Colors.white.withOpacity(0.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Icon(Icons.favorite, color: Colors.white),
              title: Text(
                'Heart Rate',
                style: TextStyle(color: Colors.white),
              ),
              trailing: Text(
                '$heartRate bpm',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
          // Add more metrics as needed
        ],
      ),
    );
  }
}
