import 'package:flutter/material.dart';
import '../models/meal.dart';
import '../services/favorites_service.dart';

class MealCard extends StatefulWidget {
  final Meal meal;
  final VoidCallback onTap;

  const MealCard({
    super.key,
    required this.meal,
    required this.onTap,
  });

  @override
  State<MealCard> createState() => _MealCardState();
}

class _MealCardState extends State<MealCard> {
  @override
  Widget build(BuildContext context) {
    final isFavorite = FavoritesService.isFavorite(widget.meal.id);

    return Card(
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: widget.onTap,
              child: Image.network(
                widget.meal.thumbnail,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.meal.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    setState(() {
                      FavoritesService.toggleFavorite(widget.meal);
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
