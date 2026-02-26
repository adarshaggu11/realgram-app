// Firebase initialization and global configuration
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> initializeFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

// IMPORTANT: After running flutterfire configure, a firebase_options.dart file 
// will be generated automatically. This file contains your Firebase project credentials.
// 
// You should see a file at: lib/firebase_options.dart
// 
// If you don't see it, run: flutterfire configure
