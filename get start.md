flutter run 

install sqlite :
dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.0.0+4
  path: ^1.8.0

  puis : flutter pub get


  créer une base de donnée sqlite , installer sur le lien : 
  https://www.sqlite.org/download.html  --> go to (Precompiled Binaries for Windows, then sqlite-tools-win-x64-3470000.zip)
  
  référence youTube : 
  https://youtu.be/-bDwNR_C0dE?si=TymnNLPqjLZBOoVZ

  menu navbar flutter : https://docs.flutter.dev/cookbook/design/drawer

  - dézipper le fichier zip 
  - renommer le dossier en sqlite3
  - mettre dans une variable d'environement path le chemin vers sqlite3

  - aller vers le chemin où créer la base de données 
  - open cmd : 
  
  D:\ITU\Stage\RAVINALA AIRPORT\informatique\gestion de transport\code\mobile\flutter\transportflutter\lib\assets\database>sqlite3 bdd.db
        SQLite version 3.42.0 2023-05-16 12:36:15
        Enter ".help" for usage hints.

sqlite> .databases
        main: D:\ITU\Stage\RAVINALA AIRPORT\informatique\gestion de transport\code\mobile\flutter\transportflutter\lib\assets\database\bdd.db r/w

        ici le fichier .db est crée automatiquement dans le répertoire
sqlite>



icone :

https://api.flutter.dev/flutter/material/Icons-class.html?gad_source=1&gclid=Cj0KCQiA0MG5BhD1ARIsAEcZtwTyZ0G9WjdwyHdMW94scCq2CP4U9AthC5UyfRny_qFdE7dXVQqE4fYaAtAYEALw_wcB&gclsrc=aw.ds

changer l'icone du logo :
flutter pub run flutter_native_splash:create
flutter pub run flutter_launcher_icons:main

session variable = session storage
flutter pub add session_storage