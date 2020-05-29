import 'package:diet_app/models/food_model.dart';
import 'package:flutter/foundation.dart';

class FoodCategory {
  List<Food> foods;
  int category;
  int parentCategory;

  FoodCategory(this.foods, {@required category, @required parentCategory,});

  int compareRelationship(int otherParentCategory) {
    if (otherParentCategory == category) {
      return -1;
    }
    else {
      return 0;
    }
  }
}