// import 'package:flutter/material.dart';
// import '../l10n/app_localizations.dart';

// class ProfileScreen extends StatelessWidget {
//   const ProfileScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(AppLocalizations.of(context).profile),
//         centerTitle: true,
//         backgroundColor: Colors.blueAccent,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             // Profile Picture with Shadow
//             Center(
//               child: Container(
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black26,
//                       blurRadius: 8,
//                       spreadRadius: 2,
//                     ),
//                   ],
//                 ),
//                 child: CircleAvatar(
//                   radius: 60,
//                   backgroundImage: AssetImage('assets/images/Profile.jpg'), 
//                   backgroundColor: Colors.grey[300],
//                 ),
//               ),
//             ),
//             SizedBox(height: 16),

//             // Name
//             Text(
//               "Bhushan Kor", // Replace with dynamic user name
//               style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 22,
//                   ),
//             ),
//             SizedBox(height: 8),

//             // Email
//             Text(
//               "2022.bhushan.kor@ves.ac.in", // Replace with dynamic email
//               style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                     color: Colors.grey[600],
//                     fontSize: 16,
//                   ),
//             ),
//             SizedBox(height: 24),

//             // Logout Button
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton.icon(
//                 onPressed: () {
//                   // Dummy logout action
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text(AppLocalizations.of(context).logoutSuccess),
//                       backgroundColor: Colors.green,
//                     ),
//                   );
//                 },
//                 icon: Icon(Icons.logout),
//                 label: Text(AppLocalizations.of(context).logout),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.red,
//                   foregroundColor: Colors.white,
//                   padding: EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../l10n/app_localizations.dart';
// import '../main.dart'; // Needed to restart app on logout
// import 'package:firebase_auth/firebase_auth.dart'; 

// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});

//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   String _name = '';
//   String _email = '';

//   @override
//   void initState() {
//     super.initState();
//     _loadUserInfo();
//   }

//   Future<void> _loadUserInfo() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _name = prefs.getString('username') ?? 'User';
//       _email = prefs.getString('email') ?? 'example@email.com';
//     });
//   }

//   Future<void> _logout() async {
//     await FirebaseAuth.instance.signOut();
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('isLoggedIn', false);
//     await prefs.remove('username');
//     await prefs.remove('email');
//     runApp(const TaskVerseApp()); // Restart app to go back to login
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(AppLocalizations.of(context).profile),
//         centerTitle: true,
//         backgroundColor: Colors.blueAccent,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             // Profile Picture with Shadow
//             Center(
//               child: Container(
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black26,
//                       blurRadius: 8,
//                       spreadRadius: 2,
//                     ),
//                   ],
//                 ),
//                 child: CircleAvatar(
//                   radius: 60,
//                   backgroundImage: AssetImage('assets/images/Profile.jpg'),
//                   backgroundColor: Colors.grey[300],
//                 ),
//               ),
//             ),
//             SizedBox(height: 16),

//             // Dynamic Name
//             Text(
//               _name,
//               style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 22,
//                   ),
//             ),
//             SizedBox(height: 8),

//             // Dynamic Email
//             Text(
//               _email,
//               style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                     color: Colors.grey[600],
//                     fontSize: 16,
//                   ),
//             ),
//             SizedBox(height: 24),

//             // Logout Button
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton.icon(
//                 onPressed: _logout,
//                 icon: Icon(Icons.logout),
//                 label: Text(AppLocalizations.of(context).logout),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.red,
//                   foregroundColor: Colors.white,
//                   padding: EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import '../main.dart'; // Needed to restart app on logout
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = '';
  String _email = '';
  String _uid = '';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _uid = user.uid;
        _email = user.email ?? 'example@email.com';
      });

      // Fetch user details from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          _name = userDoc['username'] ?? 'User';
        });
      }
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const TaskVerseApp(),
      ),
      (Route<dynamic> route) => false,
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).profile),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Picture with Shadow
            Center(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage('assets/images/Profile.jpg'),
                  backgroundColor: Colors.grey[300],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Dynamic Name
            Text(
              _name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
            ),
            SizedBox(height: 8),

            // Dynamic Email
            Text(
              _email,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
            ),
            SizedBox(height: 24),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _logout,
                icon: Icon(Icons.logout),
                label: Text(AppLocalizations.of(context).logout),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
