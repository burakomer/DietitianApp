import 'package:diet_app/enums/days_enum.dart';
import 'package:diet_app/enums/meals_enum.dart';
import 'package:diet_app/models/food_model.dart';
import 'package:diet_app/models/plan_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ClientPlanView extends StatefulWidget {
  ClientPlanView({Key key}) : super(key: key);

  @override
  _ClientPlanViewState createState() => _ClientPlanViewState();
}

class _ClientPlanViewState extends State<ClientPlanView> {
  Plan plan;

  @override
  Widget build(BuildContext context) {
    plan = ModalRoute.of(context).settings.arguments;

    return DefaultTabController(
      length: Day.values.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Plan'),
          bottom: TabBar(
            isScrollable: true,
            tabs: Day.values
                .map<Widget>((Day day) => Tab(text: describeEnum(day)))
                .toList(),
          ),
        ),
        body: Container(
          padding: EdgeInsets.all(12.0),
          child: TabBarView(
            children: Day.values
                .map<Widget>((Day day) => getDayView(context, day))
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget getDayView(BuildContext context, Day day) {
    return ListView.builder(
        itemCount: Meal.values.length,
        itemBuilder: (context, mealIndex) {
          var mealCourses = plan.planMap[day][Meal.values[mealIndex]];
          return Card(
            child: Column(
              children: getCourses(Meal.values[mealIndex], mealCourses),
            ),
          );
        });
  }

  List<Widget> getCourses(Meal meal, List<Food> mealCourses) {
    List<Widget> children = List<Widget>();
    children.add(Container(
      color: Colors.orangeAccent,
      child: ListTile(
        title: Text(
          describeEnum(meal),
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
    ));
    children.addAll(mealCourses
        .map<Widget>((Food food) => ListTile(
              title: Text(food.name),
            ))
        .toList());
    return children;
  }
}
