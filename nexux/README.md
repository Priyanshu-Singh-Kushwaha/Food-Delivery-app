Nexux Food App
A modern, responsive food ordering application built with Flutter and Firebase. Nexux provides a seamless experience for users to browse food items, add them to a cart, manage favorites, and place orders with simulated payment options. User data, including profiles, cart items, favorites, and orders, is persistently stored and managed using Firebase Firestore.

🚀 Features
User Authentication: Secure user registration and login using Firebase Authentication (Email/Password).

User Profile Management: Users can view and update their profile details (name, email, phone, address).

Product Browsing: Display a list of food items with details like name, price, and restaurant.

Shopping Cart: Add, remove, and update quantities of items in the shopping cart.

Favorites Management: Mark and unmark food items as favorites for quick access.

Order Placement: Simulate payment processing (Google Pay, Paytm, Cash on Delivery) and place orders.

Order Status Tracking: View the status and details of placed orders in real-time.

Firebase Integration: Leverages Firebase Authentication and Firestore for backend services.

State Management: Uses the provider package for efficient state management across the app.

Responsive UI: Designed to provide a good user experience across different screen sizes.

Theming: A dark, futuristic theme with vibrant accent colors.

🛠️ Technologies Used
Flutter: UI Toolkit for building natively compiled applications for mobile, web, and desktop from a single codebase.

Firebase:

Firebase Authentication: For user registration and login.

Cloud Firestore: NoSQL document database for storing application data (products, cart, favorites, user profiles, orders).

Firebase CLI & Emulators: For local development and testing of Firebase services.

Dart: The programming language for Flutter.

Provider: For state management.

uuid package: For generating unique IDs (e.g., for anonymous users or new documents).

google_fonts package: For custom typography.

image_picker package: (If implemented for profile pictures/food analysis) For picking images.

http package: (If implemented for external APIs like food analysis) For making HTTP requests.

geolocator package: (If implemented for location services) For location access.

⚙️ Setup Instructions
Follow these steps to get the Nexux Food App running on your local machine.

Prerequisites
Flutter SDK (v3.0.0 or higher recommended)

Firebase CLI

Node.js (required for Firebase CLI)

A web browser (e.g., Chrome) for running the web app.
3. Firebase Project Setup
If you don't have a Firebase project set up, follow these steps:

Go to the Firebase Console.

Click "Add project" and follow the prompts to create a new Firebase project.

Enable Firebase services:

Authentication: Go to "Authentication" -> "Get started" -> "Sign-in method" tab. Enable "Email/Password" provider.

Firestore Database: Go to "Firestore Database" -> "Create database". Choose "Start in production mode" (you'll set up rules later) and select a location.

Add a Web App to your Firebase Project:

In your Firebase project overview, click the web icon </> to add a web app.

Register your app (you can use any nickname).

Copy your Firebase configuration (the firebaseConfig object).

Generate firebase_options.dart:

Install FlutterFire CLI: dart pub global activate flutterfire_cli

Configure FlutterFire for your project: flutterfire configure

Select your Firebase project.

Choose web as the platform.

This will generate a lib/firebase_options.dart file with your project's Firebase configuration.

4. Firebase Emulator Suite Setup
To run and test your app locally with Firebase services:

Install Emulators: If you haven't already, install the Firebase Emulators:

firebase init emulators
# Select Firestore, Authentication (and any other services you might use like Storage)
# Choose default ports (e.g., 8081 for Firestore, 9099 for Auth)

Start Emulators: In your project's root directory, run:

firebase emulators:start

This will start the emulators and provide a local UI at http://localhost:4000. Keep this terminal window open.

5. Update Firebase Configuration in main.dart
Ensure your lib/main.dart file is configured to connect to the emulators in debug mode. The provided code already includes this, but double-check the host and port values match your emulator setup:

// lib/main.dart
import 'package:flutter/foundation.dart' show kDebugMode;
// ... other imports

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (kDebugMode) {
    FirebaseFirestore.instance.settings = const Settings(
      host: 'localhost:8081', // Your Firestore emulator port
      sslEnabled: false,
      persistenceEnabled: false,
    );
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099); // Your Auth emulator port
    print('*** Using Firebase Emulator Suite for development ***');
  } else {
    print('*** Using Production Firebase (Release Mode) ***');
  }

  final firestoreService = FirestoreService();
  // ... rest of main function
}

