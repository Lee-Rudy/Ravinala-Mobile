-- database name :  bdd 
-- type : sqlite3
-- description : bdd pour app mobile , pointage des usagers



--sqlite3 bdd.db

-- .schema utilisateurs
-- .schema pointage
-- .tables
---------------------------------------------------------


CREATE TABLE cars_mobile (
    id INTEGER PRIMARY KEY,
    nom_car TEXT,
    --cars_server_id INTEGER --new
);

ALTER TABLE cars_mobile ADD COLUMN cars_server_id INTEGER;


CREATE TABLE usagers_mobile (
    id INTEGER PRIMARY KEY,
    matricule TEXT, 
    nom TEXT,
    prenom TEXT,
    --usagers_server_id INTEGER --new
);

insert into usagers_mobile(matricule, nom, prenom) values('mat001', 'john', 'doe');

ALTER TABLE usagers_mobile ADD COLUMN usagers_server_id INTEGER;

PRAGMA table_info(usagers_mobile); --consulter les champs de la table


CREATE TABLE pointage_usagers_mobile (
    id INTEGER PRIMARY KEY,
    cars_mobile_id INTEGER,
    usagers_mobile_id INTEGER,
    heure_pointage TIME,
    date_pointage DATE,
    FOREIGN KEY (cars_mobile_id) REFERENCES cars_mobile(id),
    FOREIGN KEY (usagers_mobile_id) REFERENCES usagers_mobile(id)
);

CREATE TABLE durree_cars (
    id INTEGER PRIMARY KEY,
    date_durree DATE,
    heure_depart TIME,  -- btn départ
    heure_arrivee TIME  -- btn arrivée
);

--push :
-- mitady ny date izy ou séléctionne , ex: 10/11/24 
--> get select where (date = dateSelected) dans la table (poitage_usagers_mobile & durree_cars)
