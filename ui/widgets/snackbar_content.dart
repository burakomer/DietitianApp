import 'package:flutter/material.dart';

class SnackbarContent extends StatelessWidget {
  final IconData icon;
  final String title;

  const SnackbarContent({Key key, @required this.icon, @required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
                          children: <Widget>[
                            Icon(icon),
                            SizedBox(
                              width: 8.0,
                            ),
                            Text(title)
                          ],
                        ),
    );
  }
}