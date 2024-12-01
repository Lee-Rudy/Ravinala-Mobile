// import 'dart:convert';

class Usagers
{
  int? id;
  String matricule;
  String nom;
  String prenom;

  Usagers
  ({
      this.id,
      required this.matricule,
      required this.nom,
      required this.prenom
   });

  //convert object to map
   Map<String, dynamic> toMap() {
    return {
      'id': id,
      'matricule': matricule,
      'nom': nom,
      'prenom': prenom,
    };
  }

  //convert map to object
   factory Usagers.fromMap(Map<String, dynamic> map) {
    return Usagers(
      id: map['id'],
      matricule: map['matricule'],
      nom: map['nom'],
      prenom: map['prenom'],

    );
  }

}




