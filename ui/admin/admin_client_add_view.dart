import 'package:diet_app/models/client_model.dart';
import 'package:diet_app/providers/database_provider.dart';
import 'package:flutter/material.dart';
import 'package:string_validator/string_validator.dart';

class AdminClientAddView extends StatefulWidget {
  AdminClientAddView({Key key}) : super(key: key);

  @override
  _AdminClientAddViewState createState() => _AdminClientAddViewState();
}

class _AdminClientAddViewState extends State<AdminClientAddView> {
  bool isBusy = false;

  TextEditingController _clientNameForm = TextEditingController();
  TextEditingController _clientSurnameForm = TextEditingController();
  TextEditingController _clientIDForm = TextEditingController();

  GlobalKey<FormState> _clientFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Client'),
      ),
      body: getBody(context),
      floatingActionButton: Builder(
        builder: (context) => FloatingActionButton.extended(
          icon: Icon(Icons.person_add),
          label: Text('Create'),
          onPressed: () async {
            if (_clientFormKey.currentState.validate()) {
              setState(() {
                isBusy = true;
              });

              bool success = await DatabaseProvider.instance.createClient(
                  Client(
                      name: _clientNameForm.text,
                      surname: _clientSurnameForm.text,
                      id: int.parse(_clientIDForm.text)));
              if (success) {
                Scaffold.of(context).showSnackBar(SnackBar(
                    content: Row(
                  children: <Widget>[
                    Icon(Icons.check),
                    SizedBox(
                      width: 8.0,
                    ),
                    Text('Successfully added client'),
                  ],
                )));
              } else {
                Scaffold.of(context).showSnackBar(SnackBar(
                    content: Row(
                  children: <Widget>[
                    Icon(Icons.error),
                    SizedBox(
                      width: 8.0,
                    ),
                    Text('Error adding client'),
                  ],
                )));
              }

              setState(() {
                isBusy = false;
              });
            }
          },
        ),
      ),
    );
  }

  Widget getBody(BuildContext context) {
    return isBusy
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Container(
            padding: EdgeInsets.all(12.0),
            child: Form(
              key: _clientFormKey,
              child: Container(
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: _clientNameForm,
                      decoration: InputDecoration(labelText: 'Name'),
                      validator: (String value) {
                        if (value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _clientSurnameForm,
                      decoration: InputDecoration(labelText: 'Surname'),
                      validator: (String value) {
                        if (value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _clientIDForm,
                      decoration: InputDecoration(labelText: 'ID'),
                      keyboardType: TextInputType.number,
                      validator: (String value) {
                        if (value.isEmpty) {
                          return 'Required';
                        } else if (!isInt(value) ||
                            value.length < 11 ||
                            value.length > 11) {
                          return 'Enter a valid TC ID';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
