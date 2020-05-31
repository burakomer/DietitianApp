import 'package:diet_app/messages.dart';
import 'package:diet_app/models/client_model.dart';
import 'package:diet_app/models/food_category_model.dart';
import 'package:diet_app/models/food_model.dart';
import 'package:diet_app/models/plan_template_model.dart';
import 'package:diet_app/providers/database_provider.dart';
import 'package:diet_app/ui/widgets/checkbox_element.dart';
import 'package:diet_app/ui/widgets/snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:string_validator/string_validator.dart';

class AdminClientOptionsView extends StatefulWidget {
  AdminClientOptionsView({Key key}) : super(key: key);

  @override
  _AdminClientOptionsViewState createState() => _AdminClientOptionsViewState();
}

class _AdminClientOptionsViewState extends State<AdminClientOptionsView>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    _tabController.addListener(_handleTabIndex);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabIndex);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabIndex() {
    setState(() {});
  }

  final assignedPlanPopupMenu = {'Delete'};
  final planPopupMenu = {'Assign', 'Delete'};

  final foodPopupMenu = {
    'Change Name',
    'Change Daily Limit',
    'Change Weekly Limit',
    'Change Meals',
    'Delete'
  };
  final foodAddPopupMenu = {'Add Food', 'Add Food as Child'};

  Client client;
  PlanTemplate assignedPlan;
  int assignedPlanIndex;
  bool isFirstLoad = true;
  bool isCreatingPlan = false;
  bool isLoadingFoods = false;

  bool isMovingFood = false;
  Food foodToMove;

  bool isDeletingFood = false;
  Food deletedFoodBeforeDestroyed;

  bool isDeletingPlan = false;
  PlanTemplate deletedPlanBeforeDestroyed;

  @override
  Widget build(BuildContext context) {
    client = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      appBar: AppBar(
        title: Text(client.fullName),
        actions: <Widget>[
          Builder(builder: (context) {
            return PopupMenuButton<String>(
              onSelected: (String value) async {
                switch (value) {
                  case 'Initialize':
                    bool success = await DatabaseProvider.instance
                        .initializeFoods(client.documentID);

                    if (!success) {
                      Scaffold.of(context).showSnackBar(SnackBar(
                        content: SnackbarContent(
                            icon: Icons.error,
                            title: Messages.foodsInitializeFailure),
                      ));
                    }
                    break;
                  case 'Load Sample Data':
                    bool success = await DatabaseProvider.instance
                        .addFoods(client.documentID);

                    if (!success) {
                      Scaffold.of(context).showSnackBar(SnackBar(
                        content: SnackbarContent(
                            icon: Icons.error,
                            title: Messages.foodsInitializeFailure),
                      ));
                    }
                    break;
                  default:
                }
              },
              itemBuilder: (BuildContext context) {
                return <String>['Initialize', 'Load Sample Data']
                    .map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            );
          }),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        shape: _tabController.index == 0 ? CircularNotchedRectangle() : null,
        child: TabBar(
          controller: _tabController,
          tabs: <Widget>[
            Tab(
              iconMargin: EdgeInsets.all(1),
              icon: Icon(Icons.assignment),
              text: 'Plans',
            ),
            Tab(
              iconMargin: EdgeInsets.all(1),
              icon: Icon(Icons.fastfood),
              text: 'Foods',
            ),
          ],
        ),
      ),
      floatingActionButton: getFAB(context),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[getPlansTabView(context), getFoodsTabView(context)],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget getPlansTabView(BuildContext context) {
    return StreamBuilder<List<PlanTemplate>>(
      stream: DatabaseProvider.instance
          .planTemplatesOfClientStream(client.documentID),
      builder:
          (BuildContext context, AsyncSnapshot<List<PlanTemplate>> snapshot) {
        var handleOnTap = (int index) async {
          setState(() {
            isLoadingFoods = true;
          });
          bool success =
              await DatabaseProvider.instance.loadFoods(client.documentID);
          if (success) {
            Navigator.of(context).pushNamed('AdminClientPlanEdit',
                arguments: snapshot.data[index]);
          } else {
            Scaffold.of(context).showSnackBar(SnackBar(
                content: SnackbarContent(
              icon: Icons.error,
              title: Messages.foodsLoadFailure,
            )));
          }
          setState(() {
            isLoadingFoods = false;
          });
        };

        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        } else {
          assignedPlan = snapshot.data.firstWhere(
              (planTemp) => planTemp.assignedPlan,
              orElse: () => null);

          return Container(
            child: Column(
              children: <Widget>[
                assignedPlan == null
                    ? ListTile(
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              'Assign a plan from here',
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic,
                                  fontSize: 16.0),
                            ),
                            IconButton(
                              icon: Icon(Icons.arrow_downward),
                              onPressed: null,
                            ),
                          ],
                        ),
                      )
                    : Card(
                        elevation: 5.0,
                        child: ListTile(
                          title: Text(assignedPlan.name),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text('Assigned Plan',
                                  style: TextStyle(color: Colors.grey)),
                              PopupMenuButton<String>(
                                onSelected: (String value) async {
                                  switch (value) {
                                    case 'Delete':
                                      setState(() {
                                        deletedPlanBeforeDestroyed =
                                            assignedPlan;
                                      });

                                      bool success = await DatabaseProvider
                                          .instance
                                          .deletePlanTemplate(
                                              clientDocumentID:
                                                  client.documentID,
                                              planTemplateDocumentID:
                                                  assignedPlan.documentID);
                                      if (success) {
                                        Scaffold.of(context)
                                            .showSnackBar(SnackBar(
                                          duration: Duration(seconds: 6),
                                          content: SnackbarContent(
                                            icon: Icons.delete_forever,
                                            title: deletedPlanBeforeDestroyed
                                                    .name +
                                                ' deleted.',
                                          ),
                                          action: SnackBarAction(
                                            label: 'Undo',
                                            onPressed: () async {
                                              await DatabaseProvider.instance
                                                  .updatePlanTemplate(
                                                      deletedPlanBeforeDestroyed,
                                                      recovery: true);
                                              setState(() {
                                                deletedPlanBeforeDestroyed =
                                                    null;
                                              });
                                            },
                                          ),
                                        ));
                                      } else {
                                        Scaffold.of(context)
                                            .showSnackBar(SnackBar(
                                                content: SnackbarContent(
                                          icon: Icons.delete_forever,
                                          title: Messages
                                              .planTemplateDeleteFailure,
                                        )));
                                        setState(() {
                                          deletedPlanBeforeDestroyed = null;
                                        });
                                      }
                                      break;
                                    default:
                                  }
                                },
                                itemBuilder: (BuildContext context) {
                                  return assignedPlanPopupMenu
                                      .map((String choice) {
                                    return PopupMenuItem<String>(
                                      value: choice,
                                      child: Text(choice),
                                    );
                                  }).toList();
                                },
                              ),
                            ],
                          ),
                          onTap: isLoadingFoods
                              ? null
                              : () => handleOnTap(assignedPlanIndex),
                        ),
                      ),
                Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      if (snapshot.data[index].assignedPlan) {
                        assignedPlan = snapshot.data[index];
                        assignedPlanIndex = index;
                        return Container();
                      }
                      return ListTile(
                        title: Text(snapshot.data[index].name),
                        onTap: isLoadingFoods ? null : () => handleOnTap(index),
                        trailing: PopupMenuButton<String>(
                          onSelected: (String value) async {
                            switch (value) {
                              case 'Assign':
                                bool success = await DatabaseProvider.instance
                                    .assignPlanTemplate(
                                        clientDocumentID: client.documentID,
                                        planTemplateToAssignDocumentID:
                                            snapshot.data[index].documentID,
                                        planTemplateToUnassignDocumentID:
                                            assignedPlan == null
                                                ? ''
                                                : assignedPlan.documentID);
                                if (success) {
                                  setState(() {
                                    assignedPlan = snapshot.data[index];
                                    assignedPlanIndex = index;
                                  });
                                  Scaffold.of(context).showSnackBar(SnackBar(
                                      content: SnackbarContent(
                                    icon: Icons.check,
                                    title:
                                        Messages.planTemplateAssignmentSuccess,
                                  )));
                                } else {
                                  Scaffold.of(context).showSnackBar(SnackBar(
                                      content: SnackbarContent(
                                    icon: Icons.error,
                                    title:
                                        Messages.planTemplateAssignmentFailure,
                                  )));
                                }
                                break;
                              case 'Delete':
                                setState(() {
                                  deletedPlanBeforeDestroyed =
                                      snapshot.data[index];
                                });

                                bool success = await DatabaseProvider.instance
                                    .deletePlanTemplate(
                                        clientDocumentID: client.documentID,
                                        planTemplateDocumentID:
                                            snapshot.data[index].documentID);
                                if (success) {
                                  Scaffold.of(context).showSnackBar(SnackBar(
                                    duration: Duration(seconds: 6),
                                    content: SnackbarContent(
                                      icon: Icons.delete_forever,
                                      title: Messages.deletedMessage(
                                          deletedPlanBeforeDestroyed.name),
                                    ),
                                    action: SnackBarAction(
                                      label: 'Undo',
                                      onPressed: () async {
                                        await DatabaseProvider.instance
                                            .updatePlanTemplate(
                                                deletedPlanBeforeDestroyed,
                                                recovery: true);
                                        setState(() {
                                          deletedPlanBeforeDestroyed = null;
                                        });
                                      },
                                    ),
                                  ));
                                } else {
                                  Scaffold.of(context).showSnackBar(SnackBar(
                                      content: SnackbarContent(
                                    icon: Icons.delete_forever,
                                    title: Messages.planTemplateDeleteFailure,
                                  )));
                                  setState(() {
                                    deletedPlanBeforeDestroyed = null;
                                  });
                                }
                                break;
                              default:
                            }
                          },
                          itemBuilder: (BuildContext context) {
                            return planPopupMenu.map((String choice) {
                              return PopupMenuItem<String>(
                                value: choice,
                                child: Text(choice),
                              );
                            }).toList();
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget getFoodsTabView(BuildContext context) {
    return StreamBuilder(
      stream: DatabaseProvider.instance.foodsOfClientStream(client.documentID),
      builder: (BuildContext context, AsyncSnapshot<List<Food>> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        } else {
          /* Before building the list, create a new list that groups foods according to their categories. */
          List<FoodCategory> foodCategories = new List<FoodCategory>();

          /* First, sort the list accourding to category indexes, so that the next process works correctly. */
          snapshot.data.sort((a, b) => a.category.compareTo(b.category));

          snapshot.data.forEach((Food food) {
            if (foodCategories.length < food.category) {
              /* If the category doesn't exist in the list */
              List<Food> foods = <Food>[food];

              foodCategories.add(FoodCategory(foods,
                  category: food.category,
                  parentCategory: food.parentCategory,
                  courseLevel: food.courseLevel));
            } else {
              /* Meaning that the category is already created */
              foodCategories[food.category - 1].foods.add(food);
            }
          });

          /* Then, sort them according to their category and parent category. (Childs come after the parent.) */
          foodCategories
              .sort((a, b) => a.compareRelationship(b.parentCategory));

          return ListView.builder(
            itemCount: foodCategories.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                padding: EdgeInsets.fromLTRB(
                    4 +
                        getFoodIndentation(
                            foodCategories[index].foods[0].courseLevel),
                    2,
                    4,
                    2),
                child: Card(
                  elevation: getFoodCategoryElevation(
                      foodCategories[index].foods[0].courseLevel),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Flexible(
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: foodCategories[index]
                                .foods
                                .map((Food food) => ListTile(
                                      /* Indentation depending on the course level. */
                                      title: Text(foodCategories[index]
                                              .foods[0]
                                              .courseLevel
                                              .toString() +
                                          '. ' +
                                          food.name),
                                      subtitle: Text('DLimit: ${food.dailyLimit} | WLimit: ${food.weeklyLimit}' +
                                          '\n${food.breakfast ? 'Breakfast' : ''}' +
                                          '${(food.breakfast && (food.lunch || food.dinner || food.snack)) ? ' ' : ''}' +
                                          '${food.lunch ? 'Lunch' : ''}' +
                                          '${(food.lunch && (food.dinner || food.snack)) ? ' ' : ''}' +
                                          '${food.dinner ? 'Dinner' : ''}' +
                                          '${(food.dinner && food.snack) ? ' ' : ''}' +
                                          '${food.snack ? 'Snack' : ''}'),
                                      isThreeLine: true,
                                      trailing: PopupMenuButton(
                                        itemBuilder: (BuildContext context) {
                                          return foodPopupMenu
                                              .map((String choice) {
                                            return PopupMenuItem<String>(
                                              value: choice,
                                              child: Text(choice),
                                            );
                                          }).toList();
                                        },
                                        onSelected: (String value) async {
                                          switch (value) {
                                            case 'Change Name':
                                              String newName =
                                                  await changeFoodNameDialog(
                                                      context);
                                              if (newName.isNotEmpty) {
                                                Food updatedFood = food;
                                                updatedFood.name = newName;
                                                bool success =
                                                    await DatabaseProvider
                                                        .instance
                                                        .updateFood(updatedFood,
                                                            clientDocumentID:
                                                                client
                                                                    .documentID);

                                                if (!success) {
                                                  Scaffold.of(context)
                                                      .showSnackBar(SnackBar(
                                                          content:
                                                              SnackbarContent(
                                                    icon: Icons.error,
                                                    title: Messages
                                                        .foodUpdateFailure,
                                                  )));
                                                }
                                              }
                                              break;
                                            case 'Change Daily Limit':
                                              String newDailyLimit =
                                                  await changeFoodDailyWeeklyLimitDialog(
                                                      context,
                                                      title: 'Daily');
                                              if (newDailyLimit.isNotEmpty) {
                                                Food updatedFood = food;
                                                updatedFood.dailyLimit =
                                                    int.parse(newDailyLimit);
                                                bool success =
                                                    await DatabaseProvider
                                                        .instance
                                                        .updateFood(updatedFood,
                                                            clientDocumentID:
                                                                client
                                                                    .documentID);

                                                if (!success) {
                                                  Scaffold.of(context)
                                                      .showSnackBar(SnackBar(
                                                          content:
                                                              SnackbarContent(
                                                    icon: Icons.error,
                                                    title: Messages
                                                        .foodUpdateFailure,
                                                  )));
                                                }
                                              }
                                              break;
                                            case 'Change Weekly Limit':
                                              String newWeeklyLimit =
                                                  await changeFoodDailyWeeklyLimitDialog(
                                                      context,
                                                      title: 'Weekly');
                                              if (newWeeklyLimit.isNotEmpty) {
                                                Food updatedFood = food;
                                                updatedFood.weeklyLimit =
                                                    int.parse(newWeeklyLimit);
                                                bool success =
                                                    await DatabaseProvider
                                                        .instance
                                                        .updateFood(updatedFood,
                                                            clientDocumentID:
                                                                client
                                                                    .documentID);

                                                if (!success) {
                                                  Scaffold.of(context)
                                                      .showSnackBar(SnackBar(
                                                          content:
                                                              SnackbarContent(
                                                    icon: Icons.error,
                                                    title: Messages
                                                        .foodUpdateFailure,
                                                  )));
                                                }
                                              }
                                              break;
                                            case 'Delete':
                                              setState(() {
                                                deletedFoodBeforeDestroyed =
                                                    food;
                                              });

                                              bool success =
                                                  await DatabaseProvider
                                                      .instance
                                                      .deleteFood(
                                                          clientDocumentID:
                                                              client.documentID,
                                                          foodToDeleteDocumentID:
                                                              food.documentID);
                                              if (success) {
                                                Scaffold.of(context)
                                                    .showSnackBar(SnackBar(
                                                  duration:
                                                      Duration(seconds: 6),
                                                  content: SnackbarContent(
                                                    icon: Icons.delete_forever,
                                                    title: Messages.deletedMessage(
                                                        deletedFoodBeforeDestroyed
                                                            .name),
                                                  ),
                                                  action: SnackBarAction(
                                                    label: 'Undo',
                                                    onPressed: () async {
                                                      await DatabaseProvider
                                                          .instance
                                                          .updateFood(
                                                              deletedFoodBeforeDestroyed,
                                                              clientDocumentID:
                                                                  client
                                                                      .documentID,
                                                              recovery: true);
                                                      setState(() {
                                                        deletedFoodBeforeDestroyed =
                                                            null;
                                                      });
                                                    },
                                                  ),
                                                ));
                                              } else {
                                                Scaffold.of(context)
                                                    .showSnackBar(SnackBar(
                                                        content:
                                                            SnackbarContent(
                                                  icon: Icons.error,
                                                  title: Messages
                                                      .foodDeleteFailure,
                                                )));
                                                setState(() {
                                                  deletedFoodBeforeDestroyed =
                                                      null;
                                                });
                                              }
                                              break;
                                            case 'Change Meals':
                                              List<bool> newMeals =
                                                  await changeFoodMeals(context,
                                                      meals: <bool>[
                                                    food.breakfast,
                                                    food.lunch,
                                                    food.dinner,
                                                    food.snack
                                                  ]);
                                              if (newMeals != null) {
                                                Food updatedFood = food;

                                                updatedFood.breakfast =
                                                    newMeals[0];
                                                updatedFood.lunch = newMeals[1];
                                                updatedFood.dinner =
                                                    newMeals[2];
                                                updatedFood.snack = newMeals[3];

                                                bool success =
                                                    await DatabaseProvider
                                                        .instance
                                                        .updateFood(updatedFood,
                                                            clientDocumentID:
                                                                client
                                                                    .documentID);

                                                if (!success) {
                                                  Scaffold.of(context)
                                                      .showSnackBar(SnackBar(
                                                          content:
                                                              SnackbarContent(
                                                    icon: Icons.error,
                                                    title: Messages
                                                        .foodUpdateFailure,
                                                  )));
                                                }
                                              }
                                              break;
                                            default:
                                          }
                                        },
                                      ),
                                    ))
                                .toList()),
                      ),
                      Center(
                        child: PopupMenuButton(
                          icon: Icon(Icons.add),
                          itemBuilder: (BuildContext context) {
                            if (foodCategories[index].courseLevel != 3) {
                              return foodAddPopupMenu.map((String choice) {
                                return PopupMenuItem<String>(
                                  value: choice,
                                  child: Text(choice),
                                );
                              }).toList();
                            } else {
                              String menuItem = foodAddPopupMenu.firstWhere(
                                  (element) => element == 'Add Food');
                              return <PopupMenuItem<String>>[
                                PopupMenuItem<String>(
                                  value: menuItem,
                                  child: Text(menuItem),
                                )
                              ];
                            }
                          },
                          onSelected: (String value) async {
                            int newFoodCategory = -1;
                            int newFoodParentCategory = -1;
                            int newFoodCourseLevel = -1;

                            switch (value) {
                              case 'Add Food':
                                newFoodCategory =
                                    foodCategories[index].category;
                                newFoodParentCategory =
                                    foodCategories[index].parentCategory;
                                newFoodCourseLevel =
                                    foodCategories[index].courseLevel;
                                break;
                              case 'Add Food as Child':
                                /* Get a new category index. It is basically the current amount of categories + 1 */
                                newFoodCategory = foodCategories.length + 1;
                                /* Set the new foods parent category to selected category. */
                                newFoodParentCategory =
                                    foodCategories[index].category;
                                /* New foods course level is one level higher. 
                                  Handling the course limit here is not needed,
                                      since this menu option will only exist for the appropriate categories. */
                                newFoodCourseLevel =
                                    foodCategories[index].courseLevel + 1;
                                break;
                              default:
                            }
                            Food newFood = await newFoodDialog(context,
                                category: newFoodCategory,
                                parentCategory: newFoodParentCategory,
                                courseLevel: newFoodCourseLevel);
                            if (newFood != null) {
                              bool success = await DatabaseProvider.instance
                                  .createFood(client.documentID, newFood);

                              if (success) {
                                Scaffold.of(context).showSnackBar(SnackBar(
                                  content: SnackbarContent(
                                    icon: Icons.check,
                                    title: Messages.foodCreateSuccess,
                                  ),
                                ));
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  Future<Food> newFoodDialog(BuildContext context,
      {@required int category,
      @required int parentCategory,
      @required int courseLevel}) async {
    GlobalKey<FormState> foodFormKey = GlobalKey<FormState>();

    TextEditingController foodNameField = TextEditingController();
    TextEditingController dailyLimitField = TextEditingController();
    TextEditingController weeklyLimitField = TextEditingController();
    bool breakfast = false;
    bool lunch = false;
    bool dinner = false;
    bool snack = false;

    return await showDialog<Food>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
              title: Text('Create Food'),
              content: Form(
                key: foodFormKey,
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    TextFormField(
                      controller: foodNameField,
                      decoration: InputDecoration(labelText: 'Name'),
                      validator: (String value) {
                        if (value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: dailyLimitField,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'Daily Limit'),
                      validator: (String value) {
                        if (value.isEmpty) {
                          return 'Required';
                        } else if (!isInt(value)) {
                          return 'Enter an integer';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: weeklyLimitField,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'Weekly Limit'),
                      validator: (String value) {
                        if (value.isEmpty) {
                          return 'Required';
                        } else if (!isInt(value)) {
                          return 'Enter an integer';
                        }
                        return null;
                      },
                    ),
                    CheckboxElement(
                      onChanged: (bool value) {
                        breakfast = value;
                      },
                      title: Text('Breakfast'),
                    ),
                    CheckboxElement(
                      onChanged: (bool value) {
                        lunch = value;
                      },
                      title: Text('Lunch'),
                    ),
                    CheckboxElement(
                      onChanged: (bool value) {
                        dinner = value;
                      },
                      title: Text('Dinner'),
                    ),
                    CheckboxElement(
                      onChanged: (bool value) {
                        snack = value;
                      },
                      title: Text('Snack'),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop<Food>(null),
                ),
                FlatButton(
                  child: Text('Create'),
                  onPressed: () {
                    if (foodFormKey.currentState.validate()) {
                      Navigator.of(context).pop<Food>(Food(
                        name: foodNameField.text,
                        category: category,
                        parentCategory: parentCategory,
                        courseLevel: courseLevel,
                        dailyLimit: int.parse(dailyLimitField.text),
                        weeklyLimit: int.parse(weeklyLimitField.text),
                        breakfast: breakfast,
                        lunch: lunch,
                        dinner: dinner,
                        snack: snack,
                      ));
                    }
                  },
                ),
              ],
            ));
  }

  Future<String> changeFoodNameDialog(BuildContext context) async {
    TextEditingController foodNameField = TextEditingController();
    GlobalKey<FormState> foodFormKey = GlobalKey<FormState>();

    return await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
              title: Text('Enter the new name'),
              content: Form(
                key: foodFormKey,
                child: TextFormField(
                  controller: foodNameField,
                  validator: (String value) {
                    if (value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop<String>(''),
                ),
                FlatButton(
                  child: Text('Create'),
                  onPressed: () {
                    if (foodFormKey.currentState.validate()) {
                      Navigator.of(context).pop<String>(foodNameField.text);
                    }
                  },
                ),
              ],
            ));
  }

  Future<String> changeFoodDailyWeeklyLimitDialog(BuildContext context,
      {@required String title}) async {
    TextEditingController foodLimitField = TextEditingController();
    GlobalKey<FormState> foodFormKey = GlobalKey<FormState>();

    return await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
              title: Text('Enter the new $title Limit'),
              content: Form(
                key: foodFormKey,
                child: TextFormField(
                  controller: foodLimitField,
                  keyboardType: TextInputType.number,
                  validator: (String value) {
                    if (value.isEmpty) {
                      return 'Required';
                    } else if (!isInt(value)) {
                      return 'Enter an integer';
                    }
                    return null;
                  },
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop<String>(''),
                ),
                FlatButton(
                  child: Text('Create'),
                  onPressed: () {
                    if (foodFormKey.currentState.validate()) {
                      Navigator.of(context).pop<String>(foodLimitField.text);
                    }
                  },
                ),
              ],
            ));
  }

  Future<List<bool>> changeFoodMeals(BuildContext context,
      {@required List<bool> meals}) async {
    return await showDialog<List<bool>>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
              title: Text('Change Meals'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  CheckboxElement(
                    value: meals[0],
                    onChanged: (bool value) {
                      meals[0] = value;
                    },
                    title: Text('Breakfast'),
                  ),
                  CheckboxElement(
                    value: meals[1],
                    onChanged: (bool value) {
                      meals[1] = value;
                    },
                    title: Text('Lunch'),
                  ),
                  CheckboxElement(
                    value: meals[2],
                    onChanged: (bool value) {
                      meals[2] = value;
                    },
                    title: Text('Dinner'),
                  ),
                  CheckboxElement(
                    value: meals[3],
                    onChanged: (bool value) {
                      meals[3] = value;
                    },
                    title: Text('Snack'),
                  ),
                ],
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop<List<bool>>(null),
                ),
                FlatButton(
                  child: Text('Create'),
                  onPressed: () => Navigator.of(context).pop<List<bool>>(meals),
                ),
              ],
            ));
  }

  double getFoodIndentation(int courseLevel) {
    switch (courseLevel) {
      case 1:
        return 0.0;
      case 2:
        return 16.0;
      case 3:
        return 32.0;
      default:
        return 0.0;
    }
    // return SizedBox(
    //   width: 32,
    //   child: Center(
    //     child: Text(
    //       courseLevel.toString() + '.',
    //       style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w900),
    //     ),
    //   ),
    // );
  }

  double getFoodCategoryElevation(int courseLevel) {
    switch (courseLevel) {
      case 1:
        return 18.0;
      case 2:
        return 6.0;
      case 3:
        return 2.0;
      default:
        return 0.0;
    }
  }

  Widget getFAB(BuildContext context) {
    return Builder(
        builder: (context) => _tabController.index == 0
            ? FloatingActionButton(
                child: Icon(Icons.add),
                onPressed: isCreatingPlan
                    ? () {}
                    : () async {
                        setState(() {
                          isCreatingPlan = true;
                        });
                        bool success = await DatabaseProvider.instance
                            .createPlanTemplate(client.documentID);

                        if (success) {
                          Scaffold.of(context).showSnackBar(SnackBar(
                              content: SnackbarContent(
                                  icon: Icons.check,
                                  title: Messages.planTemplateCreateSuccess)));
                        } else {
                          Scaffold.of(context).showSnackBar(SnackBar(
                              content: SnackbarContent(
                                  icon: Icons.error,
                                  title: Messages.planTemplateCreateFailure)));
                        }
                        setState(() {
                          isCreatingPlan = false;
                        });
                      },
              )
            : Container());
  }
}
