// lib/models/bouton/bouton.dart
class Bouton {
  int? id; // Conserver pour usage local
  String nomVoiture;
  String? datetimeDepart; // Date en String
  String? datetimeArrivee; // Date en String

  Bouton({
    this.id,
    required this.nomVoiture,
    this.datetimeDepart,
    this.datetimeArrivee,
  });

  Map<String, dynamic> toMap() {
    return {
      // 'id': id, // Exclure l'id de la sérialisation
      'nomVoiture': nomVoiture,
      'datetime_depart': datetimeDepart != null 
          ? DateTime.parse(datetimeDepart!).toIso8601String()
          : null, // Convertir en ISO 8601
      'datetime_arrivee': datetimeArrivee != null 
          ? DateTime.parse(datetimeArrivee!).toIso8601String()
          : null, // Convertir en ISO 8601
    };
  }

  factory Bouton.fromMap(Map<String, dynamic> map) {
    return Bouton(
      id: map['id'],
      nomVoiture: map['nomVoiture'] ?? 'Inconnu',
      datetimeDepart: map['datetime_depart'],
      datetimeArrivee: map['datetime_arrivee'],
    );
  }
}
