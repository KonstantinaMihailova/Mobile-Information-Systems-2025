import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/meal_category.dart';
import '../models/meal.dart';
import '../models/meal_detail.dart';



class ApiService {
  static const String baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  Future<List<MealCategory>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/categories.php'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> categoriesJson = data['categories'] ?? [];

        return categoriesJson
            .map((json) => MealCategory.fromJson(json))
            .toList();
      } else {
        throw Exception('Грешка при вчитување: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Грешка при API повик: $e');
    }
  }

  Future<List<Meal>> getMealsByCategory(String category) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/filter.php?c=$category'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> mealsJson = data['meals'] ?? [];

        return mealsJson.map((json) => Meal.fromJson(json)).toList();
      } else {
        throw Exception('Грешка при вчитување јадења: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Грешка при API повик за јадења: $e');
    }
  }

  Future<List<Meal>> searchMeals(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/search.php?s=$query'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> mealsJson = data['meals'] ?? [];

        if (mealsJson.isEmpty) {
          return [];
        }

        return mealsJson.map((json) => Meal.fromJson(json)).toList();
      } else {
        throw Exception(
            'Грешка при пребарување на јадења: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Грешка при API повик за пребарување: $e');
    }
  }

  Future<MealDetail> getMealDetails(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/lookup.php?i=$id'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> mealsJson = data['meals'] ?? [];

        if (mealsJson.isEmpty) {
          throw Exception('Нема пронајден рецепт за ова ID');
        }

        return MealDetail.fromJson(mealsJson.first);
      } else {
        throw Exception(
            'Грешка при вчитување на деталите: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Грешка при API повик за деталите: $e');
    }
  }

  Future<MealDetail> getRandomMeal() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/random.php'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> mealsJson = data['meals'] ?? [];

        if (mealsJson.isEmpty) {
          throw Exception('Нема податоци за random рецепт');
        }

        return MealDetail.fromJson(mealsJson.first);
      } else {
        throw Exception(
          'Грешка при вчитување random рецепт: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Грешка при API повик за random рецепт: $e');
    }
  }



}