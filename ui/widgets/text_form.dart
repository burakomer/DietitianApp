import 'package:flutter/material.dart';

class TextForm extends StatelessWidget {
  final String title;
  final TextEditingController controller;

  final TextInputType keyboardType;
  final Function(String) validator;
  final bool enabled;
  final String enabledHintText;
  final String disabledHintText;
  final Function() onTap;
  final bool fillOnTap;
  final Widget trailing;

  TextForm(
      {Key key,
      @required this.title,
      @required this.controller,
      this.keyboardType: TextInputType.text,
      this.validator,
      this.enabled: true,
      this.enabledHintText: '',
      this.disabledHintText: '',
      this.onTap,
      this.fillOnTap: true,
      this.trailing: const SizedBox()})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 5.0, 12.0, 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(title + ': '),
          Flexible(
            child: TextFormField(
              validator: validator,
              keyboardType: keyboardType,
              enabled: enabled,
              controller: controller,
              onTap: () {
                controller.text = (enabled && fillOnTap) ? enabledHintText : '';
                if (onTap != null) onTap();
              },
              decoration: InputDecoration(
                  hintText: enabled ? enabledHintText : disabledHintText),
            ),
          ),
          trailing
        ],
      ),
    );
  }
}
