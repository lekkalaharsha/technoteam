import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  User? user;
  DatabaseReference? userRef;

  @override
  void initState() {
    super.initState();
    _setupDatabaseListener();
  }

  void _setupDatabaseListener() async {
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userRef = FirebaseDatabase.instance.ref().child('users').child(user!.uid);
      userRef!.onValue.listen((event) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        setState(() {
          // Update the state with the new data
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Message
            StreamBuilder<DatabaseEvent>(
              stream: userRef?.onValue,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                
                var userData = snapshot.data?.snapshot.value as Map<dynamic, dynamic>?;
                var username = userData?['username'] ?? 'User';
                var steps = userData?['steps'] ?? '0';
                var heartRate = userData?['heartRate'] ?? '0';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, $username',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text('Age: ${userData?['age'] ?? 'N/A'}', style: TextStyle(color: Colors.white)),
                    Text('Gender: ${userData?['gender'] ?? 'N/A'}', style: TextStyle(color: Colors.white)),
                    Text('Place: ${userData?['place'] ?? 'N/A'}', style: TextStyle(color: Colors.white)),
                    SizedBox(height: 20),
                    Text('Stats', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    SizedBox(height: 10),
                    Card(
                      color: Colors.white.withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Icon(Icons.directions_walk, color: Colors.white),
                        title: Text('Steps Today', style: TextStyle(color: Colors.white)),
                        trailing: Text('$steps', style: TextStyle(color: Colors.white, fontSize: 20)),
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
                        title: Text('Heart Rate', style: TextStyle(color: Colors.white)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('$heartRate bpm', style: TextStyle(color: Colors.white, fontSize: 20)),
                            SizedBox(width: 10),
                            if (heartRate is int && heartRate > 100) // Adjust the threshold as needed
                              Icon(Icons.warning, color: Colors.red),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text('Quick Actions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
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
                );
              },
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
      label: Text(title, style: TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        minimumSize: Size(150, 50),
        textStyle: TextStyle(fontSize: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
