import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/meal.dart';
import '../services/meal_service.dart';
import 'LoginScreen.dart';
import 'main.dart';// Adjust this import based on where your main menu screen is located

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Meal> favoriteMeals = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() async {
    final loadedFavorites = await MealService().loadFavorites();
    setState(() {
      favoriteMeals = loadedFavorites;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MealListScreen()),
            );
          },
          child: Text('Go to Menu'),
        ),
      ),
    );
  }
}
