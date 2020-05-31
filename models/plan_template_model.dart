import 'package:diet_app/enums/meals_enum.dart';
import 'package:diet_app/messages.dart';
import 'package:diet_app/models/food_model.dart';
import 'package:flutter/foundation.dart';

class PlanTemplate {
  String documentID;
  String clientDocumentID;
  String name;
  bool assignedPlan;

  /// **Meal:** Represents each meal.
  ///
  /// **List<List<Foods>>:** Courses in a meal. *Snacks have 1, regular meals have 3.*
  ///
  /// **List<Foods>:** Foods in a course. Multiple can be selected to create variation.
  Map<Meal, List<List<Food>>> planMap;

  PlanTemplate({this.name, this.documentID, this.clientDocumentID, this.assignedPlan: false}) {
    planMap = Map<Meal, List<List<Food>>>();
  }

  PlanTemplate.fromMap(Map<String, dynamic> map, {@required String documentID, @required String clientDocumentID}) {
    name = map['name'];
    assignedPlan = map['assignedPlan'];
    map.remove('name');
    map.remove('assignedPlan');
    planMap = map.map<Meal, List<List<Food>>>((key, value) => MapEntry(
        Meal.values.firstWhere((meal) => describeEnum(meal) == key), value));
    this.documentID = documentID;
    this.clientDocumentID = clientDocumentID;
  }

  Map<String, dynamic> toMap() {
    var map = planMap.map<String, dynamic>(
        (meal, list) => MapEntry(describeEnum(meal), list));
    map['name'] = name;
    map['assignedPlan'] = assignedPlan;
    return map;
  }

  void changeName(String newName) {
    if (name != newName) {
      name = newName;
    }
  }

  void add(
      {Meal meal,
      @required List<Food> firstCourse,
      List<Food> secondCourse,
      List<Food> thirdCourse}) {
    if (planMap.containsKey(meal)) {
      throw Exception(Messages.mealExists);
    }

    final courseAmount =
        (meal == Meal.Snack1 || meal == Meal.Snack2 || meal == Meal.Snack3)
            ? 1
            : 3;
    planMap[meal] = List<List<Food>>(courseAmount);

    planMap[meal][1] = firstCourse;

    if (secondCourse != null) {
      if (planMap[meal].length < 1) {
        throw Exception(Messages.tooManyCourses);
      }
      planMap[meal].add(secondCourse);
    }

    if (thirdCourse != null) {
      if (planMap[meal].length < 1) {
        throw Exception(Messages.tooManyCourses);
      }
      planMap[meal][2] = thirdCourse;
    }
  }

  void update(
      {Meal meal,
      List<Food> firstCourse,
      List<Food> secondCourse,
      List<Food> thirdCourse}) {
    if (planMap.containsKey(meal)) {
      throw Exception(Messages.mealNotExists);
    }

    if (firstCourse != null) {
      planMap[meal][0] = firstCourse;
    }

    if (secondCourse != null) {
      if (planMap[meal].length < 1) {
        throw Exception(Messages.tooManyCourses);
      }
      planMap[meal][1] = secondCourse;
    }

    if (thirdCourse != null) {
      if (planMap[meal].length < 1) {
        throw Exception(Messages.tooManyCourses);
      }
      planMap[meal][2] = thirdCourse;
    }
  }

  void read() {
    
  }
}
