import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transportflutter/services/api_services.dart';
import 'package:flutter/services.dart'; // Import nécessaire pour SystemNavigator

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController carNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isPasswordHidden = true;

  // Clé pour le formulaire
  final _formKey = GlobalKey<FormState>();

  // Indicateur de chargement
  bool _isLoading = false;

  // Instance de ApiService
  final ApiService apiService = ApiService();

  /// Fonction pour afficher le pop-up d'erreur
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 10),
              Text(
                'Erreur',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
          content: Text(
            message,
            style: TextStyle(color: Colors.red),
          ),
          actions: [
            TextButton(
              child: Text(
                'OK',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// Fonction d'authentification
  Future<void> _authenticate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    String carName = carNameController.text.trim();
    String password = passwordController.text.trim();

    setState(() {
      _isLoading = true;
    });

    // Afficher le loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final result = await apiService.login(carName, password);

      Navigator.of(context).pop(); // Fermer le loading

      if (result['success']) {
        String loginName = result['user']['nom_car_login'];
        print('Utilisateur connecté : $loginName');

        // Stocker le nom_car_login dans le stockage local
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('nom_car_login', loginName);
        print('nom_car_login stocké dans SharedPreferences');

        // Afficher un message de succès (facultatif)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.green,
          ),
        );

        // Redirection après authentification réussie via les routes nommées
        Navigator.pushReplacementNamed(context, '/');
      } else {
        // Afficher un message d'erreur dans un pop-up
        print('Erreur lors de la connexion : ${result['message']}');
        _showErrorDialog(result['message']);
      }
    } catch (e) {
      Navigator.of(context).pop(); // Fermer le loading
      print('Erreur lors de l\'authentification : ${e.toString()}'); // Log supplémentaire
      _showErrorDialog('Une erreur est survenue. Veuillez réessayer.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    carNameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async {
        // Option 1 : Quitter l'application
        bool exitApp = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Quitter'),
            content: Text('Voulez-vous quitter l\'application?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Non'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Oui'),
              ),
            ],
          ),
        );
        if (exitApp) {
          SystemNavigator.pop(); // Quitter l'application
        }
        return Future.value(false); // Ne pas laisser le système gérer le retour
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5), // Couleur de fond de l'écran
        body: GestureDetector(
          onTap: () {
            // Ferme le clavier lorsqu'on touche en dehors des champs
            FocusScope.of(context).unfocus();
          },
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                width: screenWidth * 0.5, // Ajuste la largeur à 80% de l'écran
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white, // Couleur de fond du formulaire
                  borderRadius: BorderRadius.circular(15.0), // Coins arrondis
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3), // Ombre légère
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey, // Assignation de la clé au Form
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 20),
                      // Logo
                      Center(
                        child: Image.asset(
                          'lib/assets/images/logo.png', // Remplacez par le chemin de votre image
                          height: 100, // Ajustez la taille de l'image
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Titre
                      Text(
                        'Bienvenue',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF45B48E),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Champ pour le nom du car
                      TextFormField(
                        controller: carNameController,
                        decoration: InputDecoration(
                          labelText: 'Nom du car',
                          prefixIcon: const Icon(Icons.directions_car, color: Color(0xFF45B48E)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        // Validator pour vérifier si le champ est vide
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Veuillez entrer le nom du car';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      // Champ pour le mot de passe
                      TextFormField(
                        controller: passwordController,
                        obscureText: isPasswordHidden,
                        decoration: InputDecoration(
                          labelText: 'Mot de passe',
                          prefixIcon: const Icon(Icons.lock, color: Color(0xFF45B48E)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          suffixIcon: IconButton(
                            icon: Icon(
                              isPasswordHidden ? Icons.visibility : Icons.visibility_off,
                              color: const Color(0xFF45B48E),
                            ),
                            onPressed: () {
                              setState(() {
                                isPasswordHidden = !isPasswordHidden;
                              });
                            },
                          ),
                        ),
                        // Validator pour vérifier si le champ est vide
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Veuillez entrer le mot de passe';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      // Bouton de connexion
                      SizedBox(
                        width: double.infinity, // Le bouton prend toute la largeur disponible
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF45B48E),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          onPressed: _isLoading ? null : _authenticate,
                          child: const Text(
                            'Se connecter',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
