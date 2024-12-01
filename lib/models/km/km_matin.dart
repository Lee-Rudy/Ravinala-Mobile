class KMmatin {
  int? id;
  String depart;
  String fin;
  String nomVoiture;
  String datetimeMatin;

  KMmatin({
    this.id,
    required this.depart,
    required this.fin,
    required this.nomVoiture,
    required this.datetimeMatin,
  });

  Map<String, dynamic> toMap()
  {
    return
    {
      // 'id' : id,
      'depart': depart,
      'fin': fin,
      'nomVoiture' : nomVoiture,
      // 'datetime_matin': DateTime.parse(datetimeMatin).toUtc().toIso8601String(),
      'datetime_matin': datetimeMatin,
      // 'datetime_matin' : datetimeMatin != null 
      //     ? DateTime.parse(datetimeMatin!).toIso8601String()
      //     : null,
    };
  }

  factory KMmatin.fromMap(Map<String, dynamic> map)
  {
    return KMmatin(
      id: map['id'],
      depart : map['depart'] ?? 'Inconnu',
      fin : map['fin'] ?? 'Inconnu',
      nomVoiture: map['nomVoiture'] ?? 'Inconnu',
      datetimeMatin : map['datetime_matin'],
    );
  }
}