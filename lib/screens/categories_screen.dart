import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

import '../models/meal_category.dart';
import '../services/api_service.dart';
import '../widgets/category_card.dart';
import '../screens/meal_detail_screen.dart';
import '../screens/favorites_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final ApiService _apiService = ApiService();
  List<MealCategory> _allCategories = [];
  List<MealCategory> _filteredCategories = [];
  bool _isLoading = true;
  String _errorMessage = '';
  final TextEditingController _searchController = TextEditingController();

  // ⚡️ Локални нотификации
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _initNotifications();

    // ⚡️ Пријави се за push notifications
    FirebaseMessaging.instance.subscribeToTopic("daily_recipe");
  }

  // ------------------ Локални notifications ------------------
  void _initNotifications() async {
    tzdata.initializeTimeZones();

    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    const AndroidInitializationSettings androidInit =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings =
    InitializationSettings(android: androidInit);
    await flutterLocalNotificationsPlugin.initialize(initSettings);
  }

  Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'recipe_channel',
      'Recipe Notifications',
      channelDescription: 'Daily recipe reminder',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails =
    NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformDetails,
    );
  }

  void _scheduleDailyNotification() {
    if (_allCategories.isEmpty) return;

    final randomCategory =
    _allCategories[Random().nextInt(_allCategories.length)];

    final now = tz.TZDateTime.now(tz.local);

    // ⚡️ TEST: Notification 10 секунди од сега
    final testTime = now.add(const Duration(seconds: 10));

    flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Recipe of the Day (TEST)',
      randomCategory.name,
      testTime,
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
    );
  }


  // void _scheduleDailyNotification() {
  //   if (_allCategories.isEmpty) return;
  //
  //   final randomCategory = _allCategories[Random().nextInt(_allCategories.length)];
  //
  //   // ⚡️ Се закажува секој ден во 23:15
  //   final now = tz.TZDateTime.now(tz.local);
  //   final scheduledTime = tz.TZDateTime(
  //     tz.local,
  //     now.year,
  //     now.month,
  //     now.day,
  //     23, // час
  //     10, // минути
  //   );
  //
  //   flutterLocalNotificationsPlugin.zonedSchedule(
  //     0,
  //     'Recipe of the Day',
  //     randomCategory.name,
  //     scheduledTime.isBefore(now)
  //         ? scheduledTime.add(const Duration(days: 1))
  //         : scheduledTime,
  //     const NotificationDetails(
  //       android: AndroidNotificationDetails(
  //         'recipe_channel',
  //         'Recipe Notifications',
  //         channelDescription: 'Daily recipe reminder',
  //         importance: Importance.max,
  //         priority: Priority.high,
  //       ),
  //     ),
  //     androidAllowWhileIdle: true,
  //     uiLocalNotificationDateInterpretation:
  //     UILocalNotificationDateInterpretation.absoluteTime,
  //     matchDateTimeComponents: DateTimeComponents.time,
  //   );
  // }






  // ------------------ EXISTING CODE ------------------

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final categories = await _apiService.getCategories();
      setState(() {
        _allCategories = categories;
        _filteredCategories = categories;
        _isLoading = false;
      });

      // ⚡️ Schedule daily notification после што имаме категории
      _scheduleDailyNotification();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterCategories(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCategories = _allCategories;
      } else {
        _filteredCategories = _allCategories.where((category) {
          return category.name
              .toLowerCase()
              .contains(query.toLowerCase()) ||
              category.description
                  .toLowerCase()
                  .contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Категории на јадења'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: 'Омилени рецепти',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FavoritesScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.shuffle),
            tooltip: 'Random рецепт',
            onPressed: () async {
              try {
                final randomMeal = await _apiService.getRandomMeal();
                if (!mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MealDetailScreen(
                      mealId: randomMeal.id,
                    ),
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Грешка при random рецепт: $e'),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterCategories,
              decoration: InputDecoration(
                hintText: 'Пребарувај категории...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _filterCategories('');
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                ? _buildError()
                : _filteredCategories.isEmpty
                ? _buildEmpty()
                : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _filteredCategories.length,
              itemBuilder: (context, index) {
                return CategoryCard(
                  category: _filteredCategories[index],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Грешка при вчитување',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(_errorMessage),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadCategories,
            child: const Text('Обиди се повторно'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Нема пронајдени категории',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
