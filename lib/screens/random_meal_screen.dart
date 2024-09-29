import 'package:flutter/material.dart';
import '../models/meal.dart';
import 'meal_detail_screen.dart';

class RandomMealScreen extends StatelessWidget {
  final Meal meal;
  final Function(Meal) onToggleFavorite;

  RandomMealScreen({required this.meal, required this.onToggleFavorite});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Random Meal'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(meal.thumbnail),
            SizedBox(height: 20),
            Text(
              meal.name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(meal.category),
            SizedBox(height: 10),
            Text(meal.area),
            SizedBox(height: 20),
            IconButton(
              icon: Icon(
                meal.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: meal.isFavorite ? Colors.red : null,
              ),
              onPressed: () {
                onToggleFavorite(meal);
                Navigator.pop(context); // Close the screen after toggling favorite
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MealDetailScreen(meal: meal),
                  ),
                );
              },
              child: Text('View Details'),
            ),
          ],
        ),
      ),
    );
  }
}
