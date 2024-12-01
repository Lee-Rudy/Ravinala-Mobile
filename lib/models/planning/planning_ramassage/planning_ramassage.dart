import 'package:intl/intl.dart';


class PlanningRamassage {
  int? id;
  int? idUsagers;
  String? matricule;
  String? nomUsager;
  String? nomAxe;
  String? nomVoiture; 
  String? fokontany;
  String? lieu;
  DateTime heure;

  PlanningRamassage({
    this.id,
    required this.idUsagers,
    required this.matricule,
    required this.nomUsager,
    this.nomAxe,
    required this.nomVoiture, 
    required this.fokontany,
    required this.lieu,
    required this.heure,
  });

  Map<String, dynamic> toMap() {
    return { //database
      'id': id, 
      'idUsagers': idUsagers,
      'matricule': matricule,
      'nomUsager': nomUsager,
      'nom_axe': nomAxe,
      'nomVoiture': nomVoiture, 
      'fokontany': fokontany,
      'lieu': lieu,
      'heure': heure.toIso8601String(),
    };
  }

  //gauche = json ; droite = dataBase

  factory PlanningRamassage.fromMap(Map<String, dynamic> map) {
  final timeFormat = DateFormat("HH:mm:ss");

  // Extraction de la partie heure uniquement
  String heureValue = map['heure'];

  if (heureValue.contains("T")) {
    // Si une date est incluse, extrait uniquement la partie heure
    heureValue = heureValue.split("T")[1].split(".")[0];
  }

  print("nomVoiture from database: ${map['nomVoiture']}");

  return PlanningRamassage(
    id: map['id'],
    idUsagers: map['idUsagers'],
    matricule: map['matricule'],
    nomUsager: map['nomUsager'],
    nomAxe: map['nom_axe'],
    nomVoiture: map['nomVoiture'],
    fokontany: map['fokontany'],
    lieu: map['lieu'],
    heure: timeFormat.parse(heureValue),
  );
}

}
