import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddScheduleForm extends StatefulWidget {
  @override
  _AddScheduleFormState createState() => _AddScheduleFormState();
}

class _AddScheduleFormState extends State<AddScheduleForm> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _exerciseType = '';
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _notificationsEnabled = false;

  void _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _pickTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  void _saveSchedule() async {
    if (_formKey.currentState!.validate()) {
      User? user = _auth.currentUser;

      if (user != null && _selectedDate != null && _selectedTime != null) {
        await _firestore.collection('schedules').add({
          'userId': user.uid,
          'exerciseType': _exerciseType,
          'date': _selectedDate,
          'time': _selectedTime!.format(context),
          'notificationsEnabled': _notificationsEnabled,
        });

        Navigator.of(context).pop(); // Close the form after saving
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a date and time')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Add Schedule'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Exercise Type'),
                onChanged: (value) {
                  setState(() {
                    _exerciseType = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an exercise type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              ListTile(
                title: Text(_selectedDate == null
                    ? 'Pick a Date'
                    : 'Date: ${_selectedDate!.toLocal()}'.split(' ')[0]),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              ListTile(
                title: Text(_selectedTime == null
                    ? 'Pick a Time'
                    : 'Time: ${_selectedTime!.format(context)}'),
                trailing: const Icon(Icons.access_time),
                onTap: _pickTime,
              ),
              SwitchListTile(
                title: const Text('Enable Notifications'),
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _saveSchedule,
                child: const Text('Save Schedule'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
