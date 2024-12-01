import 'package:flutter/material.dart';
import 'package:transportflutter/database/database_helper.dart';
import 'package:transportflutter/models/cars/cars.dart';

class CarListScreen extends StatefulWidget {
  @override
  _CarListScreenState createState() => _CarListScreenState();
}

class _CarListScreenState extends State<CarListScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  List<Cars> cars = [];
  Cars? selectedCar;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: cars.isEmpty
            ? Center(child: CircularProgressIndicator())
            : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 4,
                    shadowColor: Colors.deepPurple.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12.0),
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
                              car.nom_car,
                              style: TextStyle(fontSize: 16),
                            ),
                          );
                        }).toList(),
                        onChanged: (car) {
                          setState(() {
                            selectedCar = car;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  if (selectedCar != null)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NextScreen(car: selectedCar!),
                          ),
                        );
                      },
                      child: Text(
                        'Valider la sélection',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

class NextScreen extends StatelessWidget {
  final Cars car;

  NextScreen({required this.car});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Car sélectionné',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Card(
          elevation: 3,
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Car: ${car.nom_car}\nID: ${car.id}',
              style: TextStyle(fontSize: 18, color: Colors.deepPurple),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
