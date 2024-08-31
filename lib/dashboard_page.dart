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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    try {
      user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Fetch user details from Firestore
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user!.uid).get();

        setState(() {
          userData = userDoc.data() as Map<String, dynamic>?;
        });

        // Fetch steps and heart rate for main user from Realtime Database
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

        // Fetch elder details and stats
        _fetchElderData();
      }
    } catch (e) {
      // Handle any errors (e.g., network issues)
      print('Error loading user data: $e');
    }
  }

  void _fetchElderData() async {
    try {
      // Fetch elder members for this user
      QuerySnapshot eldersSnapshot = await _firestore
          .collection('users')
          .doc(user!.uid)
          .collection('elders')
          .get();

      List<Map<String, dynamic>> elderList = [];
      for (var doc in eldersSnapshot.docs) {
        var elderData = doc.data() as Map<String, dynamic>;
        elderList.add(elderData);
        final elderUsername = elderData['username'] ?? '';
        
        _realtimeDatabase
            .child('users')
            .child(elderUsername)
            .child('stats')
            .onValue
            .listen((event) {
          final data = event.snapshot.value as Map<dynamic, dynamic>?;
          if (data != null) {
            // Here you can implement any logic to handle alerts or updates
            // For instance, check if heart rate exceeds a certain threshold
            if (int.tryParse(data['heartRate']?.toString() ?? '0') != null &&
                int.parse(data['heartRate']?.toString() ?? '0') > 100) {
              // Trigger an alert or notification
              print(
                  'Alert: ${elderData['username']}\'s heart rate is too high!');
            }
            setState(() {
              elderData['heartRate'] = data['heartRate'] ?? 'N/A';
              elderData['steps'] = elderData['steps'] ?? 'N/A';
            });
          }
        });
      }
      setState(() {
        userData?['elders'] = elderList;
      });
    } catch (e) {
      // Handle any errors (e.g., network issues)
      print('Error fetching elder data: $e');
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
              Text('Age: ${userData?['age'] ?? 'N/A'}',
                  style: const TextStyle(color: Colors.white)),
              Text('Gender: ${userData?['gender'] ?? 'N/A'}',
                  style: const TextStyle(color: Colors.white)),
              Text('Place: ${userData?['place'] ?? 'N/A'}',
                  style: const TextStyle(color: Colors.white)),
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
                  leading:
                      const Icon(Icons.directions_walk, color: Colors.white),
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
                        style:
                            const TextStyle(color: Colors.white, fontSize: 20),
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
            // Elder Monitoring Section
            const Text(
              'Elder Monitoring',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            if (userData != null && userData!['elders'] != null) ...[
              for (var elder in userData!['elders'])
                Card(
                  color: Colors.white.withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.person, color: Colors.white),
                    title: Text(
                      elder['name'] ?? 'Unknown',
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      'Heart Rate: ${elder['heartRate'] ?? 'N/A'} bpm\nSteps Today: ${elder['steps'] ?? 'N/A'}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      onPressed: () {
                        // Handle more options if needed
                      },
                    ),
                  ),
                ),
            ] else ...[
              const Text('No elder members to monitor.',
                  style: TextStyle(color: Colors.white)),
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

  Widget _buildQuickActionButton(
      String title, IconData icon, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 10),
          Text(title,
              style: const TextStyle(color: Colors.white, fontSize: 16)),
        ],
      ),
    );
  }
}
