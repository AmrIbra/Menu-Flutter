import 'package:flutter/material.dart';
import '../services/meal_service.dart';
import '../models/meal.dart';
import 'favorite_meals_screen.dart';
import 'random_meal_screen.dart';
import 'meal_detail_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/home_screen.dart';
import '../screens/LoginScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      home: AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          return HomeScreen();
        }
        return LoginScreen();
      },
    );
  }
}

class MealListScreen extends StatefulWidget {
  @override
  _MealListScreenState createState() => _MealListScreenState();
}

class _MealListScreenState extends State<MealListScreen> {
  Future<List<Meal>>? futureMeals;
  List<Meal> allMeals = [];
  List<Meal> displayedMeals = [];
  List<Meal> favoriteMeals = [];
  TextEditingController searchController = TextEditingController();
  Meal? randomMeal;

  @override
  void initState() {
    super.initState();
    loadFavorites();
    futureMeals = MealService().fetchAllMeals();

    }


  void loadFavorites() async {
    final favoriteIds = await MealService().loadFavorites();
    print('Favorites loaded: $favoriteIds');
    //final meals = await futureMeals;
    setState(() {
      favoriteMeals = favoriteIds;
    });
  }

  void toggleFavorite(Meal meal) async {
    setState(() {
      meal.isFavorite = !meal.isFavorite;
      if (meal.isFavorite) {
        favoriteMeals.add(meal);
        MealService().saveFavorites(meal);
      } else {
        favoriteMeals.removeWhere((m) => m.id == meal.id);
        MealService().removeFavorite(meal);
      }

    });
  }

  void filterMeals(String query) {
    final filteredMeals = allMeals.where((meal) {
      final mealName = meal.name.toLowerCase();
      final mealCategory = meal.category.toLowerCase();
      final mealArea = meal.area.toLowerCase();
      final searchQuery = query.toLowerCase();

      return mealName.contains(searchQuery) ||
          mealCategory.contains(searchQuery) ||
          mealArea.contains(searchQuery);
    }).toList();

    setState(() {
      displayedMeals = filteredMeals;
    });
    //print('Filtered meals: ${displayedMeals.map((meal) => meal.name).toList()}');
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
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search by name, category, or country',
              border: InputBorder.none,
              hintStyle: TextStyle(color: Colors.blueGrey),
            ),
            style: TextStyle(color: Colors.black),
            onChanged: filterMeals,
          ),

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
                      meal.isFavorite = favoriteMeals.any((m) => m.id == meal.id);
                      return ListTile(
                        leading: Image.network(meal.thumbnail),
                        title: Text(meal.name),
                        subtitle: Text('${meal.category} - ${meal.area}'),
                        trailing: IconButton(
                          icon:Icon(
                            meal.isFavorite? Icons.favorite : Icons.favorite_border,
                            color: meal.isFavorite? Colors.red : null,
                          ),
                          onPressed: () => toggleFavorite(meal),
                        ),
                        onTap: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MealDetailScreen(meal: meal))
                          );
                        },
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
