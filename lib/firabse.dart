import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
FirebaseDatabase database = FirebaseDatabase.instance;
final firebaseApp = Firebase.app();
final rtdb = FirebaseDatabase.instanceFor(app: firebaseApp, databaseURL: 'https://harsha-3a181-default-rtdb.firebaseio.com/');