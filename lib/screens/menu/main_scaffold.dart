import 'package:flutter/material.dart';
import 'package:transportflutter/screens/home_screen.dart';
import 'package:transportflutter/screens/detail_screen.dart';

//code tsy miasa
class MainScaffold extends StatelessWidget {
  final Widget child;
  final String title;

  MainScaffold({required this.child, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menuuuuu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('detail'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/details');
              },
            ),
          ],
        ),
      ),
      body: child,
    );
  }
}
