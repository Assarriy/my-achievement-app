import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/achievement_provider.dart';
import 'screens/home_screen.dart';

void main() {
  // Pastikan binding Flutter diinisialisasi sebelum menjalankan app
  // Ini penting jika Anda melakukan operasi async sebelum runApp
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Gunakan ChangeNotifierProvider untuk "menyediakan" state
    // AchievementProvider ke seluruh widget tree di bawahnya.
    return ChangeNotifierProvider(
      create: (ctx) => AchievementProvider(), // Membuat instance provider
      child: MaterialApp(
        title: 'My Achievements',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          // Tema untuk AppBar
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 1,
            iconTheme: IconThemeData(color: Colors.black),
            titleTextStyle: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Tema untuk FAB
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Colors.blue.shade800,
          ),
        ),
        debugShowCheckedModeBanner: false,
        home: HomeScreen(), // Layar utama Anda
      ),
    );
  }
}