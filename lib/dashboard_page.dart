import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  User? user;
  Map<String, dynamic>? userData;
  final DatabaseReference _realtimeDatabase = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Fetch user details from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();
      setState(() {
        userData = userDoc.data() as Map<String, dynamic>?;
      });

      // Fetch steps and heart rate from Realtime Database
      _realtimeDatabase
          .child('users')
          .child(userData?['userName'] ?? '')
          .child('stats')
          .onValue
          .listen((event) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        setState(() {
          userData?['steps'] = data?['steps'] ?? 'N/A';
          userData?['heartRate'] = data?['heartRate'] ?? 'N/A';
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set background color for better contrast
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Message
            Text(
              'Welcome, ${userData?['userName'] ?? 'User'}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            // Display User Details
            if (userData != null) ...[
              Text('Age: ${userData?['age'] ?? 'N/A'}', style: const TextStyle(color: Colors.white)),
              Text('Gender: ${userData?['gender'] ?? 'N/A'}', style: const TextStyle(color: Colors.white)),
              Text('Place: ${userData?['place'] ?? 'N/A'}', style: const TextStyle(color: Colors.white)),
            ],
            const SizedBox(height: 20),
            // Stats Section
            const Text(
              'Stats',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            // Display Steps and Heart Rate
            if (userData != null) ...[
              Card(
                color: Colors.white.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(Icons.directions_walk, color: Colors.white),
                  title: const Text(
                    'Steps Today',
                    style: TextStyle(color: Colors.white),
                  ),
                  trailing: Text(
                    '${userData?['steps'] ?? 'N/A'}',
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Card(
                color: Colors.white.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(Icons.favorite, color: Colors.white),
                  title: const Text(
                    'Heart Rate',
                    style: TextStyle(color: Colors.white),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${userData?['heartRate'] ?? 'N/A'} bpm',
                        style: const TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      const SizedBox(width: 10),
                      if (int.tryParse(userData?['heartRate'] ?? '') != null &&
                          int.parse(userData?['heartRate'] ?? '') > 100)
                        const Icon(Icons.monitor_heart, color: Colors.red),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            // Quick Actions Section
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildQuickActionButton(
                    'Exercise Plans',
                    Icons.fitness_center,
                    () {
                      Navigator.pushNamed(context, '/exercise');
                    },
                  ),
                  const SizedBox(width: 10),
                  _buildQuickActionButton(
                    'Health Monitoring',
                    Icons.health_and_safety,
                    () {
                      Navigator.pushNamed(context, '/health');
                    },
                  ),
                  // Add more quick action buttons here
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(String title, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(title, style: const TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue, // Background color
        minimumSize: const Size(150, 50), // Set a minimum size for the buttons
        textStyle: const TextStyle(fontSize: 16), // Text style for the buttons
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Rounded corners
        ),
      ),
    );
  }
}
