import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _elderNameController = TextEditingController();
  final _elderIdController = TextEditingController();

  void _addElderProfile() async {
    final name = _elderNameController.text;
    final id = _elderIdController.text;

    if (name.isNotEmpty && id.isNotEmpty) {
      try {
        User? currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          // Check if the elder ID already exists
          final docSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .collection('elders')
              .doc(id)
              .get();

          if (docSnapshot.exists) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Elder ID already exists')),
            );
          } else {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(currentUser.uid)
                .collection('elders')
                .doc(id)
                .set({
              'name': name,
              'id': id,
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Elder added successfully')),
            );
            _elderNameController.clear();
            _elderIdController.clear();
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add elder: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _elderNameController,
              decoration: const InputDecoration(labelText: 'Elder Name'),
              validator: (value) => value!.isEmpty ? 'Enter elder name' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _elderIdController,
              decoration: const InputDecoration(labelText: 'Elder ID'),
              validator: (value) => value!.isEmpty ? 'Enter elder ID' : null,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addElderProfile,
              child: const Text('Add Elder'),
            ),
          ],
        ),
      ),
    );
  }
}
