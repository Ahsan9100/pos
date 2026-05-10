import 'package:firebase_core/firebase_core.dart';

import '../firebase_options.dart';

class FirebaseBootstrap {
  static Future<FirebaseApp> initialize() async {
    try {
      final options = DefaultFirebaseOptions.currentPlatform;
      return Firebase.initializeApp(options: options);
    } on UnsupportedError catch (error) {
      throw StateError(error.message ?? error.toString());
    }
  }
}
