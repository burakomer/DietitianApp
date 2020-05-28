import 'package:flutter/material.dart';

class ClientLoginView extends StatefulWidget {
  ClientLoginView({Key key}) : super(key: key);

  @override
  _ClientLoginViewState createState() => _ClientLoginViewState();
}

class _ClientLoginViewState extends State<ClientLoginView> {
  TextEditingController clientIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Client Program'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: clientIdController,
              decoration: InputDecoration(hintText: 'Client ID Number'),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: MaterialButton(
                    child: Text('Produce Plan'),
                    color: Theme.of(context).primaryColor,
                    onPressed:
                        () {}, // Produce meal plan, save it to the database.
                  ),
                ),
                SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: MaterialButton(
                    child: Text('Load Plan'),
                    color: Theme.of(context).primaryColor,
                    onPressed:
                        () {}, // Check the database for existing plan. Retrieve it if exists.
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
