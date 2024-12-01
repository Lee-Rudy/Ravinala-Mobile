import 'package:flutter/material.dart';
import 'package:transportflutter/database/database_reset.dart';

class ResetScreen extends StatefulWidget {
  @override
  _ResetScreenState createState() => _ResetScreenState();
}

class _ResetScreenState extends State<ResetScreen> {
  final DatabaseReset dbReset = DatabaseReset.instance;
  bool _isProcessing = false;

  /// Méthode pour afficher la boîte de dialogue de confirmation
  Future<void> _showConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible:
          false, // L'utilisateur doit appuyer sur un bouton pour fermer la boîte de dialogue
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Voulez-vous vraiment supprimer toutes les données ?'),
          actions: <Widget>[
            TextButton(
              child: Text('Non'),
              onPressed: () {
                Navigator.of(context).pop(); // Fermer la boîte de dialogue
              },
            ),
            TextButton(
              child: Text('Oui'),
              onPressed: () async {
                Navigator.of(context).pop(); // Fermer la boîte de dialogue
                await _truncateDatabase();
              },
            ),
          ],
        );
      },
    );
  }

  /// Méthode pour troncater la base de données
  Future<void> _truncateDatabase() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      await dbReset.truncateAllTables();

      // Afficher un message de succès via un pop-up
      _showSuccessDialog('Toutes les données ont été supprimées avec succès.');
    } catch (e) {
      // Afficher un message d'erreur via un pop-up
      _showErrorDialog('Erreur lors de la suppression des données.');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  // Méthode pour afficher un pop-up de succès
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

  // Méthode pour afficher un pop-up d'erreur
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Réinitialisation de la Base de Données',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF45B48E),
        centerTitle: true,
      ),
      body: Center(
        child: _isProcessing
            ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF45B48E)),
              )
            : ElevatedButton.icon(
                icon: Icon(Icons.delete),
                label: Text('Réinitialiser la Base de Données'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF45B48E), // Couleur du bouton
                  foregroundColor: Colors.white, // Couleur du texte et de l'icône
                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                  textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: _showConfirmationDialog,
              ),
      ),
    );
  }
}
