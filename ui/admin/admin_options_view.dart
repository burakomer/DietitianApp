import 'package:flutter/material.dart';

class AdminOptionsView extends StatelessWidget {
  AdminOptionsView({Key key}) : super(key: key);

  final menu = {'Download Foods'};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dietitian Program'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: MaterialButton(
                    color: Theme.of(context).primaryColor,
                    child: Text('Add New Client'),
                    onPressed: () =>
                        Navigator.of(context).pushNamed('AdminClientAdd'),
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: MaterialButton(
                    color: Theme.of(context).primaryColor,
                    child: Text('Edit Existing Client'),
                    onPressed: () =>
                        Navigator.of(context).pushNamed('AdminClientSelect'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
