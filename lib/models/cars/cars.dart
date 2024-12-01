// import 'dart:convert';

class Cars {
  int? id;
  String nom_car;

  Cars({this.id, required this.nom_car});

  // Convertit un objet Car en Map pour la base de données
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom_car': nom_car,
    };
  }

  // Convertit une Map en objet Car
  factory Cars.fromMap(Map<String, dynamic> map) {
    return Cars(
      id: map['id'],
      nom_car: map['nom_car'],
    );
  }
}

