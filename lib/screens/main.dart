import 'package:flutter/material.dart';
import '../services/meal_service.dart';
import '../models/meal.dart';
import 'favorite_meals_screen.dart';
import 'random_meal_screen.dart';

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
  List<Meal> favoriteMeals = [];
  Meal? randomMeal;

  @override
  void initState() {
    super.initState();
    loadFavorites();
    futureMeals = MealService().fetchMeals().then((data) =>
        data.map((meal) => Meal.fromJson(meal)).toList());
  }

  void loadFavorites() async {
    final favoriteIds = await MealService().loadFavorites();
    print('Favorites loaded: $favoriteIds');
    final meals = await futureMeals;
    setState(() {
      favoriteMeals = meals.where((meal) => favoriteIds.contains(meal.id)).toList();
      for (var meal in meals) {
        meal.isFavorite = favoriteIds.contains(meal.id);
      }
    });
  }

  void toggleFavorite(Meal meal) {
    setState(() {
      meal.isFavorite = !meal.isFavorite;
      if (meal.isFavorite) {
        favoriteMeals.add(meal);
      } else {
        favoriteMeals.remove(meal);
      }
      MealService().saveFavorites(favoriteMeals);
      print('Favorites saved: ${favoriteMeals.map((meal) => meal.id).toList()}');
    });
  }

  void showRandomMeal() async {
    final meal = await MealService().fetchRandomMeal();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RandomMealScreen(
          meal: meal,
          onToggleFavorite: toggleFavorite,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meals'),
        actions: [
          IconButton(
              icon: Icon(Icons.favorite),
              onPressed: (){
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FavoriteMealsScreen(
                          favoriteMeals:favoriteMeals,
                          onToggleFavorite: toggleFavorite,
                      ),
                    ),
                );
              },
              )
        ],
      ),
      body: Column(
        children: [
          ElevatedButton(onPressed: showRandomMeal, child: Text('Meal of the Day'),),

          Expanded(
            child: FutureBuilder<List<Meal>>(
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
                        trailing: IconButton(
                          icon:Icon(
                            meal.isFavorite? Icons.favorite : Icons.favorite_border,
                            color: meal.isFavorite? Colors.red : null,
                          ),
                          onPressed: () => toggleFavorite(meal),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          )
        ],
      ),


    );
  }
}
