// lib/models/push/push_data.dart
import 'package:transportflutter/models/bouton/bouton.dart';
import 'package:transportflutter/models/pointage/pointage_depot/pointage_depot.dart';
import 'package:transportflutter/models/pointage/pointage_ramassage/pointage_ramassage.dart';
import 'package:transportflutter/models/pointage/pointage_imprevu/pointage_imprevu.dart';
import 'package:transportflutter/models/bouton/bouton.dart' as car_button_model;
import 'package:transportflutter/models/km/km_matin.dart';
import 'package:transportflutter/models/km/km_soir.dart';



class PushDataRequest {
  final List<PointageRamassage>? pointageRamassage;
  final List<PointageDepot>? pointageDepot;
  final List<CarButton>? btn;
  // final List<car_button_model.CarButton>? btn;  // Remplacer Bouton par CarButton
    // Remplacer Bouton par CarButton
  final List<PointageImprevu>? pointageUsagersImprevu;
  final List<KmMatin>? kmatin;
  final List<KmSoir>? ksoir;



  PushDataRequest({
    this.pointageRamassage,
    this.pointageDepot,
    this.btn,
    this.pointageUsagersImprevu,
    this.kmatin,
    this.ksoir,
  });

  // Convertir les données en Map pour l'envoi
  Map<String, dynamic> toMap() {
    return {
      'PointageRamassage': pointageRamassage?.map((e) => e.toMap()).toList(),
      'PointageDepot': pointageDepot?.map((e) => e.toMap()).toList(),
      'Btn': btn?.map((e) => e.toMap()).toList(),
      'PointageUsagersImprevu': pointageUsagersImprevu?.map((e) => e.toMap()).toList(),
      'KMMATIN': kmatin?.map((e) => e.toMap()).toList(),
      'KMSOIR': ksoir?.map((e) => e.toMap()).toList(),
    };
  }
}


class PointageRamassage {
  final String matricule;
  final String nomUsager;
  final String nomVoiture;
  final String datetimeRamassage;
  final String estPresent;

  PointageRamassage({
    required this.matricule,
    required this.nomUsager,
    required this.nomVoiture,
    required this.datetimeRamassage,
    required this.estPresent,
  });

  Map<String, dynamic> toMap() {
    return {
      'Matricule': matricule,
      'NomUsager': nomUsager,
      'NomVoiture': nomVoiture,
      'DatetimeRamassage': datetimeRamassage,
      'EstPresent': estPresent,
    };
  }
}

class PointageDepot {
  final String matricule;
  final String nomUsager;
  final String nomVoiture;
  final String datetimeDepot;
  final String estPresent;

  PointageDepot({
    required this.matricule,
    required this.nomUsager,
    required this.nomVoiture,
    required this.datetimeDepot,
    required this.estPresent,
  });

  Map<String, dynamic> toMap() {
    return {
      'Matricule': matricule,
      'NomUsager': nomUsager,
      'NomVoiture': nomVoiture,
      'DatetimeDepot': datetimeDepot,
      'EstPresent': estPresent,
    };
  }
}

class Bouton {
  final String datetimeDepart;
  final String datetimeArrivee;
  final String nomVoiture;

  Bouton({
    required this.datetimeDepart,
    required this.datetimeArrivee,
    required this.nomVoiture,
  });

  Map<String, dynamic> toMap() {
    return {
      'DatetimeDepart': datetimeDepart,    // Passage en PascalCase
      'DatetimeArrivee': datetimeArrivee,  // Passage en PascalCase
      'NomVoiture': nomVoiture,   
    };
  }
}

class PointageImprevu {
  final String matricule;
  final String nom;
  final String datetimeImprevu;
  final String nomVoiture;

  PointageImprevu({
    required this.matricule,
    required this.nom,
    required this.datetimeImprevu,
    required this.nomVoiture,
  });

  Map<String, dynamic> toMap() {
    return {
      'Matricule': matricule,
      'nom': nom,
      'DatetimeImprevu': datetimeImprevu,
      'NomVoiture': nomVoiture,
    };
  }


}
  //km
  //km matin
  class KmMatin {
  final String depart;
  final String fin;
  final String nomVoiture;
  final String datetimeMatin;


  KmMatin({
    required this.depart,
    required this.fin,
    required this.nomVoiture,
    required this.datetimeMatin,
  });

  Map<String, dynamic> toMap() {
    return {
      'Depart': depart,
      'Fin': fin,
      'NomVoiture': nomVoiture,
      'DatetimeMatin': datetimeMatin,
    };

  }

   //km matin
}
  class KmSoir {
  final String depart;
  final String fin;
  final String nomVoiture;
  final String datetimeSoir;


  KmSoir({
    required this.depart,
    required this.fin,
    required this.nomVoiture,
    required this.datetimeSoir,
  });

  Map<String, dynamic> toMap() {
    return {
      'Depart': depart,
      'Fin': fin,
      'NomVoiture': nomVoiture,
      'DatetimeSoir': datetimeSoir,
    };

  }
  }
  

