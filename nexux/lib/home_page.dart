import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nexux/food_recommender_page.dart';
import 'package:nexux/health_dashboard_page.dart';
import 'package:nexux/login_page.dart';
import 'package:nexux/profile_page.dart';
import 'package:nexux/vitals_page.dart';
import 'package:provider/provider.dart';
import 'package:nexux/services/firestore_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String _currentLocationText = 'Detecting location...';

  Map<String, dynamic> _vitalsConsumed = {
    'Calories': {'value': 120, 'target': 2000},
    'Proteins': {'value': 6, 'target': 100},
    'Carbs': {'value': 15, 'target': 250},
    'Fats': {'value': 4, 'target': 70},
  };

  late FirestoreService _firestoreService;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _firestoreService = Provider.of<FirestoreService>(context);
    _firestoreService.getFoodAnalysisResultsStream().listen((results) {
      if (mounted) {
        setState(() {
          _vitalsConsumed = {
            'Calories': {'value': 0, 'target': 2000},
            'Proteins': {'value': 0, 'target': 100},
            'Carbs': {'value': 0, 'target': 250},
            'Fats': {'value': 0, 'target': 70},
          };
          for (var result in results) {
            _vitalsConsumed['Calories']['value'] = (_vitalsConsumed['Calories']['value'] + result.calories).clamp(0, _vitalsConsumed['Calories']['target'] * 2);
            _vitalsConsumed['Proteins']['value'] = (_vitalsConsumed['Proteins']['value'] + result.protein).clamp(0, _vitalsConsumed['Proteins']['target'] * 2);
            _vitalsConsumed['Carbs']['value'] = (_vitalsConsumed['Carbs']['value'] + result.carbs).clamp(0, _vitalsConsumed['Carbs']['target'] * 2);
            _vitalsConsumed['Fats']['value'] = (_vitalsConsumed['Fats']['value'] + result.fats).clamp(0, _vitalsConsumed['Fats']['target'] * 2);
          }
        });
      }
    });
  }

  void _updateVitals(Map<String, dynamic> newNutritionalData) {
    setState(() {
      _vitalsConsumed['Calories']['value'] = (_vitalsConsumed['Calories']['value'] + (newNutritionalData['calories'] ?? 0)).clamp(0, _vitalsConsumed['Calories']['target'] * 2);
      _vitalsConsumed['Proteins']['value'] = (_vitalsConsumed['Proteins']['value'] + (newNutritionalData['protein'] ?? 0)).clamp(0, _vitalsConsumed['Proteins']['target'] * 2);
      _vitalsConsumed['Carbs']['value'] = (_vitalsConsumed['Carbs']['value'] + (newNutritionalData['carbs'] ?? 0)).clamp(0, _vitalsConsumed['Carbs']['target'] * 2);
      _vitalsConsumed['Fats']['value'] = (_vitalsConsumed['Fats']['value'] + (newNutritionalData['fats'] ?? 0)).clamp(0, _vitalsConsumed['Fats']['target'] * 2);
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToHealthDashboard() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const HealthDashboardPage(),
      ),
    );
  }

  void _navigateToProfilePage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ProfilePage(),
      ),
    );
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logged out successfully!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (Route<dynamic> route) => false,
      );
    }
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        setState(() {
          _currentLocationText = 'Location services disabled.';
        });
      }
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          setState(() {
            _currentLocationText = 'Location permissions denied.';
          });
        }
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        setState(() {
          _currentLocationText = 'Location permissions permanently denied.';
        });
      }
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      if (mounted) {
        setState(() {
          _currentLocationText = 'Current Location';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentLocationText = 'Failed to get location.';
        });
      }
      print('Error getting location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = <Widget>[
      FoodRecommenderPage(
        onVitalsUpdate: _updateVitals,
        currentVitals: _vitalsConsumed,
      ),
      VitalsPage(vitalsConsumed: _vitalsConsumed),
    ];

    final user = FirebaseAuth.instance.currentUser;
    final String userInitial = user?.displayName?.isNotEmpty == true
        ? user!.displayName![0].toUpperCase()
        : (user?.email?.isNotEmpty == true ? user!.email![0].toUpperCase() : 'U');

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 0,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _currentLocationText,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              Text(
                'NEXUX',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.show_chart_rounded, size: 28),
            onPressed: _navigateToHealthDashboard,
            tooltip: 'Access Comprehensive Data',
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _navigateToProfilePage,
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: Text(
                userInitial,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu_rounded),
            label: 'Meals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monitor_heart_rounded),
            label: 'Vitals',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
        unselectedItemColor: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
        onTap: _onItemTapped,
        backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        type: Theme.of(context).bottomNavigationBarTheme.type,
        selectedLabelStyle: Theme.of(context).bottomNavigationBarTheme.selectedLabelStyle,
        unselectedLabelStyle: Theme.of(context).bottomNavigationBarTheme.unselectedLabelStyle,
        elevation: Theme.of(context).bottomNavigationBarTheme.elevation,
      ),
    );
  }
}