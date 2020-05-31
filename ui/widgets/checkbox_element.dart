import 'package:flutter/material.dart';

class CheckboxElement extends StatefulWidget {
  final bool value;
  final Function(bool) onChanged;
  final Widget title;

  CheckboxElement({Key key, this.value: false, this.onChanged, this.title})
      : super(key: key);

  @override
  _CheckboxElementState createState() => _CheckboxElementState(value);
}

class _CheckboxElementState extends State<CheckboxElement> {
  bool value;

  _CheckboxElementState(this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Checkbox(
          value: value,
          onChanged: (bool value) {
            widget.onChanged(value);
            setState(() {
              this.value = value;
            });
          },
        ),
        widget.title,
      ],
    );
  }
}
