import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diet_app/enums/meals_enum.dart';
import 'package:diet_app/models/client_model.dart';
import 'package:diet_app/models/food_model.dart';
import 'package:diet_app/models/plan_model.dart';
import 'package:diet_app/models/plan_template_model.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../messages.dart';

class DatabaseProvider {
  static final DatabaseProvider instance = DatabaseProvider();
  final CollectionReference clientsCollection =
      Firestore.instance.collection('clients');
  final CollectionReference foodsCollection =
      Firestore.instance.collection('foods');

  final String _plansPath = 'plans';
  final String _planTemplatesPath = 'planTemplates';
  final String _foodsPath = 'foods';
  final String _assignedPlanField = 'assignedPlan';

  // String _localPath;
  // File get _foodsFile {
  //   return File('$_localPath/foods.json');
  // }

  List<Food> foods = List<Food>();

  // void initialize() async {
  //   final directory = await getApplicationDocumentsDirectory();
  //   _localPath = directory.path;

  //   await downloadFoods();
  // }

  Future<bool> addFoods(String clientDocumentID) async {
    Map<String, dynamic> map = jsonDecode(Food.foodList);
    List<Map<String, dynamic>> foodsMap =
        map['foods'].cast<Map<String, dynamic>>();

    CollectionReference foodsCollectionOfClient =
        getFoodsCollectionOfClient(clientDocumentID);
    try {
      foodsMap.forEach((Map<String, dynamic> food) async {
        var newDoc = foodsCollectionOfClient.document();
        await newDoc.setData(food);
      });
      return true;
    } on Exception catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<bool> initializeFoods(String clientDocumentID) async {
    try {
      await createFood(
          clientDocumentID,
          Food(
              name: 'New Food',
              courseLevel: 1,
              category: 1,
              parentCategory: 0,
              dailyLimit: 1,
              weeklyLimit: 1));
      return true;
    } on Exception catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<bool> createFood(String clientDocumentID, Food newFood) async {
    try {
      await Firestore.instance.runTransaction((transaction) async {
        DocumentSnapshot freshFoodDocSnap = await transaction
            .get(getFoodsCollectionOfClient(clientDocumentID).document());

        await transaction.set(freshFoodDocSnap.reference, newFood.toMap());
      });
      return true;
    } on Exception catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  List<Food> readFoodsLocal(
      int courseLevel, int parentCategory, Meal selectedMeal) {
    var query = foods.where((Food food) =>
        food.courseLevel == courseLevel &&
        food.parentCategory == parentCategory);

    bool snack = selectedMeal == Meal.Snack1 ||
        selectedMeal == Meal.Snack2 ||
        selectedMeal == Meal.Snack3;
    bool breakfast = selectedMeal == Meal.Breakfast;
    bool lunch = selectedMeal == Meal.Lunch;
    bool dinner = selectedMeal == Meal.Dinner;

    if (snack) {
      query = query.where((Food food) => food.snack);
    }

    if (breakfast) {
      query = query.where((Food food) => food.breakfast);
    }

    if (lunch) {
      query = query.where((Food food) => food.lunch);
    }

    if (dinner) {
      query = query.where((Food food) => food.dinner);
    }

    return query.toList();
  }

  Future<bool> updateFood(Food updatedFood,
      {@required String clientDocumentID, bool recovery: false}) async {
    try {
      await Firestore.instance.runTransaction((transaction) async {
        DocumentSnapshot freshSnap = await transaction.get(
            getFoodsCollectionOfClient(clientDocumentID)
                .document(updatedFood.documentID));

        if (recovery) {
          transaction.set(freshSnap.reference, updatedFood.toMap());
        } else {
          transaction.update(freshSnap.reference, updatedFood.toMap());
        }
      });
      return true;
    } on Exception catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<bool> deleteFood(
      {@required String clientDocumentID,
      @required String foodToDeleteDocumentID}) async {
    try {
      await Firestore.instance.runTransaction((transaction) async {
        DocumentSnapshot freshFoodDocSnap = await transaction.get(
            getFoodsCollectionOfClient(clientDocumentID)
                .document(foodToDeleteDocumentID));

        await transaction.delete(freshFoodDocSnap.reference);
      });
      return true;
    } on Exception catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  // Future<List<Food>> getFoodsLive(
  //     int courseLevel, int parentCategory, Meal selectedMeal) async {
  //   Query query = foodsCollection.where('courseLevel', isEqualTo: courseLevel);

  //   bool snack = selectedMeal == Meal.Snack1 ||
  //       selectedMeal == Meal.Snack2 ||
  //       selectedMeal == Meal.Snack3;
  //   bool breakfast = selectedMeal == Meal.Breakfast;
  //   bool lunch = selectedMeal == Meal.Lunch;
  //   bool dinner = selectedMeal == Meal.Dinner;

  //   if (snack) {
  //     query = query.where('snack', isEqualTo: true);
  //   }

  //   if (breakfast) {
  //     query = query.where('breakfast', isEqualTo: true);
  //   }

  //   if (lunch) {
  //     query = query.where('lunch', isEqualTo: true);
  //   }

  //   if (dinner) {
  //     query = query.where('dinner', isEqualTo: true);
  //   }

  //   QuerySnapshot querySnap = await query.getDocuments();
  //   QuerySnapshot parentsQuerySnap = await foodsCollection
  //       .where('parentCategory', arrayContains: parentCategory)
  //       .getDocuments();

  //   List<Food> requestedFoods = List<Food>();

  //   parentsQuerySnap.documents.forEach((DocumentSnapshot parentsDocSnap) {
  //     if (querySnap.documents.firstWhere(
  //             (docSnap) => docSnap.documentID == parentsDocSnap.documentID,
  //             orElse: () => null) !=
  //         null) {
  //       requestedFoods.add(Food.fromMap(parentsDocSnap.data));
  //     }
  //   });

  //   requestedFoods.sort((a, b) => a.category.compareTo(b.category));

  //   return requestedFoods;
  // }

  // Future<bool> downloadFoods() async {
  //   try {
  //     List<Map<String, dynamic>> foodMap = List<Map<String, dynamic>>();

  //     QuerySnapshot querySnap = await foodsCollection.getDocuments();
  //     querySnap.documents.forEach((docSnap) {
  //       foodMap.add(docSnap.data);
  //     });

  //     String foodsJson = jsonEncode(foodMap);

  //     await _foodsFile.writeAsString(foodsJson);
  //     await loadFoodsFromFile();
  //     return true;
  //   } catch (e) {
  //     return false;
  //   }
  // }

  // Future<void> loadFoodsFromFile() async {
  //   try {
  //     String foodsJson = await _foodsFile.readAsString();

  //     List<Map<String, dynamic>> foodMaps =
  //         jsonDecode(foodsJson).cast<Map<String, dynamic>>();

  //     foods = List<Food>();
  //     foodMaps.forEach((Map<String, dynamic> map) {
  //       foods.add(Food.fromMap(map));
  //     });
  //     debugPrint(
  //         'Total amount of foods in database: ' + foods.length.toString());
  //   } on Exception catch (e) {
  //     debugPrint(e.toString());
  //   }
  // }

  Future<bool> loadFoods(String clientDocumentID) async {
    try {
      QuerySnapshot querySnap =
          await getFoodsCollectionOfClient(clientDocumentID).getDocuments();

      foods = querySnap.documents
          .map((docSnap) =>
              Food.fromMap(docSnap.data, documentID: docSnap.documentID))
          .toList();
      return true;
    } on Exception catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  CollectionReference getFoodsCollectionOfClient(String clientDocumentID) {
    return clientsCollection.document(clientDocumentID).collection(_foodsPath);
  }

  Stream<List<Food>> foodsOfClientStream(String clientDocumentID) {
    return getFoodsCollectionOfClient(clientDocumentID).snapshots().map(
        (querySnap) => querySnap.documents
            .map((docSnap) =>
                Food.fromMap(docSnap.data, documentID: docSnap.documentID))
            .toList());
  }

  // CLIENT CRUD

  Future<bool> createClient(Client newClient) async {
    try {
      await Firestore.instance.runTransaction((transaction) async {
        QuerySnapshot querySnap = await clientsCollection
            .where('id', isEqualTo: newClient.id)
            .limit(1)
            .getDocuments();

        if (querySnap.documents.length > 0) {
          throw Exception(Messages.clientExists);
        }

        DocumentSnapshot freshClientSnap =
            await transaction.get(clientsCollection.document());

        await transaction.set(freshClientSnap.reference, newClient.toMap());
      });
      return true;
    } on Exception catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<Client> getClient(int clientID) async {
    try {
      QuerySnapshot querySnap = await clientsCollection
          .where('id', isEqualTo: clientID)
          .limit(1)
          .getDocuments();

      if (querySnap.documents.length == 0) {
        return null;
      } else {
        return Client.fromMap(querySnap.documents[0].data,
            documentID: querySnap.documents[0].documentID);
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Stream<List<Client>> clientStream() {
    return clientsCollection.snapshots().map((querySnap) => querySnap.documents
        .map((docSnap) =>
            Client.fromMap(docSnap.data, documentID: docSnap.documentID))
        .toList());
  }

  // PLAN TEMPLATE CRUD

  Future<bool> createPlanTemplate(String clientDocumentID) async {
    try {
      await Firestore.instance.runTransaction((transaction) async {
        QuerySnapshot querySnap =
            await getPlanTemplatesCollectionOfClient(clientDocumentID)
                .getDocuments();

        DocumentSnapshot freshSnap = await transaction.get(
            getPlanTemplatesCollectionOfClient(clientDocumentID).document());

        await transaction.set(
            freshSnap.reference,
            PlanTemplate(
                    name: 'New Plan ' + querySnap.documents.length.toString())
                .toMap());
      });
      return true;
    } on Exception catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<bool> updatePlanTemplate(PlanTemplate updatedPlanTemplate,
      {bool recovery: false}) async {
    try {
      await Firestore.instance.runTransaction((transaction) async {
        DocumentSnapshot freshSnap = await transaction.get(
            getPlanTemplatesCollectionOfClient(
                    updatedPlanTemplate.clientDocumentID)
                .document(updatedPlanTemplate.documentID));
        if (recovery) {
          updatedPlanTemplate.assignedPlan = false;
          await transaction.set(
              freshSnap.reference, updatedPlanTemplate.toMap());
        } else {
          await transaction.update(
              freshSnap.reference, updatedPlanTemplate.toMap());
        }
      });
      return true;
    } on Exception catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<bool> deletePlanTemplate(
      {@required String clientDocumentID,
      @required String planTemplateDocumentID}) async {
    try {
      await Firestore.instance.runTransaction((transaction) async {
        DocumentSnapshot freshSnap = await transaction.get(
            getPlanTemplatesCollectionOfClient(clientDocumentID)
                .document(planTemplateDocumentID));

        await transaction.delete(freshSnap.reference);
      });
      return true;
    } on Exception catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<bool> assignPlanTemplate(
      {@required String clientDocumentID,
      @required String planTemplateToAssignDocumentID,
      String planTemplateToUnassignDocumentID: ''}) async {
    try {
      await Firestore.instance.runTransaction((transaction) async {
        DocumentSnapshot planTempToAssignDocSnap = await transaction.get(
            getPlanTemplatesCollectionOfClient(clientDocumentID)
                .document(planTemplateToAssignDocumentID));

        if (planTemplateToUnassignDocumentID.isNotEmpty) {
          DocumentSnapshot planTempToUnassignDocSnap = await transaction.get(
              getPlanTemplatesCollectionOfClient(clientDocumentID)
                  .document(planTemplateToUnassignDocumentID));
          await transaction.update(
              planTempToUnassignDocSnap.reference, {_assignedPlanField: false});
        }

        await transaction.update(
            planTempToAssignDocSnap.reference, {_assignedPlanField: true});
      });
      return true;
    } on Exception catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Stream<List<PlanTemplate>> planTemplatesOfClientStream(
      String clientDocumentID) {
    return getPlanTemplatesCollectionOfClient(clientDocumentID).snapshots().map(
        (QuerySnapshot querySnap) => querySnap.documents
            .map((DocumentSnapshot docSnap) => PlanTemplate.fromMap(
                docSnap.data,
                documentID: docSnap.documentID,
                clientDocumentID: clientDocumentID))
            .toList());
  }

  CollectionReference getPlanTemplatesCollectionOfClient(
      String clientDocumentID) {
    return clientsCollection
        .document(clientDocumentID)
        .collection(_planTemplatesPath);
  }

  // PLAN GENERATION

  Future<String> generatePlan(String clientDocumentID) async {
    try {
      await loadFoods(clientDocumentID);
      await Firestore.instance.runTransaction((transaction) async {
        DocumentSnapshot freshPlanDocSnap = await transaction
            .get(getPlansCollectionOfClient(clientDocumentID).document('plan'));

        // if (freshPlanDocSnap.exists) {
        //   debugPrint(Messages.planGenerationPlanExists);
        //   await Future.error(Messages.planGenerationPlanExists);
        // }

        QuerySnapshot planTemplatesQuerySnap =
            await getPlanTemplatesCollectionOfClient(clientDocumentID)
                .where(_assignedPlanField, isEqualTo: true)
                .limit(1)
                .getDocuments();

        if (planTemplatesQuerySnap.documents.length == 0) {
          debugPrint(Messages.assignedPlanTemplateNotExists);
          await Future.error(Messages.assignedPlanTemplateNotExists);
        }

        Plan newPlan = Plan.generate(PlanTemplate.fromMap(
          planTemplatesQuerySnap.documents[0].data,
          documentID: planTemplatesQuerySnap.documents[0].documentID,
          clientDocumentID: clientDocumentID,
        ));

        await transaction.set(freshPlanDocSnap.reference, newPlan.toMap());

        await savePlanLocally(newPlan);
      });
      return '';
    } on String catch (e) {
      return e;
    } on Exception catch (e) {
      debugPrint(e.toString());
      return 'null';
    }
  }

  Future<Plan> getPlanOfClient(String clientDocumentID) async {
    try {
      DocumentSnapshot freshPlanDocSnap =
          await getPlansCollectionOfClient(clientDocumentID)
              .document('plan')
              .get();

      if (!freshPlanDocSnap.exists) {
        await Future<String>.error(Messages.planGenerationPlanNotExists);
        return null;
      }
      return Plan.fromMap(freshPlanDocSnap.data);
    } on String catch (e) {
      debugPrint(e);
      return null;
    }
  }

  Future<bool> savePlanLocally(Plan plan) async {
    try {
      final directory = await getExternalStorageDirectory();
      File planFile = File('${directory.path}/plan.json');

      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String json = encoder.convert(plan.toMap());

      await planFile.writeAsString(json);
      return true;
    } on Exception catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<Plan> readPlanLocally() async {
    try {
      final directory = await getExternalStorageDirectory();
      debugPrint(directory.path);
      File planFile = File('${directory.path}/plan.json');

      String json = await planFile.readAsString();
      Map<String, dynamic> map = jsonDecode(json);
      return Plan.fromMap(map);
    } on Exception catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  CollectionReference getPlansCollectionOfClient(String clientDocumentID) {
    return clientsCollection.document(clientDocumentID).collection(_plansPath);
  }
}
