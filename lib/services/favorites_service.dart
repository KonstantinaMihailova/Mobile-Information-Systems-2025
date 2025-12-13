import '../models/meal.dart';

class FavoritesService {
  static final List<Meal> _favorites = [];

  static List<Meal> get favorites => _favorites;

  static bool isFavorite(String mealId) {
    return _favorites.any((meal) => meal.id == mealId);
  }

  static void toggleFavorite(Meal meal) {
    if (isFavorite(meal.id)) {
      _favorites.removeWhere((m) => m.id == meal.id);
    } else {
      _favorites.add(meal);
    }
  }
}
