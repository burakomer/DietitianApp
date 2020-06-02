import 'package:diet_app/enums/meals_enum.dart';
import 'package:diet_app/messages.dart';
import 'package:diet_app/models/food_model.dart';
import 'package:diet_app/providers/database_provider.dart';
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

  PlanTemplate(
      {this.name,
      this.documentID,
      this.clientDocumentID,
      this.assignedPlan: false}) {
    planMap = Map<Meal, List<List<Food>>>();

    Meal.values.forEach((Meal meal) {
      int courseAmount =
          (meal == Meal.Snack1 || meal == Meal.Snack2 || meal == Meal.Snack3)
              ? 1
              : 3;
      planMap[meal] = List<List<Food>>(courseAmount);
      for (var i = 0; i < courseAmount; i++) {
        planMap[meal][i] = List<Food>();
      }
    });
  }

  PlanTemplate.fromMap(Map<String, dynamic> map,
      {@required String documentID, @required String clientDocumentID}) {
    name = map['name'];
    assignedPlan = map['assignedPlan'];

    planMap = Map<Meal, List<List<Food>>>();
    Meal.values.forEach((Meal meal) {
      int courseAmount =
          (meal == Meal.Snack1 || meal == Meal.Snack2 || meal == Meal.Snack3)
              ? 1
              : 3;
      planMap[meal] = List<List<Food>>(courseAmount);

      var wrapper = MealWrapper.fromMap(map[describeEnum(meal)]);
      for (var i = 0; i < courseAmount; i++) {
        planMap[meal][i] = wrapper.courses[i]
            .map((String docID) => DatabaseProvider.instance.foods
                .firstWhere((Food food) => food.documentID == docID))
            .toList();
      }
    });

    this.documentID = documentID;
    this.clientDocumentID = clientDocumentID;
  }

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    planMap.forEach((meal, list) {
      map[describeEnum(meal)] = MealWrapper(list).toMap();
    });
    map['name'] = name;
    map['assignedPlan'] = assignedPlan;
    return map;
  }

  void changeName(String newName) {
    if (name != newName) {
      name = newName;
    }
  }

  bool add(
      {@required Meal meal,
      @required List<Food> firstCourse,
      List<Food> secondCourse,
      List<Food> thirdCourse}) {
    planMap[meal][0] = firstCourse.toList();

    if (secondCourse.length != 0) {
      if (planMap[meal].length < 1) {
        return false;
      }
      planMap[meal][1] = secondCourse.toList();
    }

    if (thirdCourse.length != 0) {
      if (planMap[meal].length < 1) {
        return false;
      }
      planMap[meal][2] = thirdCourse.toList();
    }

    return true;
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

  void read() {}
}

class MealWrapper {
  List<List<String>> courses;

  MealWrapper(List<List<Food>> coursesFoods) {
    courses = List<List<String>>();
    coursesFoods.forEach((List<Food> course) =>
        courses.add(course.map((Food food) => food.documentID).toList()));

    // course1 = coursesFoods[0].map((Food food) => food.documentID).toList();
    // if (coursesFoods.length > 1) {
    //   course2 = coursesFoods[1].map((Food food) => food.documentID).toList();
    //   course3 = coursesFoods[2].map((Food food) => food.documentID).toList();
    // } else {
    //   course2 = null;
    //   course3 = null;
    // }
  }

  MealWrapper.fromMap(Map<String, dynamic> map) {
    courses = List<List<String>>(map.keys.length);

    for (var i = 0; i < courses.length; i++) {
      courses[i] = map[i.toString()].cast<String>();
    }
  }

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    for (var i = 0; i < courses.length; i++) {
      map[i.toString()] = courses[i];
    }

    return map;

    // if (course2 != null && course3 != null) {
    //   return {
    //     '0': course1,
    //     '1': course2,
    //     '2': course3,
    //   };
    // } else {
    //   return {'0': course1};
    // }
  }
}
