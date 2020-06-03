import 'package:diet_app/messages.dart';
import 'package:diet_app/models/client_model.dart';
import 'package:diet_app/models/plan_model.dart';
import 'package:diet_app/providers/database_provider.dart';
import 'package:diet_app/ui/widgets/snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:string_validator/string_validator.dart';

class ClientLoginView extends StatefulWidget {
  ClientLoginView({Key key}) : super(key: key);

  @override
  _ClientLoginViewState createState() => _ClientLoginViewState();
}

class _ClientLoginViewState extends State<ClientLoginView> {
  TextEditingController _clientIdField = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isGeneratingPlan = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Client Program'),
      ),
      body: Builder(
        builder: (context) => Padding(
          padding: const EdgeInsets.all(12.0),
          child: isGeneratingPlan ? Center(child: CircularProgressIndicator()) : Column(
            children: <Widget>[
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _clientIdField,
                  keyboardType: TextInputType.number,
                  decoration:
                      InputDecoration(labelText: 'Client ID Number'),
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
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: MaterialButton(
                      child: Text('Produce Plan'),
                      color: Theme.of(context).primaryColor,
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          setState(() {
                            isGeneratingPlan = true;
                          });
                          Client client = await DatabaseProvider.instance
                              .getClient(int.parse(_clientIdField.text));

                          if (client != null) {
                            String error = await DatabaseProvider.instance
                                .generatePlan(client.documentID);
                            if (error.isNotEmpty) {
                              Scaffold.of(context).showSnackBar(SnackBar(
                                content: SnackbarContent(
                                  icon: Icons.error,
                                  title: error,
                                ),
                              ));
                            } else {
                              Scaffold.of(context).showSnackBar(SnackBar(
                                content: SnackbarContent(
                                  icon: Icons.check,
                                  title: Messages.planGenerationSuccess,
                                ),
                              ));
                            }
                          } else {
                            Scaffold.of(context).showSnackBar(SnackBar(
                              content: SnackbarContent(
                                icon: Icons.error,
                                title: Messages.clientNotExists,
                              ),
                            ));
                          }

                          setState(() {
                            isGeneratingPlan = false;
                          });
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: MaterialButton(
                      child: Text('Load Plan'),
                      color: Theme.of(context).primaryColor,
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          Client client = await DatabaseProvider.instance
                              .getClient(int.parse(_clientIdField.text));

                          if (client != null) {
                            await DatabaseProvider.instance
                                .loadFoods(client.documentID); // Temporary
                            Plan plan = await DatabaseProvider.instance
                                .readPlanLocally();
                            if (plan != null) {
                              Navigator.of(context)
                                  .pushNamed('ClientPlan', arguments: plan);
                            } else {
                              Plan plan = await DatabaseProvider.instance
                                  .getPlanOfClient(client.documentID);
                              if (plan != null) {
                                bool success = await DatabaseProvider
                                    .instance
                                    .savePlanLocally(plan);
                                if (success) {
                                  Navigator.of(context).pushNamed(
                                      'ClientPlan',
                                      arguments: plan);
                                } else {
                                  Scaffold.of(context)
                                      .showSnackBar(SnackBar(
                                    content: SnackbarContent(
                                      icon: Icons.error,
                                      title: Messages.foodsLoadFailure,
                                    ),
                                  ));
                                }
                              } else {
                                Scaffold.of(context).showSnackBar(SnackBar(
                                  content: SnackbarContent(
                                    icon: Icons.error,
                                    title: Messages.foodsLoadFailure,
                                  ),
                                ));
                              }
                            }
                          } else {
                            Scaffold.of(context).showSnackBar(SnackBar(
                              content: SnackbarContent(
                                icon: Icons.error,
                                title: Messages.clientNotExists,
                              ),
                            ));
                          }
                        }
                      },
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
