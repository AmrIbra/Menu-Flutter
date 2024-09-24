import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/meal.dart';

class MealService {
  static const String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';
  static const String _favoritesKey = 'favorites';

  Future<List<dynamic>> fetchMeals() async {
    List<dynamic> allMeals = [];
    for (var letter in 'abcdefghijklmnopqrstuvwxyz'.split('')) {
      final response = await http.get(Uri.parse('$_baseUrl/search.php?f=$letter'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['meals'] != null) {
          allMeals.addAll(data['meals']);
        }
      } else {
        throw Exception('Failed to load meals for letter $letter');
      }
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

}
