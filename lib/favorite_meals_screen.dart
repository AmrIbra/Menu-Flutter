import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'models/meal.dart';

class FavoriteMealsScreen extends StatefulWidget {
  final List<Meal> favoriteMeals;
  final Function(Meal) onToggleFavorite;

  FavoriteMealsScreen(
      {required this.favoriteMeals, required this.onToggleFavorite});

  @override
  _FavoriteMealsScreenState createState() => _FavoriteMealsScreenState();
}

class _FavoriteMealsScreenState extends State<FavoriteMealsScreen> {
  late List<Meal> favoriteMeals;

  @override
  void initState() {
    super.initState();
    favoriteMeals = widget.favoriteMeals;
  }

  void toggleFavorite(Meal meal) {
    setState(() {
      widget.onToggleFavorite(meal);
      favoriteMeals = widget.favoriteMeals.where((meal) => meal.isFavorite).toList();
    });
  }

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
            trailing: IconButton(
              icon: Icon(
              Icons.favorite,
              color: Colors.red,
              ),
          onPressed: () => toggleFavorite(meal),
            ),
          );
        },
      ),
    );
  }
}
