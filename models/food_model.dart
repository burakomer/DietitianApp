import 'package:flutter/foundation.dart';

class Food {
  String documentID;

  String name;
  int courseLevel;
  int category;
  int parentCategory;

  bool snack;
  bool breakfast;
  bool lunch;
  bool dinner;

  Food(
      {@required this.name,
      @required this.courseLevel,
      @required this.category,
      @required this.parentCategory,
      this.snack: false,
      this.breakfast: false,
      this.lunch: false,
      this.dinner: false});

  Food.fromMap(Map<String, dynamic> map, {@required documentID})
      : this.name = map['name'],
        this.courseLevel = map['courseLevel'],
        this.category = map['category'],
        this.parentCategory = map['parentCategory'],
        this.snack = map['snack'],
        this.breakfast = map['breakfast'],
        this.lunch = map['lunch'],
        this.dinner = map['dinner'],
        this.documentID = documentID;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'courseLevel': courseLevel,
      'category': category,
      'parentCategory': parentCategory,
      'snack': snack,
      'breakfast': breakfast,
      'lunch': lunch,
      'dinner': dinner,
    };
  }

  

  bool operator ==(dynamic other) =>
      other != null && other is Food && this.name == other.name;

  @override
  int get hashCode => super.hashCode;

  static final String foodList = '''{
    "foods": [
        {
            "name": "Köfteler",
            "courseLevel": 1,
            "category": 1,
            "parentCategory": 0,
            "snack": false,
            "breakfast": false,
            "lunch": true,
            "dinner": true
        },
        {
            "name": "Et Yemekleri",
            "courseLevel": 1,
            "category": 1,
            "parentCategory": 0,
            "snack": false,
            "breakfast": false,
            "lunch": true,
            "dinner": true
        },
        {
            "name": "Tavuk Yemekleri",
            "courseLevel": 1,
            "category": 1,
            "parentCategory": 0,
            "snack": false,
            "breakfast": false,
            "lunch": true,
            "dinner": true
        },
        {
            "name": "Kuru Baklagiller",
            "courseLevel": 1,
            "category": 1,
            "parentCategory": 0,
            "snack": false,
            "breakfast": false,
            "lunch": true,
            "dinner": true
        },
        {
            "name": "Zeytinyağlı Sebzeler",
            "courseLevel": 2,
            "category": 2,
            "parentCategory": 1,
            "snack": false,
            "breakfast": false,
            "lunch": true,
            "dinner": true
        },
        {
            "name": "Çiğ Sebzeler",
            "courseLevel": 2,
            "category": 2,
            "parentCategory": 1,
            "snack": false,
            "breakfast": false,
            "lunch": true,
            "dinner": true
        },
        {
            "name": "Sebze Salataları",
            "courseLevel": 2,
            "category": 2,
            "parentCategory": 1,
            "snack": false,
            "breakfast": false,
            "lunch": true,
            "dinner": true
        },
        {
            "name": "Ekmek",
            "courseLevel": 3,
            "category": 3,
            "parentCategory": 2,
            "snack": false,
            "breakfast": false,
            "lunch": true,
            "dinner": true
        },
        {
            "name": "Sütlü Tatlılar",
            "courseLevel": 3,
            "category": 4,
            "parentCategory": 2,
            "snack": false,
            "breakfast": false,
            "lunch": true,
            "dinner": true
        },
        {
            "name": "Sütsüz Tatlılar",
            "courseLevel": 3,
            "category": 4,
            "parentCategory": 2,
            "snack": false,
            "breakfast": false,
            "lunch": true,
            "dinner": true
        },
        {
            "name": "Pastalar",
            "courseLevel": 3,
            "category": 4,
            "parentCategory": 2,
            "snack": false,
            "breakfast": false,
            "lunch": true,
            "dinner": true
        },
        {
            "name": "Hamurişi Tatlılar",
            "courseLevel": 3,
            "category": 4,
            "parentCategory": 2,
            "snack": false,
            "breakfast": false,
            "lunch": true,
            "dinner": true
        },
        {
            "name": "Makarna",
            "courseLevel": 2,
            "category": 5,
            "parentCategory": 1,
            "snack": false,
            "breakfast": false,
            "lunch": true,
            "dinner": true
        },
        {
            "name": "Pilav",
            "courseLevel": 2,
            "category": 5,
            "parentCategory": 1,
            "snack": false,
            "breakfast": false,
            "lunch": true,
            "dinner": true
        },
        {
            "name": "Nişastalı Sebzeler",
            "courseLevel": 2,
            "category": 5,
            "parentCategory": 1,
            "snack": false,
            "breakfast": false,
            "lunch": true,
            "dinner": true
        },
        {
            "name": "Zeytinyağlı Dolmalar, Sarmalar",
            "courseLevel": 2,
            "category": 5,
            "parentCategory": 1,
            "snack": false,
            "breakfast": false,
            "lunch": true,
            "dinner": true
        },
        {
            "name": "Komposto, Hoşaf",
            "courseLevel": 3,
            "category": 6,
            "parentCategory": 5,
            "snack": false,
            "breakfast": false,
            "lunch": true,
            "dinner": true
        },
        {
            "name": "Yoğurt",
            "courseLevel": 3,
            "category": 7,
            "parentCategory": 5,
            "snack": false,
            "breakfast": false,
            "lunch": true,
            "dinner": true
        },
        {
            "name": "Etsiz Çorba",
            "courseLevel": 2,
            "category": 8,
            "parentCategory": 1,
            "snack": false,
            "breakfast": false,
            "lunch": true,
            "dinner": true
        },
        {
            "name": "Ekmek",
            "courseLevel": 3,
            "category": 9,
            "parentCategory": 8,
            "snack": false,
            "breakfast": false,
            "lunch": true,
            "dinner": true
        },
        {
            "name": "Meyve",
            "courseLevel": 3,
            "category": 10,
            "parentCategory": 8,
            "snack": false,
            "breakfast": false,
            "lunch": true,
            "dinner": true
        },
        {
            "name": "Yoğurt",
            "courseLevel": 3,
            "category": 11,
            "parentCategory": 8,
            "snack": false,
            "breakfast": false,
            "lunch": true,
            "dinner": true
        },
        {
            "name": "Sütlü Tatlılar",
            "courseLevel": 3,
            "category": 12,
            "parentCategory": 8,
            "snack": false,
            "breakfast": false,
            "lunch": true,
            "dinner": true
        },
        {
            "name": "Sütsüz Tatlılar",
            "courseLevel": 3,
            "category": 12,
            "parentCategory": 8,
            "snack": false,
            "breakfast": false,
            "lunch": true,
            "dinner": true
        },
        {
            "name": "Pastalar",
            "courseLevel": 3,
            "category": 12,
            "parentCategory": 8,
            "snack": false,
            "breakfast": false,
            "lunch": true,
            "dinner": true
        },
        {
            "name": "Hamurişi Tatlılar",
            "courseLevel": 3,
            "category": 12,
            "parentCategory": 8,
            "snack": false,
            "breakfast": false,
            "lunch": true,
            "dinner": true
        }
    ]
}''';
}
