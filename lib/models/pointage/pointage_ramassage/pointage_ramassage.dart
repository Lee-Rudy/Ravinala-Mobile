// lib/models/pointage/pointage_ramassage/pointage_ramassage.dart
class PointageRamassage {
  int? id; // Conserver pour usage local
  String matricule;
  String nomUsager;
  String nomVoiture;
  String datetimeRamassage; // Date en String
  int estPresent; // 0 ou 1

  PointageRamassage({
    this.id,
    required this.matricule,
    required this.nomUsager,
    required this.nomVoiture,
    required this.datetimeRamassage,
    this.estPresent = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      // 'id': id, // Exclure l'id de la sérialisation
      'matricule': matricule,
      'nomUsager': nomUsager,
      'nomVoiture': nomVoiture,
      // 'datetime_ramassage': datetimeRamassage,
      // 'datetime_ramassage': DateTime.parse(datetimeRamassage).toUtc().toIso8601String(),

      'datetime_ramassage': datetimeRamassage != null,
      //     ? DateTime.parse(datetimeRamassage!).toIso8601String()
      //     : null, // Convertir en ISO 8601
      'est_present': estPresent,
    };
  }

  factory PointageRamassage.fromMap(Map<String, dynamic> map) {
    return PointageRamassage(
      id: map['id'],
      matricule: map['matricule'] ?? 'Inconnu',
      nomUsager: map['nomUsager'] ?? 'Inconnu',
      nomVoiture: map['nomVoiture'] ?? 'Inconnu',
      datetimeRamassage: map['datetime_ramassage'],
      estPresent: map['est_present'] ?? 0,
    );
  }
}
