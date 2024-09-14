import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'auth_service.dart'; // Your AuthService
import 'main.dart'; // Your main.dart where SignInScreen is located

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _textController;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Text animation controller
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Fade-in effect for the text
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    ));

    // Scale animation for the text
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.elasticOut,
    ));

    // Start text animation after a slight delay
    Future.delayed(Duration(seconds: 2), () {
      _textController.forward();
    });

    // Navigate to SignInScreen after 5 seconds
    Future.delayed(Duration(seconds: 6), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => SignInScreen(authService: AuthService())),
      );
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade800,
              Colors.deepPurple.shade400,
              Colors.deepPurple.shade200,
              Colors.deepPurple.shade800,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Full-screen Lottie animation for splash effect
            Center(
              child: Lottie.asset(
                'assets/splash_animation.json', // Full-screen splash animation file
                width:  300,
                height:  300,
               ),
            ),

            // Animated text with fade-in and scaling effects
            Positioned(
              bottom: 100, // Place the text at the bottom
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeInAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Movie Browser',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              blurRadius: 10.0,
                              color: Colors.black38,
                              offset: Offset(3.0, 3.0),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Your Ultimate Movie Experience',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
