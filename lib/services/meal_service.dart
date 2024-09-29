import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/meal.dart';

class MealService {
  static const String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';
  static const String _favoritesKey = 'favorites';

  Future<List<Map<String,dynamic>>> fetchMealsByLetter(String letter) async {
    final response = await http.get(Uri.parse('$_baseUrl/search.php?f=$letter'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('API Response: $data');
      return List<Map<String, dynamic>>.from(data['meals'] ?? []);
    } else {
      throw Exception('Failed to load meals');
    }
  }

  Future<List<Map<String, dynamic>>> fetchAllMeals() async {
    List<Map<String, dynamic>> allMeals = [];
    for (var letter in 'abcdefghijklmnopqrstuvwxyz'.split('')) {
      final meals = await fetchMealsByLetter(letter);
      allMeals.addAll(meals);
    }
    return allMeals;
  }

  Future<void> saveFavorites(List<Meal> favoriteMeals) async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteIds = favoriteMeals.map((meal) => meal.id).toList();
    prefs.setString(_favoritesKey, json.encode(favoriteIds));
  }

  Future<List<String>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteIdsString = prefs.getString(_favoritesKey);
    if (favoriteIdsString != null) {
      return List<String>.from(json.decode(favoriteIdsString));
    }
    return [];
  }

  Future<Meal> fetchRandomMeal() async {
    final response = await http.get(Uri.parse('$_baseUrl/random.php'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Meal.fromJson(data['meals'][0]);
    } else {
      throw Exception('Failed to load random meal');
    }
  }


}
