import 'package:flutter/material.dart';
import 'services/meal_service.dart';
import 'models/meal.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meal App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MealListScreen(),
    );
  }
}

class MealListScreen extends StatefulWidget {
  @override
  _MealListScreenState createState() => _MealListScreenState();
}

class _MealListScreenState extends State<MealListScreen> {
  late Future<List<Meal>> futureMeals;

  @override
  void initState() {
    super.initState();
    futureMeals = MealService().fetchMeals().then((data) =>
        data.map((meal) => Meal.fromJson(meal)).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meals'),
      ),
      body: FutureBuilder<List<Meal>>(
        future: futureMeals,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No meals found'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final meal = snapshot.data![index];
                return ListTile(
                  leading: Image.network(meal.thumbnail),
                  title: Text(meal.name),
                  subtitle: Text(meal.category),
                );
              },
            );
          }
        },
      ),
    );
  }
}
