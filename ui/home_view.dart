// import 'package:diet_app/providers/database_provider.dart';
import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // floatingActionButton: FloatingActionButton(
      //     onPressed: () => DatabaseProvider.instance.addFoods()),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FlatButton(
              child: Text('Dietitian Program'),
              onPressed: () => Navigator.of(context).pushNamed('AdminOptions'),
            ),
            FlatButton(
              child: Text('Client Program'),
              onPressed: () => Navigator.of(context).pushNamed('ClientLogin'),
            )
          ],
        ),
      ),
    );
  }
}
