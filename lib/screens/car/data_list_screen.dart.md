import 'package:flutter/material.dart';
import 'package:transportflutter/database/database_helper.dart';
import 'package:transportflutter/models/cars/cars_mobile.dart';
import 'package:transportflutter/models/usagers/usagers_mobile.dart';

class DataListScreen extends StatefulWidget {
  @override
  _DataListScreenState createState() => _DataListScreenState();
}

class _DataListScreenState extends State<DataListScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  List<Car> cars = [];
  List<Usagers> usagers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadDataFromDatabase();
  }

  Future<void> loadDataFromDatabase() async {
    // Récupère les données de la base de données
    List<Car> carList = await dbHelper.fetchAllCars();
    List<Usagers> usagerList = await dbHelper.fetchAllUsagers();

    // Met à jour l'état pour afficher les données
    setState(() {
      cars = carList;
      usagers = usagerList;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des Données'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                ListTile(
                  title: Text(
                    'Cars',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ...cars.map((car) => ListTile(
                      title: Text(car.nom_car),
                      subtitle: Text('ID: ${car.id}'),
                    )),
                Divider(),
                ListTile(
                  title: Text(
                    'Usagers',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ...usagers.map((usager) => ListTile(
                      title: Text('${usager.nom} ${usager.prenom}'),
                      subtitle: Text('Matricule: ${usager.matricule}'),
                    )),
              ],
            ),
    );
  }
}
