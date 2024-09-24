import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'models/meal.dart';

class FavoriteMealsScreen extends StatelessWidget {
  final List<Meal> favoriteMeals;

  FavoriteMealsScreen({required this.favoriteMeals});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Meals'),
      ),
      body: ListView.builder(
        itemCount: favoriteMeals.length,
        itemBuilder: (context, index) {
          final meal = favoriteMeals[index];
          return ListTile(
            leading: Image.network(meal.thumbnail),
            title: Text(meal.name),
            subtitle: Text(meal.category),
          );
        },
      ),
    );
  }
}
