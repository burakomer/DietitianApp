import 'package:diet_app/enums/meals_enum.dart';
import 'package:diet_app/main.dart';
import 'package:diet_app/messages.dart';
import 'package:diet_app/models/food_category_model.dart';
import 'package:diet_app/models/food_model.dart';
import 'package:diet_app/models/plan_template_model.dart';
import 'package:diet_app/providers/database_provider.dart';
import 'package:diet_app/ui/widgets/snackbar_content.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AdminClientPlanEditView extends StatefulWidget {
  AdminClientPlanEditView({Key key}) : super(key: key);

  @override
  _AdminClientPlanEditViewState createState() =>
      _AdminClientPlanEditViewState();
}

class _AdminClientPlanEditViewState extends State<AdminClientPlanEditView>
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

  Color themePrimaryColor;
  final bool getLive = true;

  PlanTemplate planTemplate;

  bool isUploading = false;
  Meal selectedMeal = Meal.Breakfast;

  Food selectedFood1;
  Food selectedFood2;
  Food selectedFood3;

  List<Food> course1 = List<Food>();
  List<Food> course2 = List<Food>();
  List<Food> course3 = List<Food>();

  List<String> categories = <String>[
    'Köfte yemekleri',
    'Zeytinyağlı yemekler, sarmalar',
  ];

  TextEditingController _planNameField = TextEditingController();

  final menu = {'Upload Plan'};

  @override
  Widget build(BuildContext context) {
    themePrimaryColor = Theme.of(context).primaryColor;

    planTemplate = ModalRoute.of(context).settings.arguments;
    _planNameField.text = planTemplate.name;

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Plan'),
        actions: getAppBarActions(context),
        bottom: getAppBarBottom(context),
      ),
      body: Container(
        child: TabBarView(
          controller: _tabController,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(12.0),
              child: ListView(
                children: getAddToPlanTabView(),
              ),
            ),
            getViewPlanTabView(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add_box),
        onPressed: () {
          setState(() {
            planTemplate.add(
                meal: selectedMeal,
                firstCourse: course1,
                secondCourse: course2,
                thirdCourse: course3);
          });
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: TabBar(
          controller: _tabController,
          tabs: <Widget>[
            Tab(
              iconMargin: EdgeInsets.all(1),
              icon: Icon(Icons.assignment_returned),
              text: 'Add to Plan',
            ),
            Tab(
              iconMargin: EdgeInsets.all(1),
              icon: Icon(Icons.assignment),
              text: 'View Plan',
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> getAppBarActions(BuildContext context) {
    return <Widget>[
      Builder(
          builder: (context) => PopupMenuButton<String>(
                onSelected: (String value) async {
                  switch (value) {
                    case 'Upload Plan':
                      bool success = await DatabaseProvider.instance
                          .updatePlanTemplate(planTemplate);

                      if (success) {
                        Scaffold.of(context).showSnackBar(SnackBar(
                          content: SnackbarContent(
                              icon: Icons.check,
                              title: Messages.planTemplateUploadSuccess),
                        ));
                      } else {
                        Scaffold.of(context).showSnackBar(SnackBar(
                          content: SnackbarContent(
                              icon: Icons.check,
                              title: Messages.planTemplateUploadFailure),
                        ));
                      }
                      break;
                    default:
                  }
                },
                itemBuilder: (BuildContext context) {
                  return menu.map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(choice),
                    );
                  }).toList();
                },
              )),
    ];
  }

  PreferredSize getAppBarBottom(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(48.0),
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(left: 12.0, right: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              child: TextField(
                controller: _planNameField,
                style: TextStyle(fontSize: 17.0),
                decoration: InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    hintText: 'Enter Plan Name',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.save),
                      onPressed: () =>
                          planTemplate.changeName(_planNameField.text),
                    )),
              ),
            ),
            Flexible(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Meal>(
                  value: selectedMeal,
                  onChanged: (Meal value) {
                    setState(() {
                      selectedMeal = value;

                      selectedFood1 = null;
                      selectedFood2 = null;
                      selectedFood3 = null;

                      course1 = planTemplate.planMap[selectedMeal][0].toList();

                      if (planTemplate.planMap[selectedMeal].length > 1) {
                        course2 =
                            planTemplate.planMap[selectedMeal][1].toList();
                        course3 =
                            planTemplate.planMap[selectedMeal][2].toList();
                      } else {
                        course2.clear();
                        course3.clear();
                      }
                    });
                  },
                  selectedItemBuilder: (BuildContext context) {
                    return Meal.values.map((Meal meal) {
                      return Center(
                        child: Text(describeEnum(meal),
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      );
                    }).toList();
                  },
                  items: Meal.values
                      .map((Meal meal) => DropdownMenuItem<Meal>(
                            value: meal,
                            child: Text(describeEnum(meal)),
                          ))
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getViewPlanTabView() {
    /* Before building the list UI, create a new list that groups foods according to their categories. */
    List<Food> mealFoods = List<Food>();
    List<FoodCategory> foodCategories = new List<FoodCategory>();

    /* First, sort the list accourding to category indexes, so that the next process works correctly. */
    planTemplate.planMap[selectedMeal]
        .forEach((List<Food> course) => mealFoods.addAll(course));

    mealFoods.sort((a, b) => a.category.compareTo(b.category));

    mealFoods.forEach((Food food) {
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

    return ListView.builder(
      itemCount: foodCategories.length,
      itemBuilder: (BuildContext context, int index) {
        return Container(
          padding: EdgeInsets.fromLTRB(
              4 +
                  MyApp.getFoodIndentation(
                      foodCategories[index].foods[0].courseLevel),
              2,
              4,
              2),
          child: Card(
            elevation: MyApp.getFoodCategoryElevation(
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
                            title: Text(foodCategories[index]
                                    .foods[0]
                                    .courseLevel
                                    .toString() +
                                '. ' +
                                food.name),
                            subtitle: Text(
                                'DLimit: ${food.dailyLimit} | WLimit: ${food.weeklyLimit}' +
                                    '\n${food.breakfast ? 'Breakfast' : ''}' +
                                    '${(food.breakfast && (food.lunch || food.dinner || food.snack)) ? ' ' : ''}' +
                                    '${food.lunch ? 'Lunch' : ''}' +
                                    '${(food.lunch && (food.dinner || food.snack)) ? ' ' : ''}' +
                                    '${food.dinner ? 'Dinner' : ''}' +
                                    '${(food.dinner && food.snack) ? ' ' : ''}' +
                                    '${food.snack ? 'Snack' : ''}'),
                            isThreeLine: true,
                          ))
                      .toList(),
                ))
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> getAddToPlanTabView() {
    List<Widget> body = List<Widget>();

    List<Widget> course1Body;
    List<Widget> course2Body;
    List<Widget> course3Body;

    course1Body = getCourse(context,
        foodList: DatabaseProvider.instance.readFoodsLocal(1, 0, selectedMeal),
        courseNumber: '1st',
        selectedFood: selectedFood1,
        courseList: course1, onSelectedCourseChanged: (value) {
      setState(() {
        if (selectedFood2 != null) {
          if (selectedFood2.parentCategory != value.category) {
            selectedFood2 = null;
          }
        }
        selectedFood1 = value;
      });
    }, onCourseAdded: () {
      setState(() {
        if (!course1.contains(selectedFood1)) {
          course1.add(selectedFood1);
        }
      });
    }, onCourseRemoved: (int index) {
      setState(() {
        course1.removeAt(index);
      });
    });

    if (selectedFood1 != null &&
        (selectedMeal != Meal.Snack1 ||
            selectedMeal != Meal.Snack2 ||
            selectedMeal != Meal.Snack3)) {
      course2Body = getCourse(context,
          foodList: DatabaseProvider.instance
              .readFoodsLocal(2, selectedFood1.category, selectedMeal),
          courseNumber: '2nd',
          selectedFood: selectedFood2,
          courseList: course2, onSelectedCourseChanged: (value) {
        setState(() {
          if (selectedFood3 != null) {
            if (selectedFood3.parentCategory != value.category) {
              selectedFood3 = null;
            }
          }
          selectedFood2 = value;
        });
      }, onCourseAdded: () {
        setState(() {
          if (!course2.contains(selectedFood2)) {
            course2.add(selectedFood2);
          }
        });
      }, onCourseRemoved: (int index) {
        setState(() {
          course2.removeAt(index);
        });
      });
    }

    if (selectedFood2 != null &&
        (selectedMeal != Meal.Snack1 ||
            selectedMeal != Meal.Snack2 ||
            selectedMeal != Meal.Snack3)) {
      course3Body = getCourse(context,
          foodList: DatabaseProvider.instance
              .readFoodsLocal(3, selectedFood2.category, selectedMeal),
          selectedFood: selectedFood3,
          courseNumber: '3rd',
          courseList: course3, onSelectedCourseChanged: (value) {
        setState(() {
          selectedFood3 = value;
        });
      }, onCourseAdded: () {
        setState(() {
          if (!course3.contains(selectedFood3)) {
            course3.add(selectedFood3);
          }
        });
      }, onCourseRemoved: (int index) {
        setState(() {
          course3.removeAt(index);
        });
      });
    }

    if (course1Body != null) body.addAll(course1Body);
    if (course2Body != null) body.add(const SizedBox(height: 12.0));
    if (course2Body != null) body.addAll(course2Body);
    if (course3Body != null) body.add(const SizedBox(height: 12.0));
    if (course3Body != null) body.addAll(course3Body);
    body.add(const SizedBox(height: 12.0));

    return body;
  }

  // Future<List<Widget>> getBodyLive(BuildContext context) async {
  //   List<Widget> body = List<Widget>();

  //   List<Widget> course1Body;
  //   List<Widget> course2Body;
  //   List<Widget> course3Body;

  //   course1Body = getCourse(context,
  //       foodList:
  //           await DatabaseProvider.instance.getFoodsLive(1, 0, selectedMeal),
  //       courseNumber: '1st',
  //       selectedFood: selectedFood1,
  //       courseList: course1, onSelectedCourseChanged: (value) {
  //     setState(() {
  //       if (selectedFood2 != null) {
  //         if (!selectedFood2.parentCategories.contains(value.category)) {
  //           selectedFood2 = null;
  //         }
  //       }
  //       selectedFood1 = value;
  //     });
  //   }, onCourseAdded: () {
  //     setState(() {
  //       if (!course1.contains(selectedFood1)) {
  //         course1.add(selectedFood1);
  //       }
  //     });
  //   }, onCourseRemoved: (int index) {
  //     setState(() {
  //       course1.removeAt(index);
  //     });
  //   });

  //   if (selectedFood1 != null) {
  //     course2Body = getCourse(context,
  //         foodList: await DatabaseProvider.instance
  //             .getFoodsLive(2, selectedFood1.category, selectedMeal),
  //         courseNumber: '2nd',
  //         selectedFood: selectedFood2,
  //         courseList: course2, onSelectedCourseChanged: (value) {
  //       setState(() {
  //         if (selectedFood3 != null) {
  //           if (!selectedFood3.parentCategories.contains(value.category)) {
  //             selectedFood3 = null;
  //           }
  //         }
  //         selectedFood2 = value;
  //       });
  //     }, onCourseAdded: () {
  //       setState(() {
  //         if (!course2.contains(selectedFood2)) {
  //           course2.add(selectedFood2);
  //         }
  //       });
  //     }, onCourseRemoved: (int index) {
  //       setState(() {
  //         course2.removeAt(index);
  //       });
  //     });
  //   }

  //   if (selectedFood2 != null) {
  //     course3Body = getCourse(context,
  //         foodList: await DatabaseProvider.instance
  //             .getFoodsLive(3, selectedFood2.category, selectedMeal),
  //         selectedFood: selectedFood3,
  //         courseNumber: '3rd',
  //         courseList: course3, onSelectedCourseChanged: (value) {
  //       setState(() {
  //         selectedFood3 = value;
  //       });
  //     }, onCourseAdded: () {
  //       setState(() {
  //         if (!course3.contains(selectedFood3)) {
  //           course3.add(selectedFood3);
  //         }
  //       });
  //     }, onCourseRemoved: (int index) {
  //       setState(() {
  //         course3.removeAt(index);
  //       });
  //     });
  //   }

  //   if (course1Body != null) body.addAll(course1Body);
  //   if (course2Body != null) body.add(const SizedBox(height: 12.0));
  //   if (course2Body != null) body.addAll(course2Body);
  //   if (course3Body != null) body.add(const SizedBox(height: 12.0));
  //   if (course3Body != null) body.addAll(course3Body);
  //   body.add(const SizedBox(height: 12.0));
  //   body.add(MaterialButton(
  //     color: themePrimaryColor,
  //     child: Text('Add Selections To Plan'),
  //     onPressed: () {},
  //   ));

  //   return body;
  // }

  List<Widget> getCourse(
    BuildContext context, {
    @required String courseNumber,
    @required Food selectedFood,
    @required List<Food> courseList,
    @required List<Food> foodList,
    @required Function(Food value) onSelectedCourseChanged,
    @required Function onCourseAdded,
    @required Function onCourseRemoved,
  }) {
    return <Widget>[
      Row(
        children: <Widget>[
          Text(courseNumber + ' Course:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(
            width: 5.0,
          ),
          Flexible(
            child: DropdownButtonHideUnderline(
              child: ButtonTheme(
                alignedDropdown: true,
                child: DropdownButton<Food>(
                  isExpanded: true,
                  //icon: Icon(Icons.fastfood),
                  value: selectedFood,
                  onChanged: onSelectedCourseChanged,
                  selectedItemBuilder: (BuildContext context) {
                    return foodList.map<Widget>((Food food) {
                      return Center(child: Text(food.name));
                    }).toList();
                  },
                  items: foodList.map(((Food food) {
                    return DropdownMenuItem<Food>(
                      value: food,
                      child: Text(
                          '[' + food.category.toString() + '] ' + food.name),
                    );
                  })).toList(),
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: selectedFood == null ? null : onCourseAdded,
          ),
        ],
      ),
      Container(
        height: 128.0,
        decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
        child: ListView.builder(
          itemCount: courseList.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text('[' +
                  courseList[index].category.toString() +
                  '] ' +
                  courseList[index].name),
              trailing: IconButton(
                icon: Icon(Icons.close),
                onPressed: () => onCourseRemoved(index),
              ),
            );
          },
        ),
      ),
    ];
  }

  List<Widget> getSecondColumn(BuildContext context) {
    return <Widget>[];
  }
}
