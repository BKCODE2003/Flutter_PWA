import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginPage({super.key, required this.onLoginSuccess});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  Future<void> _handleLogin() async {

    if (_formKey.currentState!.validate()) {
      // showDialog(
      //   context: context,
      //   barrierDismissible: false,
      //   builder: (_) => const Center(child: CircularProgressIndicator()),
      // );

      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        Fluttertoast.showToast(msg: "Login successful!");
        // Navigator.of(context).pop(); // Close loading dialog
        widget.onLoginSuccess();     // Navigate immediately
        // await Future.delayed(Duration(milliseconds: 300));

        // WidgetsBinding.instance.addPostFrameCallback((_) {
        //   widget.onLoginSuccess(); // Navigate to main screen safely
        // });

      } catch (e) {
        // Navigator.of(context).pop(); // Close loading dialog
        Fluttertoast.showToast(msg: "Login failed: ${e.toString()}");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 19, 28, 38),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              const Text("Welcome, Innovative Spirit", style: TextStyle(color: Color.fromARGB(255, 250, 241, 226), fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildInput("Email", _emailController),
                    _buildPasswordInput("Password", _passwordController),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: _handleLogin,
                child: const Text("Login"),
              ),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SignupPage()));
                  },
                  child: const Text("Don't have an account? Sign Up", style: TextStyle(color: Colors.white70)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(label, style: const TextStyle(color: Colors.white70)),
        TextFormField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter $label';
            }
            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
              return 'Enter a valid email';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPasswordInput(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(label, style: const TextStyle(color: Colors.white70)),
        TextFormField(
          controller: controller,
          obscureText: _obscurePassword,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.white70,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a password';
            }
            if (value.length < 6) {
              return 'Password should be at least 6 characters';
            }
            return null;
          },
        ),
      ],
    );
  }
}
