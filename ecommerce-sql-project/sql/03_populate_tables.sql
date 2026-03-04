

USE ECommerceDB
GO


INSERT INTO CATEGORII(Denumire, Descriere) VALUES ('Electronice', 'Telefoane, tablete si accesorii')
INSERT INTO CATEGORII(Denumire, Descriere) VALUES ('Imbracaminte', 'Haine pentru toate varstele')
INSERT INTO CATEGORII(Denumire, Descriere) VALUES ('Casa si Bucatarie', 'Mobila, electrocasnice si decor')
INSERT INTO CATEGORII(Denumire, Descriere) VALUES ('Sport', 'Echipamente outdoor si fitness')
INSERT INTO CATEGORII(Denumire, Descriere) VALUES ('Carti', 'Fictiune, non-fictiune si educationale')
GO


INSERT INTO DEPOZITE(Denumire, Locatie) VALUES ('Depozit Central', 'Cluj-Napoca')
INSERT INTO DEPOZITE(Denumire, Locatie) VALUES ('Depozit Nord', 'Oradea')
INSERT INTO DEPOZITE(Denumire, Locatie) VALUES ('Depozit Sud', 'Bucuresti')
GO


INSERT INTO PRODUSE(Denumire, SKU, IdCateg, Pret, StocTotal) VALUES ('Casti Wireless Pro', 'ELEC-CWP-001', 1, 149.99, 300)
INSERT INTO PRODUSE(Denumire, SKU, IdCateg, Pret, StocTotal) VALUES ('Suport Smartphone Deluxe', 'ELEC-SSD-002', 1, 29.99, 500)
INSERT INTO PRODUSE(Denumire, SKU, IdCateg, Pret, StocTotal) VALUES ('Geaca Alergare WindStop', 'IMB-GAW-001', 2, 89.99, 200)
INSERT INTO PRODUSE(Denumire, SKU, IdCateg, Pret, StocTotal) VALUES ('Salteluta Yoga Premium', 'SPT-SYP-001', 4, 49.99, 350)
INSERT INTO PRODUSE(Denumire, SKU, IdCateg, Pret, StocTotal) VALUES ('Set Cutite Bucatarie 8 piese', 'CAS-SCB-001', 3, 119.99, 150)
INSERT INTO PRODUSE(Denumire, SKU, IdCateg, Pret, StocTotal) VALUES ('Invata SQL in 30 de Zile', 'CAR-SQL-001', 5, 34.99, 400)
INSERT INTO PRODUSE(Denumire, SKU, IdCateg, Pret, StocTotal) VALUES ('Boxa Bluetooth Compacta', 'ELEC-BBC-003', 1, 79.99, 250)
INSERT INTO PRODUSE(Denumire, SKU, IdCateg, Pret, StocTotal) VALUES ('Rucsac Trekking 45L', 'SPT-RT-002', 4, 159.99, 180)
GO


INSERT INTO STOC_DEPOZIT(IdProdus, IdDepozit, Cantitate) VALUES (1,1,120),(1,2,100),(1,3,80)
INSERT INTO STOC_DEPOZIT(IdProdus, IdDepozit, Cantitate) VALUES (2,1,200),(2,2,180),(2,3,120)
INSERT INTO STOC_DEPOZIT(IdProdus, IdDepozit, Cantitate) VALUES (3,1,80), (3,2,70), (3,3,50)
INSERT INTO STOC_DEPOZIT(IdProdus, IdDepozit, Cantitate) VALUES (4,1,140),(4,2,120),(4,3,90)
INSERT INTO STOC_DEPOZIT(IdProdus, IdDepozit, Cantitate) VALUES (5,1,60), (5,2,50), (5,3,40)
INSERT INTO STOC_DEPOZIT(IdProdus, IdDepozit, Cantitate) VALUES (6,1,160),(6,2,140),(6,3,100)
INSERT INTO STOC_DEPOZIT(IdProdus, IdDepozit, Cantitate) VALUES (7,1,100),(7,2,90), (7,3,60)
INSERT INTO STOC_DEPOZIT(IdProdus, IdDepozit, Cantitate) VALUES (8,1,70), (8,2,60), (8,3,50)
GO


INSERT INTO CLIENTI(NumeComplet, Email, Tara) VALUES ('Alice Martin', 'alice.martin@email.com', 'Romania')
INSERT INTO CLIENTI(NumeComplet, Email, Tara) VALUES ('Bob Tanaka', 'bob.tanaka@email.jp', 'Japonia')
INSERT INTO CLIENTI(NumeComplet, Email, Tara) VALUES ('Clara Ionescu', 'clara.ionescu@email.ro', 'Romania')
INSERT INTO CLIENTI(NumeComplet, Email, Tara) VALUES ('David Okonkwo', 'david.ok@email.ng', 'Nigeria')
INSERT INTO CLIENTI(NumeComplet, Email, Tara) VALUES ('Emma Schneider', 'emma.s@email.de', 'Germania')
GO