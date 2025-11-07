import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nexux/screens/main_sceen.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nexux/home_page.dart';
import 'package:nexux/login_page.dart';
import 'package:nexux/profile_page.dart';
import 'package:nexux/signup_page.dart';
import 'firebase_options.dart';
import 'providers/cart_provider.dart';
import 'providers/favorite_provider.dart';
import 'services/firestore_service.dart';
String? __app_id;
String? __firebase_config;
String? __initial_auth_token;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final firestoreService = FirestoreService();
  if (__initial_auth_token != null) {
    try {
      await FirebaseAuth.instance.signInWithCustomToken(__initial_auth_token!);
      print('Main: Signed in with custom token.');
    } on FirebaseAuthException catch (e) {
      print('Main: Error signing in with custom token: ${e.message}');
    } catch (e) {
      print('Main: General error during custom token sign-in: $e');
    }
  } else {
    print('Main: No initial custom auth token provided.');
  }
  runApp(MyApp(firestoreService: firestoreService));
}
class MyApp extends StatelessWidget {
  final FirestoreService firestoreService;
  const MyApp({super.key, required this.firestoreService});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<FirestoreService>.value(value: firestoreService),
        ChangeNotifierProvider(create: (_) => CartProvider(firestoreService)),
        ChangeNotifierProvider(create: (_) => FavoriteProvider(firestoreService)),
      ],
      child: MaterialApp(
        title: 'Nexus',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0A0A0A),
          canvasColor: const Color(0xFF0F0F0F),
          primaryColor: const Color(0xFF00E676),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF00E676),
            onPrimary: Colors.black,
            secondary: Color(0xFF7C4DFF),
            onSecondary: Colors.white,
            tertiary: Color(0xFF00BCD4),
            onTertiary: Colors.black,
            surface: Color(0xFF151515),
            onSurface: Colors.white,
            background: Color(0xFF0A0A0A),
            onBackground: Colors.white,
            error: Color(0xFFFF5252),
            onError: Colors.black,
          ),
          textTheme: TextTheme(
            displayLarge: GoogleFonts.orbitron(color: Colors.white, fontSize: 57, fontWeight: FontWeight.bold),
            displayMedium: GoogleFonts.orbitron(color: Colors.white, fontSize: 45),
            displaySmall: GoogleFonts.orbitron(color: Colors.white, fontSize: 36),
            headlineLarge: GoogleFonts.orbitron(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold),
            headlineMedium: GoogleFonts.orbitron(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
            headlineSmall: GoogleFonts.orbitron(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
            titleLarge: GoogleFonts.orbitron(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600),
            titleMedium: GoogleFonts.orbitron(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.w500),
            titleSmall: GoogleFonts.orbitron(color: Colors.white54, fontSize: 14, fontWeight: FontWeight.w500),
            bodyLarge: GoogleFonts.roboto(color: Colors.white, fontSize: 16),
            bodyMedium: GoogleFonts.roboto(color: Colors.white70, fontSize: 14),
            bodySmall: GoogleFonts.roboto(color: Colors.white54, fontSize: 12),
            labelLarge: GoogleFonts.orbitron(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
            labelMedium: GoogleFonts.orbitron(color: Colors.white70, fontSize: 12),
            labelSmall: GoogleFonts.orbitron(color: Colors.white54, fontSize: 10),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,
            titleTextStyle: TextStyle(
              color: Color(0xFF00E676),
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
            ),
            iconTheme: IconThemeData(color: Colors.white70, size: 28),
          ),
          cardTheme: CardThemeData(
            color: const Color(0xFF151515).withOpacity(0.4),
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.white.withOpacity(0.08), width: 1.0),
            ),
            shadowColor: const Color(0xFF00E676).withOpacity(0.2),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: const Color(0xFF00E676),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              textStyle: GoogleFonts.orbitron(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
              elevation: 15,
              shadowColor: const Color(0xFF00E676).withOpacity(0.8),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF151515).withOpacity(0.7),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: const Color(0xFF00E676).withOpacity(0.4), width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: const Color(0xFF7C4DFF).withOpacity(0.8), width: 2.5),
            ),
            labelStyle: GoogleFonts.roboto(color: Colors.white70),
            hintStyle: GoogleFonts.roboto(color: Colors.white54),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: const Color(0xFF151515).withOpacity(0.8),
            selectedItemColor: const Color(0xFF00E676),
            unselectedItemColor: Colors.white54,
            selectedLabelStyle: GoogleFonts.orbitron(fontSize: 12, fontWeight: FontWeight.bold),
            unselectedLabelStyle: GoogleFonts.orbitron(fontSize: 10),
            type: BottomNavigationBarType.fixed,
            elevation: 20,
          ),
        ),
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasData) {
              return const MainScreen();
            }
            return const LoginPage();
          },
        ),
        routes: {
          '/login': (context) => const LoginPage(),
          '/signup': (context) => const SignupPage(),
          '/home': (context) => const HomePage(),
          '/profile': (context) => const ProfilePage(),
        },
      ),
    );
  }
}