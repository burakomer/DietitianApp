import 'package:diet_app/enums/days_enum.dart';
import 'package:diet_app/enums/meals_enum.dart';
import 'package:diet_app/messages.dart';
import 'package:diet_app/models/food_model.dart';
import 'package:diet_app/models/plan_template_model.dart';
import 'package:diet_app/providers/database_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class Plan {
  /// **Meal:** [Meal] value.
  ///
  /// **List<List<Foods>>:** Represents each day.
  ///
  /// **List<Foods>:** Courses in a meal. *Snacks have 1, regular meals have 3.*
  Map<Day, Map<Meal, List<Food>>> planMap;

  Plan.fromMap(Map<String, dynamic> map) {
    planMap = Map<Day, Map<Meal, List<Food>>>();
    Day.values.forEach((Day day) {
      planMap[day] = Map<Meal, List<Food>>();
      Meal.values.forEach((Meal meal) {
        List<String> foodDocs =
            map[describeEnum(day)][describeEnum(meal)].cast<String>();

        planMap[day][meal] = foodDocs
            .map((String docID) => DatabaseProvider.instance.foods.firstWhere(
                  (Food food) => food.documentID == docID
                ))
            .toList();
      });
    });
  }

  Plan.generate(PlanTemplate planTemplate) {
    try {
      planMap = Map<Day, Map<Meal, List<Food>>>();
      Day.values.forEach((Day day) {
        planMap[day] = Map<Meal, List<Food>>();
        try {
          planTemplate.planMap.forEach((meal, courses) {
            /* Determine the course amount. */
            int courseAmount = (meal == Meal.Snack1 ||
                    meal == Meal.Snack2 ||
                    meal == Meal.Snack3)
                ? 1
                : 3;
            /* Create the list with the length of courseAmount */
            planMap[day][meal] = List<Food>(courseAmount);

            /* Create list that will hold the random foods. */
            List<Food> finalCourses = List<Food>(courseAmount);

            for (var i = 0; i < courseAmount; i++) {
              /* Cache the foods. */
              var foodSelections = planTemplate.planMap[meal][i];

              /* This will be used to choose the correct foods according to the previous randomly selected course food. */
              int previousCourseFoodCategory =
                  i == 0 ? 0 : finalCourses[i - 1].category;

              /* Get the possible foods. */
              List<Food> possibleFoods = foodSelections
                  .where((Food food) =>
                      food.parentCategory == previousCourseFoodCategory)
                  .toList();

              /* Now, pick a random food. */
              possibleFoods.shuffle();
              for (var randomFoodIndex = 0;
                  randomFoodIndex < possibleFoods.length;
                  randomFoodIndex++) {
                Food randomFood = possibleFoods[randomFoodIndex];

                /* Check the limits first. */
                int dailyLimitCount = 0;
                int weeklyLimitCount = 0;

                for (var a = 0; a < day.index + 1; a++) {
                  for (var b = 0; b < Meal.values.length - 1; b++) {
                    if (a == day.index) {
                      if (b == meal.index) {
                        break;
                      }
                    }

                    if (planMap[Day.values[a]][Meal.values[b]]
                        .contains(randomFood)) {
                      weeklyLimitCount++;
                      if (a == day.index) {
                        dailyLimitCount++;
                      }
                    }
                  }
                }

                /* If the limits are okay, add it to the list and break the loop.
            Else, continue. */
                if (weeklyLimitCount < randomFood.weeklyLimit &&
                    dailyLimitCount < randomFood.dailyLimit) {
                  finalCourses[i] = randomFood;
                  break;
                }

                /* If the random food couldn't be selected because of low limits or not being included, throw an exception. */
                if (randomFoodIndex == possibleFoods.length - 1) {
                  if (finalCourses[randomFoodIndex - 1] == null) {
                    throw Exception(Messages.planGenerationFoodIsNull(
                        previousCourseFoodCategory));
                  }
                }
              }

              /* Add the selected courses to the final list. */
              planMap[day][meal] = finalCourses.toList();
            }
          });
        } on Exception catch (e) {
          rethrow;
        }
      });
    } on Exception {
      rethrow;
    }
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = Map<String, dynamic>();

    planMap.forEach((day, meals) {
      map[describeEnum(day)] = Map<String, dynamic>();
      meals.forEach((meal, courses) {
        map[describeEnum(day)][describeEnum(meal)] =
            courses.map((Food food) => food.documentID).toList();
      });
    });
    return map;
  }
}
