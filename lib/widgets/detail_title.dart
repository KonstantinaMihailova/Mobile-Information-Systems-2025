import 'package:flutter/material.dart';

class DetailTitle extends StatelessWidget {
  final int id;
  final String name;
  final bool isPast;

  const DetailTitle({
    super.key,
    required this.id,
    required this.name,
    required this.isPast,
  });

  @override
  Widget build(BuildContext context) {
    final Color baseColor =
    isPast ? Colors.blueGrey.shade700 : Colors.lightGreen.shade700;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: baseColor.withValues(alpha: 0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Text(
              '#$id',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: baseColor,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Text(
            name.toUpperCase(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
