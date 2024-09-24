import 'dart:convert';
import 'package:http/http.dart' as http;

class MealService {
  static const String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';

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

}
