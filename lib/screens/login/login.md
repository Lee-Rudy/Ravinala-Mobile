import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Couleur de fond de l'écran
      body: GestureDetector(
        onTap: () {
          // Ferme le clavier lorsqu'on touche en dehors des champs
          FocusScope.of(context).unfocus();
        },
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: screenWidth * 0.5, // Ajuste la largeur à 50% de l'écran
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
                        onPressed: () {
                          // Valide le formulaire
                          if (_formKey.currentState!.validate()) {
                            // Si le formulaire est valide, procéder à la connexion
                            String carName = carNameController.text.trim();
                            String password = passwordController.text.trim();

                            // Vous pouvez ajouter ici votre logique de connexion (authentification)

                            // Redirection après connexion
                            Navigator.pushReplacementNamed(context, '/');
                          }
                        },
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
    );
  }
}