6. Update Firestore Security Rules
You need to update your Firestore Security Rules to allow read/write access to the necessary collections for authenticated users.

Go to your Firebase Console.

Navigate to Firestore Database -> Rules tab.

Replace your existing rules with the following. These rules ensure that authenticated users can only read/write their own data within the artifacts/{appId}/users/{userId}/ path.

rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow read/write for all user-specific collections under artifacts/{appId}/users/{userId}
    match /artifacts/{appId}/users/{userId}/{collection}/{document} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Explicitly allow for user profile (if user_data is a specific document)
    match /artifacts/{appId}/users/{userId}/profile/user_data {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Explicitly allow for cart_items
    match /artifacts/{appId}/users/{userId}/cart_items/{cartItemId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Explicitly allow for favorite_items
    match /artifacts/{appId}/users/{userId}/favorite_items/{favoriteItemId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Explicitly allow for food_analyses
    match /artifacts/{appId}/users/{userId}/food_analyses/{analysisId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Explicitly allow for orders
    match /artifacts/{appId}/users/{userId}/orders/{orderId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}

Click Publish.

7. Run the Application
With the Firebase Emulators running and your project configured, you can now run the Flutter app:

flutter run -d chrome --web-hostname localhost --web-port 5000

This will launch the application in your Chrome browser.

📁 Project Structure (Key Files)
nexux/
├── lib/
│   ├── main.dart                      # Main entry point, Firebase init, Provider setup
│   ├── firebase_options.dart          # Auto-generated Firebase configuration
│   ├── models/
│   │   ├── app_order.dart             # Defines the structure for user orders (renamed from order.dart)
│   │   ├── cart_item.dart             # Defines the structure for items in the cart
│   │   ├── food_analysis_result.dart  # Defines the structure for food analysis results
│   │   ├── product.dart               # Defines the structure for food products
│   │   └── user_profile.dart          # Defines the structure for user profile data
│   ├── providers/
│   │   ├── cart_provider.dart         # Manages cart state and interacts with FirestoreService
│   │   └── favorite_provider.dart     # Manages favorite items state and interacts with FirestoreService
│   ├── screens/
│   │   ├── cart_screen.dart           # UI for the shopping cart, payment simulation, order placement
│   │   ├── home_screen.dart           # UI for browsing products (shop)
│   │   ├── login_page.dart            # User login UI
│   │   ├── main_screen.dart           # Bottom navigation bar and main screen routing
│   │   ├── order_confirmation_screen.dart # Displays order status after placement
│   │   ├── profile_page.dart          # User profile UI
│   │   └── signup_page.dart           # User registration UI
│   └── services/
│       └── firestore_service.dart     # Centralized service for all Firestore interactions
├── pubspec.yaml                       # Project dependencies and metadata
└── README.md                          # This file

📊 Firestore Data Structure
Data in Firestore is organized under a specific path to ensure multi-tenancy and user-specific data isolation within the Canvas environment:

/artifacts/{appId}/users/{userId}/
├── profile/
│   └── user_data (document)
├── cart_items/ (collection)
│   └── {productId} (document)
├── favorite_items/ (collection)
│   └── {productId} (document)
├── food_analyses/ (collection)
│   └── {analysisId} (document)
└── orders/ (collection)
    └── {orderId} (document)

{appId}: The ID of the application, dynamically provided by the Canvas environment or defaults to default-app-id in local development.

{userId}: The Firebase User ID of the currently authenticated user (or a randomly generated UUID for anonymous users if no authentication token is provided).

🚀 Future Enhancements
Real Payment Gateway Integration: Replace the simulated payment with actual SDKs (e.g., Stripe, Razorpay, Google Pay's production APIs, Paytm's production APIs).

Order History: A dedicated screen to view all past orders.

Search & Filtering: Implement search functionality for food items and filters by restaurant, category, etc.

Admin Panel: A separate interface for restaurant owners/admins to manage products, orders, and users.

Push Notifications: For order status updates.

Location Services: Integrate real-time location for delivery tracking.

User Reviews & Ratings: Allow users to rate products and restaurants.

Image Uploads: Allow users to upload profile pictures or food images.