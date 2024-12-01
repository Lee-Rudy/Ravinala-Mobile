import 'package:flutter/material.dart';
import 'package:transportflutter/database/database_helper.dart';
import 'package:transportflutter/models/cars/cars_mobile.dart';


class CarListScreen extends StatelessWidget {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  Future<List<Car>> fetchCars() async {
    final db = await dbHelper.database;
    final cars = await db.query('cars_mobile');
    return cars.map((car) => Car.fromMap(car)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Liste des Cars')),
      body: FutureBuilder<List<Car>>(
        future: fetchCars(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Aucun car trouvé'));
          } else {
            return ListView(
              children: snapshot.data!.map((car) {
                return ListTile(
                  title: Text(car.nom_car),
                  subtitle: Text('ID: ${car.id}'),
                );
              }).toList(),
            );
          }
        },
      ),
    );
  }
}
