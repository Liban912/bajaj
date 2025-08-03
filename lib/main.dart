import 'package:bajaj/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mp;
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'auth/auth_service.dart';
import 'auth/auth_screen.dart';
import 'services/location_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await setup();
  runApp(const MyApp());
}

Future<void> setup() async {
  try {
    await dotenv.load(fileName: ".env");
    mp.MapboxOptions.setAccessToken(dotenv.env["MAPBOX_ACCESS_TOKEN"]!);
  } catch (e) {
    print("Error loading .env file: $e");
    print(
        "Please create a .env file in the project root with your Mapbox access token:");
    print("MAPBOX_ACCESS_TOKEN=your_actual_token_here");
    // You can also set a default token here for development
    // mp.MapboxOptions.setAccessToken("your_default_token_here");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => LocationService()),
      ],
      child: Consumer<AuthService>(
        builder: (context, authService, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Bajaj GPS Tracking',
            theme: ThemeData.dark().copyWith(
              scaffoldBackgroundColor:
                  const Color.fromARGB(255, 0, 0, 0), // Navy
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFF93032E), // Burgundy
                onPrimary: Colors.white,
                secondary: Color(0xFF034C3C), // Brunswick Green
              ),
              textTheme: const TextTheme(
                bodyLarge: TextStyle(color: Colors.white),
              ),
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.black.withOpacity(0.1),
              ),
            ),
            home: authService.isAuthenticated
                ? const HomePage()
                : const AuthScreen(),
          );
        },
      ),
    );
  }
}
