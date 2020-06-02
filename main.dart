import 'package:diet_app/ui/admin/admin_client_add_view.dart';
import 'package:diet_app/ui/admin/admin_client_options_view.dart';
import 'package:diet_app/ui/admin/admin_client_plan_edit_view.dart';
import 'package:diet_app/ui/admin/admin_options_view.dart';
import 'package:diet_app/ui/admin/admin_client_select_view.dart';
import 'package:diet_app/ui/client/client_login_view.dart';
import 'package:diet_app/ui/home_view.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
  // DatabaseProvider.instance.initialize();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.lime,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: 'HomeView',
      routes: {
        'HomeView': (context) => HomeView(),
        'ClientLogin': (context) => ClientLoginView(),
        'AdminOptions': (context) => AdminOptionsView(),
        'AdminClientSelect': (context) => AdminClientSelectView(),
        'AdminClientAdd': (context) => AdminClientAddView(),
        'AdminClientOptions': (context) => AdminClientOptionsView(),
        'AdminClientPlanEdit': (context) => AdminClientPlanEditView(),
      },
    );
  }

  static double getFoodIndentation(int courseLevel) {
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
  }

  static double getFoodCategoryElevation(int courseLevel) {
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
}
