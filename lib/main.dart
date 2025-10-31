import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/achievement_provider.dart';
import 'providers/category_provider.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';

void main() {
<<<<<<< HEAD
  WidgetsFlutterBinding.ensureInitialized();
=======
  // Ini penting untuk memastikan package seperti path_provider
  // bisa berjalan sebelum runApp() dipanggil.
  WidgetsFlutterBinding.ensureInitialized();
  
>>>>>>> f5f55c91bea006535cabfec94592e275fe521ae3
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
=======
    // Gunakan MultiProvider untuk mendaftarkan semua provider Anda
    // di level tertinggi aplikasi.
>>>>>>> f5f55c91bea006535cabfec94592e275fe521ae3
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => AchievementProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => CategoryProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'My Achievements',
        debugShowCheckedModeBanner: false,
        
        // Menambahkan tema yang konsisten untuk aplikasi
        theme: ThemeData(
          primarySwatch: Colors.red, // 🔴 ubah ke merah biar nyatu dengan tema splash
          visualDensity: VisualDensity.adaptivePlatformDensity,
<<<<<<< HEAD
=======
          
          // Tema untuk AppBar
>>>>>>> f5f55c91bea006535cabfec94592e275fe521ae3
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 1,
            iconTheme: IconThemeData(color: Colors.black87),
            titleTextStyle: TextStyle(
              color: Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
<<<<<<< HEAD
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Colors.red,
=======
          
          // Tema untuk Floating Action Button (FAB)
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Colors.blue.shade800,
            foregroundColor: Colors.white,
>>>>>>> f5f55c91bea006535cabfec94592e275fe521ae3
          ),

          // Tema untuk ChoiceChip (di halaman Add/Edit)
          chipTheme: ChipThemeData(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
            labelStyle: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
            secondaryLabelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            selectedColor: Colors.blue.shade600,
            disabledColor: Colors.grey.shade300,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
              side: BorderSide(color: Colors.grey.shade400)
            )
          ),

          // Tema untuk input form
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.blue.shade800, width: 2.0),
            ),
          )
        ),
<<<<<<< HEAD
        debugShowCheckedModeBanner: false,

        // ⬇️ ubah dari HomeScreen ke SplashScreen
        home: const SplashScreen(),
        routes: {
          '/home': (ctx) => const HomeScreen(),
        },
=======
        
        // Layar pertama yang akan dibuka
        home: HomeScreen(),
>>>>>>> f5f55c91bea006535cabfec94592e275fe521ae3
      ),
    );
  }
}