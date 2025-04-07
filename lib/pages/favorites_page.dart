import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Map<String, dynamic>> favoriteRecipes = [];

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  // Load saved favorites from SharedPreferences
  Future<void> loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favoriteList = prefs.getStringList('favoriteRecipes') ?? [];

    setState(() {
      favoriteRecipes = favoriteList.map((recipe) => json.decode(recipe) as Map<String, dynamic>).toList();
    });
  }

  // Remove a recipe from favorites
  Future<void> removeFavorite(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      favoriteRecipes.removeAt(index);
    });

    // Save updated list
    List<String> updatedList = favoriteRecipes.map((recipe) => json.encode(recipe)).toList();
    await prefs.setStringList('favoriteRecipes', updatedList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: favoriteRecipes.isEmpty
          ? const Center(child: Text('No favorite recipes yet.'))
          : ListView.builder(
        itemCount: favoriteRecipes.length,
        itemBuilder: (context, index) {
          final recipe = favoriteRecipes[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              leading: Image.network(
                recipe['image'] ?? 'https://via.placeholder.com/50',
                width: 50, height: 50, fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Image.asset('assets/images/placeholder.png', width: 50, height: 50),
              ),
              title: Text(recipe['title'] ?? 'Unknown Recipe'),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => removeFavorite(index),
              ),
            ),
          );
        },
      ),
    );
  }
}
