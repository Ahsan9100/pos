import 'package:firebase_core/firebase_core.dart';

import '../firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseBootstrap {
  static Future<FirebaseApp> initialize() async {
    try {
      final options = DefaultFirebaseOptions.currentPlatform;
      final app = await Firebase.initializeApp(options: options);
      
      // Enable Firestore Offline Persistence
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
      );
      
      return app;
    } on UnsupportedError catch (error) {
      throw StateError(error.message ?? error.toString());
    }
  }
}
