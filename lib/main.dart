import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'firebase_options.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'views/auth/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Stabilkan Firestore di Web: hindari bug internal IndexedDB/persistence.
  if (kIsWeb) {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: false,
    );
  }

  runApp(const WartaApp());
}

class WartaApp extends StatelessWidget {
  const WartaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthViewModel())],
      child: MaterialApp(
        title: 'WARTA',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8B0000)),
          useMaterial3: true,
          textTheme: GoogleFonts.interTextTheme().copyWith(
            bodyLarge: GoogleFonts.inter(fontWeight: FontWeight.w600),
            bodyMedium: GoogleFonts.inter(fontWeight: FontWeight.w500),
          ),
        ),
        // AuthGate mendengarkan Firebase auth state dan route sesuai role
        home: const AuthGate(),
      ),
    );
  }
}
