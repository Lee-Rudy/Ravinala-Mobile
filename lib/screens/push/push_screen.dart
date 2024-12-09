import 'package:flutter/material.dart';
import 'package:transportflutter/database/database_helper.dart';
import 'package:transportflutter/services/api_services.dart';
import 'package:transportflutter/models/bouton/bouton.dart' as car_button_model;
import 'package:transportflutter/models/push/push_data.dart';
import 'package:transportflutter/models/km/km_matin.dart';
import 'package:transportflutter/models/km/km_soir.dart';

class PushDataScreen extends StatefulWidget {
  @override
  _PushDataScreenState createState() => _PushDataScreenState();
}

class _PushDataScreenState extends State<PushDataScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  final ApiService apiService = ApiService();
  bool isLoading = false;

  Future<void> pushData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final db = await dbHelper.database;

      // Récupérer les données des différentes tables
      final ramassageListRaw = await dbHelper.fetchAllPointageRamassage();
      final depotListRaw = await dbHelper.fetchAllPointageDepot();
      final btnListRaw = await dbHelper.fetchAllCarButton();
      final imprevuListRaw = await dbHelper.fetchAllPointageImprevu();
      final kmMatinRaw = await dbHelper.fetchAllKMmatin();
      final kmSoirRaw = await dbHelper.fetchAllKMsoir();

      // Convertir les données brutes de la base de données en objets correspondants
      final ramassageList = ramassageListRaw.map((e) => PointageRamassage(
            matricule: e.matricule,
            nomUsager: e.nomUsager,
            nomVoiture: e.nomVoiture,
            datetimeRamassage: e.datetimeRamassage,
            estPresent: e.estPresent.toString(), // parse en string
          )).toList();

      final depotList = depotListRaw.map((e) => PointageDepot(
            matricule: e.matricule,
            nomUsager: e.nomUsager,
            nomVoiture: e.nomVoiture,
            datetimeDepot: e.datetimeDepot,
            estPresent: e.estPresent.toString(), // Assurez-vous que estPresent est bien un String
          )).toList();

      final btnList = btnListRaw.map((e) => car_button_model.CarButton(
            datetimeDepart: e.datetimeDepart,
            datetimeArrivee: e.datetimeArrivee,
            nomVoiture: e.nomVoiture,
            motif: e.motif,
          )).toList();

      final imprevuList = imprevuListRaw.map((e) => PointageImprevu(
            matricule: e.matricule,
            nom: e.nom,
            datetimeImprevu: e.datetimeImprevu,
            nomVoiture: e.nomVoiture,
          )).toList();

      final kmMatinList = kmMatinRaw.map((e) => KmMatin(
            depart: e.depart,
            fin: e.fin,
            nomVoiture: e.nomVoiture,
            datetimeMatin: e.datetimeMatin,
          )).toList();

      final kmSoirList = kmSoirRaw.map((e) => KmSoir(
            depart: e.depart,
            fin: e.fin,
            nomVoiture: e.nomVoiture,
            datetimeSoir: e.datetimeSoir,
          )).toList();

      // Créer un objet PushDataRequest
      PushDataRequest pushData = PushDataRequest(
        pointageRamassage: ramassageList,
        pointageDepot: depotList,
        btn: btnList.isNotEmpty ? btnList : null,
        pointageUsagersImprevu: imprevuList,
        kmatin: kmMatinList,
        ksoir: kmSoirList,
      );

      // Envoyer les données au serveur
      await apiService.sendAllData(pushData);

      setState(() {
        isLoading = false;
      });

      // Afficher un message de succès via une boîte de dialogue
      _showSuccessDialog('Données envoyées avec succès !');
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      // Afficher un message d'erreur via une boîte de dialogue
      _showErrorDialog('Erreur : ${e.toString()}');
    }
  }

  // Méthode pour afficher une boîte de dialogue de succès
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Succès'),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('Fermer'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  // Méthode pour afficher une boîte de dialogue d'erreur
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Erreur'),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('Fermer'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  // Méthode pour afficher une boîte de dialogue de confirmation
  Future<void> _showConfirmationDialog() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmer l\'envoi'),
          content: Text('Voulez-vous vraiment envoyer les données ?'),
          actions: [
            TextButton(
              child: Text('Annuler'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text('Confirmer'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await pushData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Envoyer les Données',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF45B48E),
        centerTitle: true,
      ),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF45B48E)),
              )
            : ElevatedButton(
                onPressed: _showConfirmationDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF45B48E),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Envoyer les données',
                  style: TextStyle(fontSize: 15.5, color: Colors.white),
                ),
              ),
      ),
    );
  }
}
