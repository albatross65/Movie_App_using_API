import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart'; // For Lottie animations
import 'SplashScreen.dart';
import 'auth_service.dart';
import 'movie_grid.dart'; // Your home screen after login
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart'; // For system UI overlays

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Set system UI overlay color (status bar, navigation bar)
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.deepPurple.shade800, // Status bar color
    systemNavigationBarColor: Colors.deepPurple.shade800, // Navigation bar color
    statusBarIconBrightness: Brightness.light, // For light icons in the status bar
  ));

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Movie Browser',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: SplashScreen(), // Set SplashScreen as the initial route
    );
  }
}

class SignInScreen extends StatefulWidget {
  final AuthService authService;

  const SignInScreen({Key? key, required this.authService}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>(); // Form key for validation
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool isSignUp = false; // Toggle between Sign-In and Sign-Up mode

  @override
  void initState() {
    super.initState();

    // Set the status bar color here
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.deepPurple.shade800, // Purple status bar color
      statusBarIconBrightness: Brightness.light, // Light icons in status bar
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Ensures the layout adjusts for the keyboard
      body: SafeArea(
        child: Container(
          width: double.infinity, // Full width of the screen
          height: double.infinity, // Full height of the screen
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
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical, // Makes the content scrollable when the keyboard appears
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start, // Keep content at the top
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.1), // Adjust height for centering

                  // Lottie Welcome Animation (place it above the form)
                  Lottie.asset('assets/welcome_animation.json', height: 150),

                  SizedBox(height: 30),
                  Text(
                    isSignUp ? 'Create an Account' : 'Welcome Back!',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 30),
                  _buildForm(), // Build the form widget with validation

                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.deepPurple,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shadowColor: Colors.black,
                      elevation: 10,
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _showLoading(context); // Show loading animation during sign-in/sign-up
                        if (isSignUp) {
                          if (_passwordController.text == _confirmPasswordController.text) {
                            User? user = await widget.authService.registerWithEmail(
                              _emailController.text,
                              _passwordController.text,
                            );
                            await Future.delayed(Duration(seconds: 2)); // Ensure loading spinner is visible
                            Navigator.of(context).pop(); // Dismiss loading
                            if (user != null) {
                              _showMessage("Sign-Up Successful");
                              // Navigate to MovieGrid
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (_) => MovieGrid()),
                              );
                            } else {
                              _showError('Sign-Up Failed');
                            }
                          } else {
                            _showError('Passwords do not match');
                          }
                        } else {
                          User? user = await widget.authService.signInWithEmail(
                            _emailController.text,
                            _passwordController.text,
                          );
                          await Future.delayed(Duration(seconds: 2)); // Ensure loading spinner is visible
                          Navigator.of(context).pop(); // Dismiss loading
                          if (user != null) {
                            _showMessage("Sign-In Successful");
                            // Navigate to MovieGrid
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (_) => MovieGrid()),
                            );
                          } else {
                            _showError('Sign-In Failed');
                          }
                        }
                      }
                    },
                    child: Text(
                      isSignUp ? 'Sign Up' : 'Sign In',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        isSignUp = !isSignUp; // Switch between Sign-Up and Sign-In modes
                      });
                    },
                    child: Text(
                      isSignUp
                          ? "Already have an account? Sign In"
                          : "Don't have an account? Sign Up",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.1), // Adjust height to prevent clipping
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Form widget with validation
  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Email Field with Icon and animations
          _buildAnimatedTextField(
            controller: _emailController,
            label: 'Email',
            icon: Icons.email,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          // Password Field with Icon and animations
          _buildAnimatedTextField(
            controller: _passwordController,
            label: 'Password',
            icon: Icons.lock,
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters long';
              }
              return null;
            },
          ),
          if (isSignUp) SizedBox(height: 20),
          // Confirm Password Field (only visible in Sign-Up mode)
          if (isSignUp)
            _buildAnimatedTextField(
              controller: _confirmPasswordController,
              label: 'Confirm Password',
              icon: Icons.lock_outline,
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password';
                }
                if (value != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
        ],
      ),
    );
  }

  // Build text field with floating label and bold text when focused
  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        labelStyle: TextStyle(
          color: Colors.deepPurple, // Regular label style
          fontSize: 16,
        ),
        floatingLabelStyle: TextStyle(
          fontWeight: FontWeight.bold, // Bold when floating
          fontSize: 18, // Larger font when floating
          color: Colors.deepPurple, // Keep the color consistent
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto, // Floating label on focus
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(color: Colors.deepPurple, width: 2.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(color: Colors.white, width: 2.0),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(
          vertical: 15.0,
          horizontal: 20.0,
        ),
      ),
    );
  }

  // Helper method to show a loading dialog with Lottie animation
  void _showLoading(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return Center(
          child: Lottie.asset('assets/loading_animation.json', width: 200, height: 200),
        );
      },
    );
  }

  // Helper method to show an error message
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // Helper method to show success messages
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
