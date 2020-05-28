import 'package:diet_app/messages.dart';
import 'package:diet_app/models/client_model.dart';
import 'package:diet_app/models/food_model.dart';
import 'package:diet_app/models/plan_template.dart';
import 'package:diet_app/providers/database_provider.dart';
import 'package:diet_app/ui/widgets/snackbar_content.dart';
import 'package:flutter/material.dart';

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

  final foodPopupMenu = {'Move', 'Delete'};

  Client client;
  PlanTemplate assignedPlan;
  int assignedPlanIndex;
  bool isFirstLoad = true;
  bool isCreatingPlan = false;
  bool isLoadingFoods = false;

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
                  default:
                }
              },
              itemBuilder: (BuildContext context) {
                return <String>['Initialize'].map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            );
          }),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: <Widget>[
            Tab(
              icon: Icon(Icons.assignment),
              text: 'Plans',
            ),
            Tab(
              icon: Icon(Icons.fastfood),
              text: 'Foods',
            ),
          ],
        ),
      ),
      floatingActionButton: getFAB(context),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          getPlansTabView(context),
          FutureBuilder<Widget>(
            future: getFoodsTabView(context),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              } else {
                return snapshot.data;
              }
            },
          ),
        ],
      ),
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
                                      title: deletedPlanBeforeDestroyed.name +
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

  Future<Widget> getFoodsTabView(BuildContext context) async {
    if (isFirstLoad) {
      bool success = await DatabaseProvider.instance
          .loadFoodCategoryCount(client.documentID);

      if (!success) {
        return Center(
          child: Text(Messages.clientFoodCategoryLoadFailure),
        );
      }
    }

    return StreamBuilder(
      stream: DatabaseProvider.instance.foodsOfClientStream(client.documentID),
      builder: (BuildContext context, AsyncSnapshot<List<Food>> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        } else {
          /* Before building the list, create a new list that groups foods according to their categories. */
          List<List<Food>> foodCategories =
              new List<List<Food>>(DatabaseProvider.instance.foodCategoryCount);

          for (var i = 0;
              i < DatabaseProvider.instance.foodCategoryCount;
              i++) {
            foodCategories[i] =
                snapshot.data.where((Food food) => food.category == i).toList();
          }

          /* Then, sort them according to their category and parent category. (Childs come after the parent.) */
          foodCategories.sort((a, b) => a[0].compareRelationship(b[0]));

          return ListView.builder(
            itemCount: foodCategories.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Flexible(
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: foodCategories[index]
                              .map((Food food) => ListTile(
                                    /* Indentation depending on the course level. */
                                    leading: getFoodIndentation(
                                        foodCategories[index][0].courseLevel),
                                    title: Text(food.name),
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
                                          case 'Move':
                                            // TODO: Update the foods category and parent category.
                                            break;
                                          case 'Delete':
                                            // TODO: Delete the food. Very easy.
                                            break;
                                          default:
                                        }
                                      },
                                    ),
                                  ))
                              .toList()),
                    ),
                    Center(
                        child: IconButton(
                      icon: Icon(Icons.add),
                      onPressed:
                          () {}, // TODO: Add to food category => foodCategories[index][0].category (Show dialog box)
                    ))
                  ],
                ),
              );
            },
          );
        }
      },
    );
  }

  Widget getFoodIndentation(int courseLevel) {
    // switch (courseLevel) {
    //   case 1:
    //     return null;
    //   case 2:
    //     return SizedBox();
    //   case 3:
    //     return SizedBox(width: 54,);
    //   default:
    //     return null;
    // }
    return SizedBox(
      width: 32,
      child: Center(
        child: Text(
          courseLevel.toString() + '.',
          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }

  Widget getFAB(BuildContext context) {
    return Builder(
        builder: (context) => _tabController.index == 0
            ? FloatingActionButton.extended(
                label: Row(
                  children: <Widget>[Icon(Icons.add), Text('Create Plan')],
                ),
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
