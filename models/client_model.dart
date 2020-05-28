import 'package:flutter/foundation.dart';

class Client {
  String documentID;
  final String name;
  final String surname;
  final int id;

  String get fullName => name + ' ' + surname;

  Client({
    @required this.name,
    @required this.surname,
    @required this.id,
    this.documentID,
  });

  Client.fromMap(Map<String, dynamic> map, {@required String documentID})
      : this.name = map['name'],
        this.surname = map['surname'],
        this.id = map['id'] {
    this.documentID = documentID;
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'surname': surname, 'id': id};
  }
}
