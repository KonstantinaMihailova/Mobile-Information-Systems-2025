import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/meal_detail.dart';
import '../services/api_service.dart';

class MealDetailScreen extends StatefulWidget {
  final String mealId;

  const MealDetailScreen({
    super.key,
    required this.mealId,
  });

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  final ApiService _apiService = ApiService();
  MealDetail? _mealDetail;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadMealDetails();
  }

  Future<void> _loadMealDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final detail = await _apiService.getMealDetails(widget.mealId);
      setState(() {
        _mealDetail = detail;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _openYoutube(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не може да се отвори YouTube линкот')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final meal = _mealDetail;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Детален рецепт'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Грешка при вчитување на рецепт',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(_errorMessage),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMealDetails,
              child: const Text('Обиди се повторно'),
            ),
          ],
        ),
      )
          : meal == null
          ? const Center(child: Text('Нема податоци за овој рецепт'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                meal.thumbnail,
                height: 220,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return SizedBox(
                    height: 220,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: progress.expectedTotalBytes != null
                            ? progress.cumulativeBytesLoaded /
                            progress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 220,
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.broken_image,
                      size: 60,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            Text(
              meal.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            const Text(
              'Состојки:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...meal.ingredients.map(
                  (ing) => Padding(
                padding:
                const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
                    Expanded(child: Text(ing)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'Инструкции:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              meal.instructions,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),

            if (meal.youtubeUrl != null &&
                meal.youtubeUrl!.isNotEmpty)
              ElevatedButton.icon(
                onPressed: () => _openYoutube(meal.youtubeUrl!),
                icon: const Icon(Icons.play_circle_fill),
                label: const Text('Отвори YouTube видео'),
              ),
          ],
        ),
      ),
    );
  }
}
