import 'package:flutter/material.dart';

import 'transaction_model.dart';

class CategoryModel {
  final String id;
  final String name;
  final IconData icon;
  final TransactionType type;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.type,
  });
}
