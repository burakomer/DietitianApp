import 'package:diet_app/messages.dart';
import 'package:diet_app/models/client_model.dart';
import 'package:diet_app/providers/database_provider.dart';
import 'package:diet_app/ui/widgets/snackbar_content.dart';
import 'package:flutter/material.dart';

class AdminClientSelectView extends StatefulWidget {
  AdminClientSelectView({Key key}) : super(key: key);

  @override
  _AdminClientSelectViewState createState() => _AdminClientSelectViewState();
}

class _AdminClientSelectViewState extends State<AdminClientSelectView> {
  bool searching = false;

  TextEditingController _clientSearchField = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: !searching
            ? Text('Select Client to Edit')
            : TextField(
                controller: _clientSearchField,
                decoration: InputDecoration(
                    hintText: 'Search',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => _clientSearchField.clear(),
                    )),
                onChanged: (String value) {
                  // Search
                },
              ),
        actions: <Widget>[
          IconButton(
            icon: !searching ? Icon(Icons.search) : Icon(Icons.close),
            onPressed: () {
              setState(() {
                searching = !searching;
              });
            },
          )
        ],
      ),
      body: getBody(context),
    );
  }

  Widget getBody(BuildContext context) {
    return StreamBuilder<List<Client>>(
      stream: DatabaseProvider.instance.clientStream(),
      builder: (BuildContext context, AsyncSnapshot<List<Client>> snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        } else {
          return ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                leading: Icon(Icons.person),
                title: Text(snapshot.data[index].fullName),
                subtitle: Text('TC ID: ' + snapshot.data[index].id.toString()),
                onTap: () async {
                  bool success = await DatabaseProvider.instance
                      .loadFoods(snapshot.data[index].documentID);
                  if (success) {
                    Navigator.of(context).pushNamed('AdminClientOptions',
                        arguments: snapshot.data[index]);
                  } else {
                    Scaffold.of(context).showSnackBar(SnackBar(
                      content: SnackbarContent(
                          icon: Icons.error, title: Messages.foodsLoadFailure),
                    ));
                  }
                },
              );
            },
          );
        }
      },
    );
  }
}
