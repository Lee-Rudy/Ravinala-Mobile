import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart'; // Pour une animation supplémentaire

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
  bool isLoading = false;
  String? errorMessage;
  bool isSuccess = false;

  @override
  void initState() {
    super.initState();
    loadCars();
  }

  Future<void> loadCars() async {
    final db = await dbHelper.database;
    final carList = await db.query('cars');
    setState(() {
      cars = carList.map((car) => Cars.fromMap(car)).toList();
    });
  }

  Future<void> loadData() async {
    if (selectedCar == null || selectedCar!.nom_car == null || selectedCar!.nom_car!.isEmpty) {
      setState(() {
        errorMessage = 'Veuillez sélectionner un car valide.';
        isSuccess = false;
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
      isSuccess = false;
    });

    try {
      // Simule la logique réelle pour charger les données
      await Future.delayed(Duration(seconds: 3)); // Simulation
      setState(() {
        isLoading = false;
        isSuccess = true;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = 'Erreur : $error';
        isSuccess = false;
      });
    }
  }

  Widget _buildLoadButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSuccess ? Colors.green : Colors.deepPurple,
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: isLoading
          ? null // Désactive le bouton pendant le chargement
          : loadData,
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 500),
        child: isLoading
            ? SpinKitThreeBounce(
                color: Colors.white,
                size: 20.0,
                key: ValueKey('loading'),
              )
            : Text(
                isSuccess
                    ? 'Succès !'
                    : errorMessage != null
                        ? 'Réessayer'
                        : 'Charger les données',
                style: TextStyle(fontSize: 15.5, color: Colors.white),
                key: ValueKey(isSuccess ? 'success' : 'normal'),
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
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: DropdownButton<Cars>(
                  value: selectedCar,
                  hint: Text("Choisissez un car"),
                  isExpanded: true,
                  items: cars.map((car) {
                    return DropdownMenuItem<Cars>(
                      value: car,
                      child: Text(car.nom_car ?? 'Nom non disponible'),
                    );
                  }).toList(),
                  onChanged: (car) {
                    setState(() {
                      selectedCar = car;
                      errorMessage = null;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            _buildLoadButton(),
            if (errorMessage != null) ...[
              SizedBox(height: 20),
              Text(
                errorMessage!,
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            ],
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chargement des données'),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: _buildContent(),
      ),
    );
  }
}
