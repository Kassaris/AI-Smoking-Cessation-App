import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smoking_app/firebase_options.dart';
import 'package:smoking_app/providers/auth_provider.dart' as my_auth;

import 'package:smoking_app/providers/home_screen_provider.dart';
import 'package:smoking_app/providers/notification_provider.dart';
import 'package:smoking_app/providers/user_provider.dart';
import 'package:smoking_app/providers/progress_provider.dart';
import 'package:smoking_app/providers/daily_tips_provider.dart';
import 'package:smoking_app/providers/achievements_provider.dart';
import 'package:smoking_app/providers/leaderboard_provider.dart';
import 'package:smoking_app/screens/add_docs.dart';
import 'package:smoking_app/screens/documents_screen.dart';
import 'package:smoking_app/screens/friends_screen.dart';
import 'package:smoking_app/screens/stats_screen.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'providers/chat_provider.dart';

import 'package:smoking_app/screens/chatbot_screen.dart';
import 'package:smoking_app/screens/daily_tips.dart';
import 'package:smoking_app/screens/leaderboard_screen.dart';
import 'package:smoking_app/screens/welcome_screen.dart';
import 'package:smoking_app/widgets/authWrapper.dart';
import 'screens/achievements_screen.dart';
import 'screens/home_screen.dart';
import 'screens/beat_cravings_screen.dart';
import 'screens/first_time_login_screen.dart';
import 'screens/global_chat_screen.dart';
import 'screens/login_signup_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/health_progress_screen.dart';
import 'screens/talk_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // ⬅️ required
  );
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  tz.initializeTimeZones();

  // Needed on some Android versions
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(
    ChangeNotifierProvider(
      create: (_) => my_auth.AuthProvider(),
      child: const SmokingApp(),
    ),
  );
}

// Required: this must be outside any class
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (message.notification != null) {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);

    await flutterLocalNotificationsPlugin.initialize(initSettings);

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'smoking_app_channel',
      'Smoking App Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      message.notification!.title,
      message.notification!.body,
      platformDetails,
    );
  }
}

class SmokingApp extends StatelessWidget {
  const SmokingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),
        ChangeNotifierProvider(create: (_) => HomeScreenProvider()),
        ChangeNotifierProvider(
          create: (context) => ProgressProvider(context),
        ),
        ChangeNotifierProxyProvider<UserProvider, DailyTipsProvider>(
          create: (context) =>
              DailyTipsProvider(userProvider: context.read<UserProvider>()),
          update: (context, userProvider, dailyTipsProvider) =>
              dailyTipsProvider!..refresh(),
        ),
        ChangeNotifierProxyProvider<UserProvider, AchievementsProvider>(
          create: (context) => AchievementsProvider(
            Provider.of<UserProvider>(context, listen: false),
          ),
          update: (context, userProvider, previous) =>
              AchievementsProvider(userProvider),
        ),
        ChangeNotifierProvider<LeaderboardProvider>(
          create: (_) => LeaderboardProvider(),
        ),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MaterialApp(
        title: 'Smoking Cessation App',
        theme: ThemeData(
          colorScheme: ColorScheme.light(
            primary: Colors.green[800]!, // This changes the picker colors
            secondary: Colors.green[800]!,
          ),
          primarySwatch: Colors.green,
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        home: AuthWrapper(),
        routes: {
          '/home': (context) => const HomeScreen(), // No need to wrap again
          '/login': (context) => const LoginScreen(),
          '/first_time_login': (context) => const FirstTimeLoginScreen(),
          '/beat_cravings': (context) => const BeatCravingsScreen(),
          '/global_chat': (context) => const GlobalChatScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/achievements': (context) => const AchievementsScreen(),
          '/progress': (context) => const ProgressScreen(),
          '/talk_screen': (context) => const TalkScreen(),
          '/dailyTips': (context) => const DailyTipsScreen(),
          '/chatbot': (context) => const ChatbotScreen(),
          '/leaderboard': (context) => LeaderboardScreen(),
          '/starting': (context) => const StartingScreen(),
          '/documents': (context) => const DocumentsScreen(),
          '/addDocs': (context) => const AddDocsScreen(),
          '/friends': (context) => const FriendsScreen(),
          '/stats': (context) => const StatsScreen(),
        },
      ),
    );
  }
}
