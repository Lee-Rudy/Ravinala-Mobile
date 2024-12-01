import 'package:flutter/material.dart';
import 'package:transportflutter/database/database_helper.dart';
import 'package:transportflutter/services/api_services.dart';
import 'package:transportflutter/models/planning/planning_ramassage/planning_ramassage.dart';
import 'package:transportflutter/models/planning/planning_depot/planning_depot.dart';
import 'package:transportflutter/models/cars/cars.dart';

class Loader_planning_screen extends StatefulWidget {
  @override
  _Loader_planning_screenState createState() => _Loader_planning_screenState();
}

class _Loader_planning_screenState extends State<Loader_planning_screen> {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  final ApiService apiService = ApiService();
  List<Cars> cars = [];
  Cars? selectedCar;
  double progress = 0.0;
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadCars();
  }

  Future<void> loadCars() async {
    final db = await dbHelper.database;
    final carList = await db.query('cars');
    print('Cars loaded from database: $carList'); // Vérifie les données brutes

    setState(() {
      cars = carList.map((car) => Cars.fromMap(car)).toList();
    });
  }

  Future<void> loadData() async {
    if (selectedCar == null || selectedCar!.nom_car == null || selectedCar!.nom_car!.isEmpty) {
      setState(() {
        errorMessage = 'Veuillez sélectionner un car valide.';
      });
      return;
    }

    setState(() {
      progress = 0.0;
      isLoading = true;
      errorMessage = null;
    });

    try {
      List<PlanningRamassage> ramassageList = await apiService.fetchPlanningRamassage(selectedCar!.nom_car!);
      setState(() => progress = 0.2);

      // Insérer/Mettre à jour les enregistrements de ramassage
      for (var i = 0; i < ramassageList.length; i++) {
        await dbHelper.insertOrUpdatePlanningRamassage(ramassageList[i]);
        setState(() => progress = 0.2 + (0.4 * (i + 1) / ramassageList.length));
      }

      List<PlanningDepot> depotList = await apiService.fetchPlanningDepot(selectedCar!.nom_car!);
      setState(() => progress = 0.7);

      // Insérer/Mettre à jour les enregistrements de depot
      for (var i = 0; i < depotList.length; i++) {
        await dbHelper.insertOrUpdatePlanningDepot(depotList[i]);
        setState(() => progress = 0.7 + (0.3 * (i + 1) / depotList.length));
      }

      setState(() {
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = 'Erreur : $error';
      });
    }
  }

  Widget _buildCarSelectionCard() {
    return Card(
      elevation: 4,
      shadowColor: Colors.deepPurple.withOpacity(0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: DropdownButton<Cars>(
          value: selectedCar,
          hint: Text(
            "Choisissez un car",
            style: TextStyle(fontSize: 18, color: Colors.grey[700]),
          ),
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: Colors.deepPurple),
          items: cars.map((car) {
            return DropdownMenuItem<Cars>(
              value: car,
              child: Text(
                car.nom_car ?? 'Nom non disponible',
                style: TextStyle(fontSize: 16),
              ),
            );
          }).toList(),
          onChanged: (car) {
            setState(() {
              selectedCar = car;
              progress = 0.0;
              errorMessage = null;
            });
            print('Selected Car: ${selectedCar?.nom_car}'); // Vérification
          },
        ),
      ),
    );
  }

  Widget _buildLoadButton() {
    if (selectedCar == null) return SizedBox.shrink();
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: loadData,
      child: Text(
        'Charger la liste de ramassage / depot',
        style: TextStyle(fontSize: 15.5, color: Colors.white),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    if (!isLoading) return SizedBox.shrink();
    return Center(
      child: Column(
        children: [
          CircularProgressIndicator(
            value: progress,
            backgroundColor: Colors.deepPurple.shade100,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
          ),
          SizedBox(height: 10),
          Text(
            '${(progress * 100).toInt()}% complété',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessMessage() {
    if (isLoading || progress < 1.0 || errorMessage != null || selectedCar == null) {
      return SizedBox.shrink();
    }

    return Center(
      child: Container(
        margin: EdgeInsets.only(top: 20),
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.green[50],
          border: Border.all(color: Colors.green),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          "Données chargées avec succès !",
          style: TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    if (errorMessage == null) return SizedBox.shrink();
    return Center(
      child: Container(
        margin: EdgeInsets.only(top: 20),
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.red[50],
          border: Border.all(color: Colors.red),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          errorMessage!,
          style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (cars.isEmpty) {
      return Center(child: CircularProgressIndicator(color: Colors.deepPurple));
    } else {
      return SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCarSelectionCard(),
            SizedBox(height: 20),
            _buildLoadButton(),
            SizedBox(height: 20),
            _buildLoadingIndicator(),
            _buildSuccessMessage(),
            _buildErrorMessage(),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Charger les Données du Ramassage/Dépot',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepPurple,
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
