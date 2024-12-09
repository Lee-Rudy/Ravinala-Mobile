-- CREATE TABLE pointage_usagers_mobile (
--     id INTEGER PRIMARY KEY,
--     cars_mobile_id INTEGER,
--     usagers_mobile_id INTEGER,
--     heure_pointage TIME,
--     date_pointage DATE,
--     FOREIGN KEY (cars_mobile_id) REFERENCES cars_mobile(id),
--     FOREIGN KEY (usagers_mobile_id) REFERENCES usagers_mobile(id)
-- );

--get liste cars api 
create table cars
(
    id integer primary key,
    nom_car text
);
insert into cars(nom_car) values ('car1'),('car2'),('car3');

CREATE TABLE planning_ramassage 
(
    id integer primary key,
    idUsagers integer,
    matricule TEXT,
    nomUsager TEXT,
    nom_axe TEXT,
    nomVoiture TEXT,
    fokontany TEXT,
    lieu TEXT,
    heure time
);

-- ALTER TABLE planning_ramassage ADD COLUMN prenom_usager TEXT;


CREATE TABLE planning_depot 
(
    id integer primary key,
    idUsagers integer,
    matricule TEXT,
    nomUsager TEXT,
    nom_axe TEXT,
    nomVoiture TEXT,
    fokontany TEXT,
    lieu TEXT,
    heure time
);

-- ALTER TABLE planning_ramassage ADD COLUMN prenom_usager TEXT;

create table pointage_ramassage
(
    id integer primary key,
    matricule text,
    nomUsager text, --nomUsager
    nomVoiture text,
    datetime_ramassage text,
    est_present integer default 0 -- 0: absent,  1: présent
);

create table pointage_depot
(
    id integer primary key,
    matricule text,
    nomUsager text,
    nomVoiture text,
    datetime_depot text,
    est_present integer default 0 -- 0: absent,  1: présent
);

--check btn
--info : btn + pointage ram/depot (session)
-- atao clic btn anakiray d zay vao lasa miaraka ilay information
create table btn
(
    id integer primary key,
    datetime_depart text,
    datetime_arrivee text,
    nomVoiture text,
    motif text
);

--insertion direct
create table pointage_usagers_imprevu
(
    id integer primary KEY,
    matricule text,
    nom text,
    datetime_imprevu text,
    nomVoiture text
);
--new
create table km_matin
(
    id integer primary key,
    depart text,
    fin text,
    nomVoiture text,
    datetime_matin text
);

create table km_soir
(
    id integer primary key,
    depart text,
    fin text,
    nomVoiture text,
    datetime_soir text
);



--  drop table pointage_usagers_imprevu;
--  drop table pointage_ramassage;
--  drop table pointage_depot;
--  drop table planning_depot;
--  drop table planning_ramassage;
--  drop table btn;
--  drop table cars;
-- drop table km_matin;
-- drop table km_soir;