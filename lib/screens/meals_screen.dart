import 'package:flutter/material.dart';
import '../models/meal.dart';
import '../services/api_service.dart';
import '../services/favorites_service.dart';
import 'meal_detail_screen.dart';

class MealsScreen extends StatefulWidget {
  final String categoryName;

  const MealsScreen({
    super.key,
    required this.categoryName,
  });

  @override
  State<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen> {
  final ApiService _apiService = ApiService();

  List<Meal> _allMeals = [];
  List<Meal> _filteredMeals = [];

  bool _isLoading = true;
  String _errorMessage = '';

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  Future<void> _loadMeals() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final meals =
      await _apiService.getMealsByCategory(widget.categoryName);

      setState(() {
        _allMeals = meals;
        _filteredMeals = meals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterMeals(String query) async {
    if (query.isEmpty) {
      setState(() {
        _filteredMeals = _allMeals;
      });
      return;
    }

    try {
      final results = await _apiService.searchMeals(query);

      setState(() {
        _filteredMeals = results;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Грешка при пребарување: $e'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Јадења: ${widget.categoryName}'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 🔍 SEARCH
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _filterMeals,
              decoration: InputDecoration(
                hintText: 'Пребарувај јадења...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _filterMeals('');
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

          // 📦 CONTENT
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                ? _buildError()
                : _filteredMeals.isEmpty
                ? _buildEmpty()
                : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _filteredMeals.length,
              itemBuilder: (context, index) {
                final meal = _filteredMeals[index];
                return _MealCard(meal: meal);
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
          const Text(
            'Грешка при вчитување јадења',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(_errorMessage),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadMeals,
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
          const Text(
            'Нема пронајдени јадења',
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}

// ======================
// 🧩 MEAL CARD WITH ❤️
// ======================

class _MealCard extends StatefulWidget {
  final Meal meal;

  const _MealCard({required this.meal});

  @override
  State<_MealCard> createState() => _MealCardState();
}

class _MealCardState extends State<_MealCard> {
  @override
  Widget build(BuildContext context) {
    final isFavorite =
    FavoritesService.isFavorite(widget.meal.id);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MealDetailScreen(
                mealId: widget.meal.id,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 🖼 IMAGE
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.network(
                  widget.meal.thumbnail,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // 📝 TITLE + ❤️
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.meal.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      setState(() {
                        FavoritesService.toggleFavorite(widget.meal);
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
