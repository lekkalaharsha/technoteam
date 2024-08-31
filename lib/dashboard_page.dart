import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  User? user;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      setState(() {
        userData = userDoc.data() as Map<String, dynamic>?;
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
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            // Display User Details
            if (userData != null) ...[
              Text('Age: ${userData?['age'] ?? 'N/A'}', style: TextStyle(color: Colors.white)),
              Text('Gender: ${userData?['gender'] ?? 'N/A'}', style: TextStyle(color: Colors.white)),
              Text('Place: ${userData?['place'] ?? 'N/A'}', style: TextStyle(color: Colors.white)),
            ],
            SizedBox(height: 20),
            // Stats Section
            Text(
              'Stats',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(user!.uid).collection('stats').doc('daily').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                
                var statsData = snapshot.data?.data() as Map<String, dynamic>?;
                var steps = statsData?['steps'] ?? 'N/A';
                var heartRate = statsData?['heartRate'] ?? 'N/A';

                return Column(
                  children: [
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
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$heartRate bpm',
                              style: TextStyle(color: Colors.white, fontSize: 20),
                            ),
                            SizedBox(width: 10),
                            if (heartRate is int && heartRate > 100) // Adjust the threshold as needed
                              Icon(Icons.warning, color: Colors.red),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: 20),
            // Quick Actions Section
            
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
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
                  SizedBox(width: 10),
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
      icon: Icon(icon, color: const Color.fromARGB(255, 4, 3, 3)),
      label: Text(title, style: TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue, // Background color
        minimumSize: Size(150, 50), // Set a minimum size for the buttons
        textStyle: TextStyle(fontSize: 16), // Text style for the buttons
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Rounded corners
        ),
      ),
    );
  }
}
