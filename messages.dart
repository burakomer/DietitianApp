class Messages {
  static const String mealExists =
      "Meal doesn't exist! Use add() to add an entry.";
  static const String mealNotExists =
      "Meal already exists! Use update() to update the entry.";
  static const String tooManyCourses = "Course amount is exceeded!";
  static const String planTemplateUpdateSuccess = "Plan updated successfully.";
  static const String planTemplateAddSuccess =
      "Added meal to plan successfully.";

  static const String planTemplateCreateSuccess = "Plan created successfully.";
  static const String planTemplateCreateFailure = "Error on creating plan.";
  static const String planTemplateUploadSuccess =
      "Plan template uploaded successfully.";
  static const String planTemplateUploadFailure =
      "Error on uploading plan template.";
  static const String planTemplateAssignmentSuccess =
      "Successfully assigned plan.";
  static const String planTemplateAssignmentFailure =
      "Error on assigning plan.";
  static const String planTemplateDeleteFailure = "Error on deleting plan.";
  static const String assignedPlanTemplateNotExists =
      "There is no assigned plan.";

  static const String foodsLoadFailure = "Error on loading foods.";
  static const String foodsInitializeFailure = 'Error on initializing food.';

  static const String foodCreateSuccess = "Successfully created food.";
  static const String foodCreateFailure = "Error on creating food.";
  static const String foodDeleteFailure = "Error on deleting food.";
  static const String foodUpdateFailure = "Error on updating food.";

  static const String clientExists = "Client already exists!";
  static const String clientNotExists = "Client doesn't exist.";
  static const String clientFoodCategoryLoadFailure =
      "Error on loading food categories.";

  static const String planGenerationSuccess = "Successfully produced a plan.";
  static const String planGenerationPlanExists =
      "Plan already generated! Load the plan instead.";
  static const String planGenerationPlanNotExists =
      "Plan not generated! Please generate the plan.";

  static String planGenerationFoodIsNull(int parentCategory) {
    return "Couldn't find suitable food in parentCategory: " +
        parentCategory.toString() +
        ".";
  }

  static String deletedMessage(String objectName) {
    return objectName + ' deleted.';
  }
}
