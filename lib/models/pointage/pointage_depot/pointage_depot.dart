// lib/models/pointage/pointage_depot/pointage_depot.dart
class PointageDepot {
  int? id; // Conserver pour usage local
  String matricule;
  String nomUsager;
  String nomVoiture;
  String datetimeDepot; // Date en String
  int estPresent; // 0 ou 1

  PointageDepot({
    this.id,
    required this.matricule,
    required this.nomUsager,
    required this.nomVoiture,
    required this.datetimeDepot,
    this.estPresent = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      // 'id': id, // Exclure l'id de la sérialisation
      'matricule': matricule,
      'nomUsager': nomUsager,
      'nomVoiture': nomVoiture,
      // 'datetime_depot': DateTime.parse(datetimeDepot).toUtc().toIso8601String(),
      'datetime_depot': datetimeDepot,
      // 'datetime_depot': datetimeDepot != null 
      //     ? DateTime.parse(datetimeDepot!).toIso8601String()
      //     : null, // Convertir en ISO 8601
      'est_present': estPresent,
    };
  }

  factory PointageDepot.fromMap(Map<String, dynamic> map) {
    return PointageDepot(
      id: map['id'],
      matricule: map['matricule'] ?? 'Inconnu',
      nomUsager: map['nomUsager'] ?? 'Inconnu',
      nomVoiture: map['nomVoiture'] ?? 'Inconnu',
      datetimeDepot: map['datetime_depot'],
      estPresent: map['est_present'] ?? 0,
    );
  }
}
