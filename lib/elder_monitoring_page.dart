import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class ElderMonitoringPage extends StatefulWidget {
  const ElderMonitoringPage({super.key});

  @override
  _ElderMonitoringPageState createState() => _ElderMonitoringPageState();
}

class _ElderMonitoringPageState extends State<ElderMonitoringPage> {
  User? user;
  List<Map<String, dynamic>> elderList = [];
  final DatabaseReference _realtimeDatabase = FirebaseDatabase.instance.ref();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadElderData();
  }

  void _loadElderData() async {
    try {
      user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        QuerySnapshot eldersSnapshot = await _firestore
            .collection('users')
            .doc(user!.uid)
            .collection('elders')
            .get();

        for (var doc in eldersSnapshot.docs) {
          var elderData = doc.data() as Map<String, dynamic>;
          elderList.add(elderData);

          // Now we call the Firebase Realtime Database to get steps and heart rate
          final elderName = elderData['name'] ?? '';
          print(elderName);

          if (elderName.isNotEmpty) {
            _realtimeDatabase
                .child('users')
                .child(elderName)
                .child('stats')
                .onValue
                .listen((event) {
              final data = event.snapshot.value as Map<dynamic, dynamic>?;
              if (data != null) {
                setState(() {
                  elderData['heartRate'] = data['heartRate'] ?? 'N/A';
                  elderData['steps'] = data['steps'] ?? 'N/A';
                
                });
                  print('Updated elder data: $elderData');
              }
            });
          }
        }

        setState(() {});
      }
    } catch (e) {
      print('Error loading elder data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Elder Monitoring'),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Message
            const Text(
              'Elder Monitoring',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            // Elder Details Section
            if (elderList.isNotEmpty) ...[
              for (var elder in elderList)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      elder['name'] ?? 'Unknown Elder',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Card(
                      color: Colors.white.withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.directions_walk,
                            color: Colors.white),
                        title: const Text(
                          'Steps Today',
                          style: TextStyle(color: Colors.white),
                        ),
                        trailing: Text(
                          '${elder['steps'] ?? 'N/A'}',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 20),
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
                        leading:
                            const Icon(Icons.favorite, color: Colors.white),
                        title: const Text(
                          'Heart Rate',
                          style: TextStyle(color: Colors.white),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${elder['heartRate'] ?? 'N/A'} bpm',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 20),
                            ),
                            const SizedBox(width: 10),
                            if (int.tryParse(elder['heartRate'] ?? '') !=
                                    null &&
                                int.parse(elder['heartRate'] ?? '') > 100)
                              const Icon(Icons.monitor_heart,
                                  color: Colors.red),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
            ] else ...[
              const Text(
                'No elder members to monitor.',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
