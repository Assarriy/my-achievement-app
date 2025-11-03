import 'dart:async';
import 'package:flutter/material.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.1, 0.7, curve: Curves.easeOutCubic),
    ));

    _colorAnimation = ColorTween(
      begin: Color(0xFF667EEA).withOpacity(0.5),
      end: Color(0xFF667EEA),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward();

    // Navigasi otomatis ke Home setelah 3 detik
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: Duration(milliseconds: 800),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F172A),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0F172A),
                  Color(0xFF1E293B),
                  Color(0xFF334155),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.6, 1.0],
              ),
            ),
            child: Stack(
              children: [
                // Animated Background Elements
                Positioned(
                  top: -100,
                  right: -100,
                  child: AnimatedContainer(
                    duration: Duration(seconds: 20),
                    curve: Curves.linear,
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Color(0xFF667EEA).withOpacity(0.1),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -80,
                  left: -80,
                  child: AnimatedContainer(
                    duration: Duration(seconds: 15),
                    curve: Curves.linear,
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Color(0xFF764BA2).withOpacity(0.1),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Floating Particles
                Positioned(
                  top: 120,
                  left: 60,
                  child: AnimatedContainer(
                    duration: Duration(seconds: 2),
                    curve: Curves.easeInOut,
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Color(0xFF667EEA).withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  top: 200,
                  right: 80,
                  child: AnimatedContainer(
                    duration: Duration(seconds: 3),
                    curve: Curves.easeInOut,
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Color(0xFFF093FB).withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 150,
                  left: 100,
                  child: AnimatedContainer(
                    duration: Duration(seconds: 4),
                    curve: Curves.easeInOut,
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Color(0xFF764BA2).withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

                // Main Content
                Center(
                  child: Transform.translate(
                    offset: Offset(0, _slideAnimation.value),
                    child: Opacity(
                      opacity: _fadeAnimation.value,
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Animated Icon Container
                            Container(
                              padding: EdgeInsets.all(30),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF667EEA),
                                    Color(0xFF764BA2),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF667EEA).withOpacity(0.4),
                                    blurRadius: 30,
                                    offset: Offset(0, 15),
                                    spreadRadius: 5,
                                  ),
                                ],
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.auto_awesome,
                                color: Colors.white,
                                size: 70,
                              ),
                            ),
                            const SizedBox(height: 32),

                            // App Title
                            AnimatedBuilder(
                              animation: _colorAnimation,
                              builder: (context, child) {
                                return Text(
                                  "My Journey",
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -0.5,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 20,
                                        color: _colorAnimation.value!.withOpacity(0.5),
                                        offset: Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 12),

                            // Tagline
                            Text(
                              "Track Your Achievements",
                              style: TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.5,
                              ),
                            ),

                            const SizedBox(height: 50),

                            // Animated Loading Indicator
                            Container(
                              width: 80,
                              height: 80,
                              child: Stack(
                                children: [
                                  Center(
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Color(0xFF667EEA),
                                        ),
                                        strokeWidth: 3,
                                        backgroundColor: Color(0xFF334155),
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFF667EEA),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Loading Text
                            Text(
                              "Loading...",
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Version Info (bottom)
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: Column(
                      children: [
                        Text(
                          "v1.0.0",
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Made with ❤️",
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}