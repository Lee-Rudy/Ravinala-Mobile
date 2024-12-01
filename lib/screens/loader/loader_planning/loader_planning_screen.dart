import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transportflutter/database/database_helper.dart';
import 'package:transportflutter/services/api_services.dart';
import 'package:transportflutter/models/planning/planning_ramassage/planning_ramassage.dart';
import 'package:transportflutter/models/planning/planning_depot/planning_depot.dart';

class Loader_planning_screen extends StatefulWidget {
  @override
  _Loader_planning_screenState createState() => _Loader_planning_screenState();
}

class _Loader_planning_screenState extends State<Loader_planning_screen> {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  final ApiService apiService = ApiService();
  String? loginName;
  double progress = 0.0;
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadLoginName();
  }

  Future<void> _loadLoginName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      loginName = prefs.getString('nom_car_login');
    });
  }

  Future<void> loadData() async {
    if (loginName == null || loginName!.isEmpty) {
      setState(() {
        errorMessage = 'Nom du car non trouvé dans la session.';
      });
      _showErrorDialog(errorMessage!);
      return;
    }

    setState(() {
      progress = 0.0;
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Charger les données de ramassage
      List<PlanningRamassage> ramassageList =
          await apiService.fetchPlanningRamassage(loginName!);
      setState(() => progress = 0.2);

      // Insérer/Mettre à jour les enregistrements de ramassage
      for (var i = 0; i < ramassageList.length; i++) {
        await dbHelper.insertOrUpdatePlanningRamassage(ramassageList[i]);
        setState(() => progress = 0.2 + (0.4 * (i + 1) / ramassageList.length));
      }

      // Charger les données de dépôt
      List<PlanningDepot> depotList =
          await apiService.fetchPlanningDepot(loginName!);
      setState(() => progress = 0.7);

      // Insérer/Mettre à jour les enregistrements de dépôt
      for (var i = 0; i < depotList.length; i++) {
        await dbHelper.insertOrUpdatePlanningDepot(depotList[i]);
        setState(() => progress = 0.7 + (0.3 * (i + 1) / depotList.length));
      }

      setState(() {
        isLoading = false;
        progress = 1.0;
      });

      _showSuccessDialog('Données chargées avec succès !');
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = 'Erreur : $error';
      });
      _showErrorDialog(errorMessage!);
    }
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

  // Méthode pour afficher une boîte de dialogue de confirmation avant de charger les données
  Future<void> _showConfirmationDialog() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmer le chargement'),
          content: Text(
              'Voulez-vous vraiment charger la liste de ramassage et dépôt ?'),
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
      await loadData();
    }
  }

  Widget _buildLoadButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF45B48E),
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: isLoading ? null : _showConfirmationDialog,
      child: Text(
        'Charger la liste de ramassage / dépôt',
        style: TextStyle(fontSize: 15.5, color: Colors.white),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    if (!isLoading) return SizedBox.shrink();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(
          value: progress,
          backgroundColor: Color(0xFF45B48E).withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF45B48E)),
        ),
        SizedBox(height: 10),
        Text(
          '${(progress * 100).toInt()}% complété',
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (loginName == null) {
      return Center(
          child: CircularProgressIndicator(color: Color(0xFF45B48E)));
    } else {
      return Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLoadButton(),
              SizedBox(height: 20),
              _buildLoadingIndicator(),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Charger les Données du Ramassage/Dépôt',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF45B48E),
        centerTitle: true,
        elevation: 3,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: _buildContent(),
      ),
    );
  }
}
