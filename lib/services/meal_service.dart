import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/meal.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MealService {
  static const String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';
  static const String _favoritesKey = 'favorites';
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /*Future<List<Map<String,dynamic>>> fetchMealsByLetter(String letter) async {
    final response = await http.get(Uri.parse('$_baseUrl/search.php?f=$letter'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('API Response: $data');
      return List<Map<String, dynamic>>.from(data['meals'] ?? []);
    } else {
      throw Exception('Failed to load meals');
    }
  }*/

  Future<List<Meal>> fetchAllMeals() async {
    List<Meal> allMeals = [];
    for (var letter in 'abcdefghijklmnopqrstuvwxyz'.split('')) {
      final response = await http.get(Uri.parse('$_baseUrl/search.php?f=$letter'));
      print('Fetching meals for letter $letter');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['meals'] != null) {
          final meals = data['meals'].map<Meal>((mealData) => Meal.fromJson(mealData)).toList();
          allMeals.addAll(meals);
          print('Loaded ${meals.length} meals for letter $letter');
        }
      } else {
        throw Exception('Failed to load meals for letter $letter');
      }
    }
    return allMeals;
  }

  Future<void> saveFavorites(Meal meal) async {
    final prefs = await SharedPreferences.getInstance();
    //final favoriteIds = favoriteMeals.map((meal) => meal.id).toList();
    //prefs.setString(_favoritesKey, json.encode(favoriteIds));

    final user = _auth.currentUser;
    if (user != null) {
      final favoriteRef = _firestore.collection('users').doc(user.uid).collection('favorites').doc(meal.id);
      await favoriteRef.set(meal.toJson());
    }
  }

  Future<void> removeFavorite(Meal meal) async {
    final user = _auth.currentUser;
    if (user != null) {
      final favoriteRef = _firestore.collection('users').doc(user.uid).collection('favorites').doc(meal.id);
      await favoriteRef.delete();
    }
  }

  Future<List<Meal>> loadFavorites() async {
    //final prefs = await SharedPreferences.getInstance();
    //final favoriteIdsString = prefs.getString(_favoritesKey);
    //if (favoriteIdsString != null) {
    //  return List<String>.from(json.decode(favoriteIdsString));
    //}

    final user = _auth.currentUser;
    if (user != null) {
      final response = await _firestore.collection('users').doc(user.uid).collection('favorites').get();
      return response.docs.map((doc) => Meal.fromJson(doc.data() as Map<String, dynamic>)).toList();
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
