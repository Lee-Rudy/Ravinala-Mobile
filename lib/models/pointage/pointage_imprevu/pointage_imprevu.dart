// lib/models/pointage/pointage_imprevu/pointage_imprevu.dart
class PointageImprevu {
  int? id; // Conserver pour usage local
  String matricule;
  String nom;
  String nomVoiture;
  String datetimeImprevu; // Date en String

  PointageImprevu({
    this.id,
    required this.matricule,
    required this.nom,
    required this.nomVoiture,
    required this.datetimeImprevu,
  });

  Map<String, dynamic> toMap() {
    return {
      // 'id': id, // Exclure l'id de la sérialisation
      'matricule': matricule,
      'nom':nom,
      'nomVoiture': nomVoiture,
      // 'datetime_imprevu': datetimeImprevu,
      // 'datetime_imprevu': DateTime.parse(datetimeImprevu).toUtc().toIso8601String(),
      'datetime_imprevu': datetimeImprevu != null 
      //     ? DateTime.parse(datetimeImprevu!).toIso8601String()
      //     : null, // Convertir en ISO 8601
    };
  }

  factory PointageImprevu.fromMap(Map<String, dynamic> map) {
    return PointageImprevu(
      id: map['id'],
      matricule: map['matricule'] ?? 'Inconnu',
      nom: map['nom'] ?? 'Inconnu',
      nomVoiture: map['nomVoiture'] ?? 'Inconnu',
      datetimeImprevu: map['datetime_imprevu'],
    );
  }
}
