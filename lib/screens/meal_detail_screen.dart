import 'package:flutter/material.dart';
import 'package:menu_flutter/models/meal.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:menu_flutter/widgets/youtube_player_widget.dart';

class MealDetailScreen extends StatelessWidget {
  final Meal meal;

  MealDetailScreen({required this.meal});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(meal.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(meal.thumbnail),
            SizedBox(height: 16),
            Text(
              meal.name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Category: ${meal.category}'),
            SizedBox(height: 8),
            Text('Area: ${meal.area}'),
            SizedBox(height: 16),
            Text(
              'Ingredients:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            ...meal.ingredients.map((ingredient) => Text(ingredient)).toList(),
            SizedBox(height: 16),
            Text(
              'Instructions:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(meal.instructions),
            SizedBox(height: 16),
            if (meal.youtubeUrl.isNotEmpty)
              YouTubePlayerWidget(videoUrl: meal.youtubeUrl),
          ],
        ),
      ),
    );
  }
}
