// import 'dart:convert';

class Car {
  int? id;
  String nom_car;

  Car({this.id, required this.nom_car});

  // Convertit un objet Car en Map pour la base de données
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom_car': nom_car,
    };
  }

  // Convertit une Map en objet Car
  factory Car.fromMap(Map<String, dynamic> map) {
    return Car(
      id: map['id'],
      nom_car: map['nom_car'],
    );
  }
}

