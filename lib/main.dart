import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/achievement_provider.dart';
import 'providers/category_provider.dart';
import 'screens/home_screen.dart';

void main() {
  // Ini penting untuk memastikan package seperti path_provider
  // bisa berjalan sebelum runApp() dipanggil.
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Gunakan MultiProvider untuk mendaftarkan semua provider Anda
    // di level tertinggi aplikasi.
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
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          
          // Tema untuk AppBar
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
          
          // Tema untuk Floating Action Button (FAB)
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Colors.blue.shade800,
            foregroundColor: Colors.white,
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
        
        // Layar pertama yang akan dibuka
        home: HomeScreen(),
      ),
    );
  }
}