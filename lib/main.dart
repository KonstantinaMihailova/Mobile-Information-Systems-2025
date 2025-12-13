import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import 'firebase_options.dart';
import 'screens/categories_screen.dart';

// ⚡️ За background нотификации
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('Background message: ${message.messageId}');
}

// Локални нотификации plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Background Firebase handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Иницијација на локални нотификации
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings =
  InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Иницијација на timezone
  tzdata.initializeTimeZones();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MealDB Recipes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
      ),
      home: const CategoriesScreen(),
    );
  }
}

// ⚡️ Функции за дневна нотификација
Future<void> scheduleDailyNotification(List<String> recipes) async {
  final randomRecipe = recipes[Random().nextInt(recipes.length)];

  await flutterLocalNotificationsPlugin.zonedSchedule(
    0,
    'Recipe of the Day',
    randomRecipe,
    tz.TZDateTime.local(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      12, // време на нотификацијата (12:00)
      0,
    ),
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'recipe_channel',
        'Recipe Notifications',
        channelDescription: 'Daily recipe reminder',
        importance: Importance.max,
        priority: Priority.high,
      ),
    ),
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation:
    UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.time,
  );
}

// ⚡️ Иницијализација на Firebase Messaging и permission
Future<void> requestNotificationPermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');
}
