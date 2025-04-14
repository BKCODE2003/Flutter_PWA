
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'screens/home_screen.dart';
import 'screens/group_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/profile_screen.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await requestAllPermissions(); // Request permissions first
  // await requestBatteryOptimization();
  // await AlarmService.init();  // ✅ Initialize alarm manager
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Future.delayed(Duration(seconds: 2)); // splash delay
  tz.initializeTimeZones();  // ✅ Timezone setup
   

  runApp(const TaskVerseApp());
}

// Comprehensive permission handler
// Future<void> requestAllPermissions() async {
//   if (Platform.isAndroid ||1==1) {
//     // Request notification permission
//     if (await Permission.notification.isDenied) {
//       await Permission.notification.request();
//     }
    
//     // For Android 12+, explicitly request schedule exact alarm permission
//     if (await Permission.scheduleExactAlarm.isDenied) {
//       await Permission.scheduleExactAlarm.request();
//     }
    
//     // Other permissions that might be needed
//     await Permission.activityRecognition.request();
//   }
// }

// Future<void> requestBatteryOptimization() async {
//   if (Platform.isAndroid || 1==1) {
//     final deviceInfo = DeviceInfoPlugin();
//     final androidInfo = await deviceInfo.androidInfo;
//     if (androidInfo.version.sdkInt >= 23) {
//       await Permission.ignoreBatteryOptimizations.request();
//     }
//   }
// }

class TaskVerseApp extends StatefulWidget {
  const TaskVerseApp({super.key});

  @override
  State<TaskVerseApp> createState() => _TaskVerseAppState();
}

Future<bool> getLoginStatus() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('isLoggedIn') ?? false;
}


class _TaskVerseAppState extends State<TaskVerseApp> {
  Locale _appLocale = const Locale('en'); // Default language (English)
  ThemeMode _themeMode = ThemeMode.system; // Default to system theme

  void _changeLanguage(Locale locale) {
    setState(() {
      _appLocale = locale;
    });
  }

  void _changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TaskVerse',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      locale: _appLocale,
      supportedLocales: const [
        Locale('en'),  
        Locale('hi'),
        Locale('mr'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: FutureBuilder<bool>(
        future: getLoginStatus(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox(); // Loading blank
          }
          return snapshot.data == true
              ? MainScreen(
                  onLanguageChanged: _changeLanguage,
                  onThemeChanged: _changeTheme,
                )
              : LoginPage(
                  onLoginSuccess: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('isLoggedIn', true);

                    // Use pushAndRemoveUntil to clear stack and push new route
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => MainScreen(
                          onLanguageChanged: (_) {},
                          onThemeChanged: (_) {},
                        ),
                      ),
                      (Route<dynamic> route) => false, // remove all previous routes
                    );
                  },

                );
        },
      ),

    );
  }
}

class MainScreen extends StatefulWidget {
  final Function(Locale) onLanguageChanged;
  final Function(ThemeMode) onThemeChanged;

  const MainScreen({super.key, required this.onLanguageChanged, required this.onThemeChanged});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(),
      GroupScreen(),
      SettingsScreen(
        onLanguageChanged: widget.onLanguageChanged,
        onThemeChanged: widget.onThemeChanged,
      ),
      const ProfileScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            AppLocalizations.of(context).app_name,  // ✅ Localized app name
            style: const TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: Colors.blue,
        actions: [],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home, color: Colors.blue),
              label: AppLocalizations.of(context).home,  
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.group_outlined),
              activeIcon: const Icon(Icons.group, color: Colors.blue),
              label: AppLocalizations.of(context).groups,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings_outlined),
              activeIcon: const Icon(Icons.settings, color: Colors.blue),
              label: AppLocalizations.of(context).settings,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              activeIcon: const Icon(Icons.person, color: Colors.blue),
              label: AppLocalizations.of(context).profile,
            ),
          ],
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:flutter_alarm_clock/flutter_alarm_clock.dart';

// void main() {
//   runApp(const MyApp());
// }

// /// {@template myApp}
// /// A main class for the Flutter alarm clock example application.
// /// {@endtemplate}
// class MyApp extends StatefulWidget {
//   /// @{@macro myApp}
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('Flutter alarm clock example'),
//         ),
//         body: Center(
//           child: Column(
//             children: <Widget>[
//               Container(
//                 margin: const EdgeInsets.all(25),
//                 child: TextButton(
//                   child: const Text(
//                     'Create alarm at 23:59',
//                     style: TextStyle(fontSize: 20),
//                   ),
//                   onPressed: () {
//                     FlutterAlarmClock.createAlarm(hour: 23, minutes: 40);
//                   },
//                 ),
//               ),
//               Container(
//                 margin: const EdgeInsets.all(25),
//                 child: const TextButton(
//                   onPressed: FlutterAlarmClock.showAlarms,
//                   child: Text(
//                     'Show alarms',
//                     style: TextStyle(fontSize: 20),
//                   ),
//                 ),
//               ),
//               Container(
//                 margin: const EdgeInsets.all(25),
//                 child: TextButton(
//                   child: const Text(
//                     'Create timer for 42 seconds',
//                     style: TextStyle(fontSize: 20),
//                   ),
//                   onPressed: () {
//                     FlutterAlarmClock.createTimer(length: 42);
//                   },
//                 ),
//               ),
//               Container(
//                 margin: const EdgeInsets.all(25),
//                 child: const TextButton(
//                   onPressed: FlutterAlarmClock.showTimers,
//                   child: Text(
//                     'Show Timers',
//                     style: TextStyle(fontSize: 20),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }