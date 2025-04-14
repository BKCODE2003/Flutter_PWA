import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'login_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  Future<void> _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmController.text) {
        Fluttertoast.showToast(msg: "Passwords do not match");
        return;
      }

      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );

        // Save user data to Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'username': _usernameController.text.trim(),
          'email': _emailController.text.trim(),
          'uid': userCredential.user!.uid,
          'createdAt': Timestamp.now(),
        });

        Fluttertoast.showToast(msg: "Signup successful!");
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => LoginPage(onLoginSuccess: () {})));
      } catch (e) {
        if (e is FirebaseAuthException) {
          String errorMessage = '';
          switch (e.code) {
            case 'email-already-in-use':
              errorMessage = 'The email address is already in use by another account.';
              break;
            case 'invalid-email':
              errorMessage = 'The email address is not valid.';
              break;
            case 'weak-password':
              errorMessage = 'The password is too weak. It should be at least 6 characters.';
              break;
            default:
              errorMessage = 'An unknown error occurred: ${e.message}';
          }
          Fluttertoast.showToast(msg: errorMessage);
        } else {
          Fluttertoast.showToast(msg: "Error: ${e.toString()}");
        }
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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
                const Text("Create Account", style: TextStyle(color: Color.fromARGB(255, 250, 241, 226), fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildInput("Username", _usernameController),
                      _buildInput("Email", _emailController, isEmail: true),
                      _buildPasswordInput("Password", _passwordController, true),
                      _buildPasswordInput("Confirm Password", _confirmController, false),
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
                  onPressed: _handleSignup,
                  child: const Text("Sign Up"),
                ),
                const SizedBox(height: 16),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                          context, MaterialPageRoute(builder: (_) => LoginPage(onLoginSuccess: () {})));
                    },
                    child: const Text("Already have an account? Login", style: TextStyle(color: Colors.white70)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller, {bool isEmail = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(label, style: const TextStyle(color: Colors.white70)),
        TextFormField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
          decoration: const InputDecoration(
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter $label';
            }
            if (isEmail && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPasswordInput(String label, TextEditingController controller, bool isMainPassword) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(label, style: const TextStyle(color: Colors.white70)),
        TextFormField(
          controller: controller,
          obscureText: isMainPassword ? _obscurePassword : _obscureConfirm,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            suffixIcon: IconButton(
              icon: Icon(
                (isMainPassword ? _obscurePassword : _obscureConfirm)
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: Colors.white70,
              ),
              onPressed: () {
                setState(() {
                  if (isMainPassword) {
                    _obscurePassword = !_obscurePassword;
                  } else {
                    _obscureConfirm = !_obscureConfirm;
                  }
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
