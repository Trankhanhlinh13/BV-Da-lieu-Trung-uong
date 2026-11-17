import 'package:flutter/material.dart';

class MealMenuItem {
  const MealMenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.icon,
    required this.color,
  });

  final String id;
  final String name;
  final String description;
  final int price;
  final IconData icon;
  final Color color;
}

class MealCartLine {
  const MealCartLine({required this.item, required this.quantity});

  final MealMenuItem item;
  final int quantity;

  MealCartLine copyWith({int? quantity}) =>
      MealCartLine(item: item, quantity: quantity ?? this.quantity);
}

class MealCartPayload {
  const MealCartPayload({
    required this.recipientName,
    required this.date,
    required this.meal,
    required this.lines,
  });

  final String recipientName;
  final DateTime date;
  final String meal;
  final List<MealCartLine> lines;
}
