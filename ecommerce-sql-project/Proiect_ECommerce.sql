
CREATE DATABASE ECommerceDB
GO

USE ECommerceDB
GO


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CATEGORII]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[CATEGORII]
GO

CREATE TABLE CATEGORII (
    IdCateg      int PRIMARY KEY IDENTITY,
    Denumire     varchar(100) NOT NULL,
    Descriere    varchar(255)
)
GO


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PRODUSE]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[PRODUSE]
GO

CREATE TABLE PRODUSE (
    IdProdus     int PRIMARY KEY IDENTITY,
    Denumire     varchar(150) NOT NULL,
    SKU          varchar(50)  NOT NULL UNIQUE,
    IdCateg      int NOT NULL,
    Pret         decimal(10,2) NOT NULL CHECK (Pret > 0),
    StocTotal    int NOT NULL DEFAULT 0 CHECK (StocTotal >= 0),
    DataAdaugare datetime2 DEFAULT SYSDATETIME()
)
GO


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DEPOZITE]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[DEPOZITE]
GO

CREATE TABLE DEPOZITE (
    IdDepozit    int PRIMARY KEY IDENTITY,
    Denumire     varchar(100) NOT NULL,
    Locatie      varchar(150)
)
GO


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[STOC_DEPOZIT]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[STOC_DEPOZIT]
GO

CREATE TABLE STOC_DEPOZIT (
    IdStoc       int PRIMARY KEY IDENTITY,
    IdProdus     int NOT NULL,
    IdDepozit    int NOT NULL,
    Cantitate    int NOT NULL DEFAULT 0 CHECK (Cantitate >= 0),
    CONSTRAINT UQ_ProdusDepozit UNIQUE (IdProdus, IdDepozit)
)
GO


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CLIENTI]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[CLIENTI]
GO

CREATE TABLE CLIENTI (
    IdClient     int PRIMARY KEY IDENTITY,
    NumeComplet  varchar(150) NOT NULL,
    Email        varchar(150) NOT NULL UNIQUE,
    Tara         varchar(80),
    DataInreg    datetime2 DEFAULT SYSDATETIME()
)
GO


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[COMENZI]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[COMENZI]
GO

CREATE TABLE COMENZI (
    IdComanda    int PRIMARY KEY IDENTITY,
    IdClient     int NOT NULL,
    DataComanda  datetime2 DEFAULT SYSDATETIME(),
    Status       varchar(30) NOT NULL DEFAULT 'In asteptare'
                     CHECK (Status IN ('In asteptare','Confirmata','Expediata','Anulata')),
    ValoareTotala decimal(12,2) DEFAULT 0
)
GO


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DETALII_COMANDA]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[DETALII_COMANDA]
GO

CREATE TABLE DETALII_COMANDA (
    IdDetaliu    int PRIMARY KEY IDENTITY,
    IdComanda    int NOT NULL,
    IdProdus     int NOT NULL,
    IdDepozit    int NOT NULL,    
    Cantitate    int NOT NULL CHECK (Cantitate > 0),
    PretUnitar   decimal(10,2) NOT NULL CHECK (PretUnitar > 0)
)
GO


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AUDIT_LOG]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[AUDIT_LOG]
GO

CREATE TABLE AUDIT_LOG (
    IdAudit        int PRIMARY KEY IDENTITY,
    Tabela         varchar(100) NOT NULL,
    Operatie       varchar(10)  NOT NULL,
    IdInregistrare int NOT NULL,
    ModificatDe    varchar(100) DEFAULT SYSTEM_USER,
    ModificatLa    datetime2    DEFAULT SYSDATETIME(),
    Observatii     varchar(500)
)

GO



ALTER TABLE PRODUSE
    ADD CONSTRAINT FK_PRODUSE_CATEGORII FOREIGN KEY (IdCateg)
    REFERENCES CATEGORII(IdCateg)
GO

ALTER TABLE STOC_DEPOZIT
    ADD CONSTRAINT FK_STOC_PRODUSE FOREIGN KEY (IdProdus)
    REFERENCES PRODUSE(IdProdus)
GO

ALTER TABLE STOC_DEPOZIT
    ADD CONSTRAINT FK_STOC_DEPOZITE FOREIGN KEY (IdDepozit)
    REFERENCES DEPOZITE(IdDepozit)
GO

ALTER TABLE COMENZI
    ADD CONSTRAINT FK_COMENZI_CLIENTI FOREIGN KEY (IdClient)
    REFERENCES CLIENTI(IdClient)
GO

ALTER TABLE DETALII_COMANDA
    ADD CONSTRAINT FK_DETALII_COMENZI FOREIGN KEY (IdComanda)
    REFERENCES COMENZI(IdComanda)
GO

ALTER TABLE DETALII_COMANDA
    ADD CONSTRAINT FK_DETALII_PRODUSE FOREIGN KEY (IdProdus)
    REFERENCES PRODUSE(IdProdus)
GO


ALTER TABLE DETALII_COMANDA
    ADD CONSTRAINT FK_DETALII_DEPOZITE FOREIGN KEY (IdDepozit)
    REFERENCES DEPOZITE(IdDepozit)
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


-------

-----
CREATE NONCLUSTERED INDEX IX_Produse_IdCateg
    ON PRODUSE (IdCateg)
    INCLUDE (Denumire, SKU, Pret, StocTotal)
GO

CREATE NONCLUSTERED INDEX IX_Produse_SKU
    ON PRODUSE (SKU)
    INCLUDE (Denumire, Pret, StocTotal)
GO

CREATE NONCLUSTERED INDEX IX_Comenzi_IdClient_Data
    ON COMENZI (IdClient, DataComanda DESC)
    INCLUDE (Status, ValoareTotala)
GO

CREATE NONCLUSTERED INDEX IX_Comenzi_Status
    ON COMENZI (Status)
    INCLUDE (IdClient, DataComanda, ValoareTotala)
GO

CREATE NONCLUSTERED INDEX IX_DetaliiComanda_IdComanda
    ON DETALII_COMANDA (IdComanda)
    INCLUDE (IdProdus, IdDepozit, Cantitate, PretUnitar)
GO

CREATE NONCLUSTERED INDEX IX_StocDepozit_IdProdus
    ON STOC_DEPOZIT (IdProdus)
    INCLUDE (IdDepozit, Cantitate)
GO



CREATE OR ALTER VIEW vw_CatalogProduse AS
SELECT
    p.IdProdus,
    p.Denumire                          AS NumeProdus,
    p.SKU,
    c.Denumire                          AS Categorie,
    p.Pret,
    p.StocTotal,
    CASE
        WHEN p.StocTotal = 0   THEN 'Stoc epuizat'
        WHEN p.StocTotal < 50  THEN 'Stoc redus'
        ELSE                        'In stoc'
    END                                 AS StatusStoc,
    p.DataAdaugare
FROM PRODUSE p
INNER JOIN CATEGORII c ON p.IdCateg = c.IdCateg
GO

CREATE OR ALTER VIEW vw_SumarComenzi AS
SELECT
    co.IdComanda,
    cl.NumeComplet                      AS NumeClient,
    cl.Email,
    cl.Tara,
    co.DataComanda,
    co.Status,
    co.ValoareTotala,
    COUNT(dc.IdDetaliu)                 AS NrProduse,
    SUM(dc.Cantitate)                   AS TotalBucati
FROM COMENZI co
INNER JOIN CLIENTI         cl ON co.IdClient  = cl.IdClient
LEFT  JOIN DETALII_COMANDA dc ON co.IdComanda = dc.IdComanda
GROUP BY co.IdComanda, cl.NumeComplet, cl.Email, cl.Tara,
         co.DataComanda, co.Status, co.ValoareTotala
GO

CREATE OR ALTER VIEW vw_VenituriPeCategorie AS
SELECT
    cat.Denumire                        AS Categorie,
    COUNT(DISTINCT co.IdComanda)        AS TotalComenzi,
    SUM(dc.Cantitate)                   AS BucatiVandute,
    SUM(dc.Cantitate * dc.PretUnitar)   AS VenitTotal,
    AVG(dc.PretUnitar)                  AS PretMediu
FROM DETALII_COMANDA dc
INNER JOIN PRODUSE    p   ON dc.IdProdus  = p.IdProdus
INNER JOIN CATEGORII  cat ON p.IdCateg    = cat.IdCateg
INNER JOIN COMENZI    co  ON dc.IdComanda = co.IdComanda
WHERE co.Status IN ('Confirmata', 'Expediata')
GROUP BY cat.Denumire
GO

CREATE OR ALTER VIEW vw_StocPeDepozite AS
SELECT
    p.Denumire                          AS Produs,
    p.SKU,
    d.Denumire                          AS Depozit,
    sd.Cantitate                        AS StocDepozit,
    p.StocTotal                         AS StocGlobal,
    CAST(
        100.0 * sd.Cantitate / NULLIF(p.StocTotal, 0)
        AS decimal(5,1))                AS ProcentDinTotal
FROM STOC_DEPOZIT sd
INNER JOIN PRODUSE  p ON sd.IdProdus  = p.IdProdus
INNER JOIN DEPOZITE d ON sd.IdDepozit = d.IdDepozit
GO


CREATE OR ALTER TRIGGER trg_Comenzi_DupaInsert
ON COMENZI
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON
    INSERT INTO AUDIT_LOG (Tabela, Operatie, IdInregistrare, Observatii)
    SELECT
        'COMENZI', 'INSERT', i.IdComanda,
        'Comanda noua | Client: ' + CAST(i.IdClient AS varchar)
          + ' | Status: ' + i.Status
          + ' | Valoare: ' + CAST(i.ValoareTotala AS varchar)
    FROM inserted i
END
GO


CREATE OR ALTER TRIGGER trg_Comenzi_DupaUpdate
ON COMENZI
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO AUDIT_LOG (Tabela, Operatie, IdInregistrare, Observatii)
    SELECT
        'COMENZI',
        'UPDATE',
        i.IdComanda,
        CONCAT(
            IIF(i.Status <> d.Status,
                CONCAT('Status: [', d.Status, '] -> [', i.Status, ']'),
                ''
            ),
            IIF(i.Status <> d.Status AND i.ValoareTotala <> d.ValoareTotala,
                ' | ',
                ''
            ),
            IIF(i.ValoareTotala <> d.ValoareTotala,
                CONCAT('Valoare: ', CAST(d.ValoareTotala AS varchar(30)),
                       ' -> ', CAST(i.ValoareTotala AS varchar(30))),
                ''
            )
        ) AS Observatii
    FROM inserted i
    INNER JOIN deleted d ON i.IdComanda = d.IdComanda
    WHERE i.Status <> d.Status OR i.ValoareTotala <> d.ValoareTotala;
END
GO



CREATE OR ALTER TRIGGER trg_Produse_InLocDeSterge
ON PRODUSE
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON


    IF EXISTS (
        SELECT 1 FROM DETALII_COMANDA dc
        INNER JOIN deleted d ON dc.IdProdus = d.IdProdus
    )
    BEGIN
        RAISERROR('Nu se poate sterge produsul: exista comenzi asociate. Dezactiveaza produsul in loc sa il stergi.', 16, 1)
        RETURN
    END

    DELETE sd
    FROM STOC_DEPOZIT sd
    INNER JOIN deleted d ON sd.IdProdus = d.IdProdus


    DELETE p
    FROM PRODUSE p
    INNER JOIN deleted d ON p.IdProdus = d.IdProdus

    INSERT INTO AUDIT_LOG (Tabela, Operatie, IdInregistrare, Observatii)
    SELECT 'PRODUSE', 'DELETE', d.IdProdus,
           'Produs sters: ' + d.Denumire + ' (stocuri depozite sterse cascadat)'
    FROM deleted d
END
GO


CREATE OR ALTER TRIGGER trg_DetaliiComanda_ActualizeazaTotal
ON DETALII_COMANDA
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @ComenziAfectate TABLE (IdComanda int PRIMARY KEY)

    INSERT INTO @ComenziAfectate
    SELECT DISTINCT IdComanda FROM inserted
    UNION
    SELECT DISTINCT IdComanda FROM deleted

    UPDATE co
    SET ValoareTotala = ISNULL((
        SELECT SUM(Cantitate * PretUnitar)
        FROM DETALII_COMANDA
        WHERE IdComanda = co.IdComanda
    ), 0)
    FROM COMENZI co
    INNER JOIN @ComenziAfectate ca ON co.IdComanda = ca.IdComanda
END
GO

CREATE OR ALTER TRIGGER trg_DetaliiComanda_ValidarePret
ON DETALII_COMANDA
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON

    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN PRODUSE p ON i.IdProdus = p.IdProdus
        WHERE ABS(i.PretUnitar - p.Pret) > 0.01
    )
    BEGIN
        RAISERROR('PretUnitar nu corespunde pretului curent din catalog. Foloseste procedura usp_PlaseazaComanda.', 16, 1)
        ROLLBACK TRANSACTION
        RETURN
    END
END
GO

CREATE OR ALTER TRIGGER trg_StocDepozit_DupaUpdate
ON STOC_DEPOZIT
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON
    INSERT INTO AUDIT_LOG (Tabela, Operatie, IdInregistrare, Observatii)
    SELECT
        'STOC_DEPOZIT', 'UPDATE', i.IdStoc,
        'Produs ' + CAST(i.IdProdus AS varchar)
          + ' | Depozit ' + CAST(i.IdDepozit AS varchar)
          + ' | Cantitate: ' + CAST(d.Cantitate AS varchar)
          + ' -> ' + CAST(i.Cantitate AS varchar)
    FROM inserted i
    INNER JOIN deleted d ON i.IdStoc = d.IdStoc
    WHERE i.Cantitate <> d.Cantitate
END
GO


CREATE OR ALTER PROCEDURE usp_PlaseazaComanda
    @IdClient   int,
    @IdProdus   int,
    @Cantitate  int,
    @IdDepozit  int
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @PretUnitar     decimal(10,2)
    DECLARE @IdComandaNoua  int

    BEGIN TRY
        BEGIN TRANSACTION

      
        SELECT @PretUnitar = p.Pret
        FROM PRODUSE p WITH (UPDLOCK, ROWLOCK)
        WHERE p.IdProdus = @IdProdus

        IF @PretUnitar IS NULL
        BEGIN
            RAISERROR('Produsul %d nu exista.', 16, 1, @IdProdus)
            ROLLBACK TRANSACTION
            RETURN
        END

   
        UPDATE STOC_DEPOZIT
        SET    Cantitate = Cantitate - @Cantitate
        WHERE  IdProdus  = @IdProdus
          AND  IdDepozit = @IdDepozit
          AND  Cantitate >= @Cantitate   

        IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR('Stoc insuficient sau depozitul %d nu contine produsul %d.',
                      16, 1, @IdDepozit, @IdProdus)
            ROLLBACK TRANSACTION;
            RETURN
        END


        UPDATE PRODUSE
        SET    StocTotal = StocTotal - @Cantitate
        WHERE  IdProdus  = @IdProdus

 
        INSERT INTO COMENZI (IdClient, Status, ValoareTotala)
        VALUES (@IdClient, 'Confirmata', 0)
        SET @IdComandaNoua = SCOPE_IDENTITY()

   
        INSERT INTO DETALII_COMANDA (IdComanda, IdProdus, IdDepozit, Cantitate, PretUnitar)
        VALUES (@IdComandaNoua, @IdProdus, @IdDepozit, @Cantitate, @PretUnitar)

        COMMIT TRANSACTION

        SELECT
            @IdComandaNoua           AS IdComandaNoua,
            @Cantitate               AS CantitateComandata,
            @PretUnitar              AS PretUnitar,
            @Cantitate * @PretUnitar AS ValoareTotala

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO


CREATE OR ALTER PROCEDURE usp_AnuleazaComanda
    @IdComanda int
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @StatusCurent varchar(30)

    BEGIN TRY
        BEGIN TRANSACTION

      
        SELECT @StatusCurent = Status
        FROM   COMENZI WITH (XLOCK, ROWLOCK)
        WHERE  IdComanda = @IdComanda

        IF @StatusCurent IS NULL
        BEGIN
            RAISERROR('Comanda %d nu exista.', 16, 1, @IdComanda)
            ROLLBACK TRANSACTION
            RETURN
        END

        IF @StatusCurent IN ('Expediata', 'Anulata')
        BEGIN
            RAISERROR('Nu se poate anula o comanda cu statusul: %s.', 16, 1, @StatusCurent)
            ROLLBACK TRANSACTION
            RETURN
        END


        UPDATE sd
        SET    sd.Cantitate = sd.Cantitate + dc.Cantitate
        FROM   STOC_DEPOZIT sd
        INNER JOIN DETALII_COMANDA dc
               ON  sd.IdProdus  = dc.IdProdus
               AND sd.IdDepozit = dc.IdDepozit   
        WHERE  dc.IdComanda = @IdComanda

       
        UPDATE p
        SET    p.StocTotal = p.StocTotal + dc.Cantitate
        FROM   PRODUSE p
        INNER JOIN DETALII_COMANDA dc ON p.IdProdus = dc.IdProdus
        WHERE  dc.IdComanda = @IdComanda

      
        UPDATE COMENZI SET Status = 'Anulata' WHERE IdComanda = @IdComanda

        COMMIT TRANSACTION

        SELECT @IdComanda AS IdComandaAnulata, 'Anulata' AS StatusNou

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO


CREATE OR ALTER PROCEDURE usp_SchimbaStatusComanda
    @IdComanda  int,
    @StatusNou  varchar(30)
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @StatusCurent varchar(30)

    BEGIN TRY
        BEGIN TRANSACTION

        SELECT @StatusCurent = Status
        FROM   COMENZI WITH (XLOCK, ROWLOCK)
        WHERE  IdComanda = @IdComanda

        IF @StatusCurent IS NULL
        BEGIN
            RAISERROR('Comanda %d nu exista.', 16, 1, @IdComanda)
            ROLLBACK TRANSACTION
            RETURN
        END

       IF NOT (
    (@StatusCurent = 'In asteptare' AND @StatusNou IN ('Confirmata', 'Anulata'))
 OR (@StatusCurent = 'Confirmata'   AND @StatusNou IN ('Expediata',  'Anulata'))
)
BEGIN
    DECLARE @msg nvarchar(2048) =
        CONCAT(
            'Tranzitie invalida: [', @StatusCurent, '] -> [', @StatusNou, ']. ',
            'Tranzitii permise: ',
            '"In asteptare"->Confirmata/Anulata, ',
            '"Confirmata"->Expediata/Anulata.'
        );

    RAISERROR('%s', 16, 1, @msg);
    ROLLBACK TRANSACTION;
    RETURN;
END

        UPDATE COMENZI SET Status = @StatusNou WHERE IdComanda = @IdComanda

        COMMIT TRANSACTION

        SELECT @IdComanda AS IdComanda, @StatusCurent AS StatusVechi, @StatusNou AS StatusNou

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO


CREATE OR ALTER PROCEDURE usp_RaportStoc
AS
BEGIN
    SET NOCOUNT ON

    SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
    BEGIN TRANSACTION

        SELECT
            p.IdProdus,
            p.Denumire              AS Produs,
            p.SKU,
            c.Denumire              AS Categorie,
            p.Pret,
            p.StocTotal             AS StocGlobal,
            SUM(sd.Cantitate)       AS TotalDepozite,
            SYSDATETIME()           AS DataRaport
        FROM PRODUSE p WITH (HOLDLOCK)
        INNER JOIN CATEGORII    c  ON p.IdCateg   = c.IdCateg
        INNER JOIN STOC_DEPOZIT sd ON p.IdProdus  = sd.IdProdus
        GROUP BY p.IdProdus, p.Denumire, p.SKU,
                 c.Denumire, p.Pret, p.StocTotal
        ORDER BY c.Denumire, p.Denumire

    COMMIT TRANSACTION
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED
END
GO


CREATE OR ALTER PROCEDURE usp_ReaprovizionareDepozite
    @IdProdus  int,
    @CantiD1   int = 0,
    @CantiD2   int = 0,
    @CantiD3   int = 0
AS
BEGIN
    SET NOCOUNT ON

    BEGIN TRY
        BEGIN TRANSACTION Reaprovizionare

        SAVE TRANSACTION SaveD1
        IF EXISTS (SELECT 1 FROM STOC_DEPOZIT WHERE IdProdus=@IdProdus AND IdDepozit=1)
            UPDATE STOC_DEPOZIT SET Cantitate = Cantitate + @CantiD1
            WHERE  IdProdus=@IdProdus AND IdDepozit=1
        ELSE
            INSERT INTO STOC_DEPOZIT(IdProdus, IdDepozit, Cantitate)
            VALUES (@IdProdus, 1, @CantiD1)

        SAVE TRANSACTION SaveD2
        IF EXISTS (SELECT 1 FROM STOC_DEPOZIT WHERE IdProdus=@IdProdus AND IdDepozit=2)
            UPDATE STOC_DEPOZIT SET Cantitate = Cantitate + @CantiD2
            WHERE  IdProdus=@IdProdus AND IdDepozit=2
        ELSE
            INSERT INTO STOC_DEPOZIT(IdProdus, IdDepozit, Cantitate)
            VALUES (@IdProdus, 2, @CantiD2)

        SAVE TRANSACTION SaveD3
        IF EXISTS (SELECT 1 FROM STOC_DEPOZIT WHERE IdProdus=@IdProdus AND IdDepozit=3)
            UPDATE STOC_DEPOZIT SET Cantitate = Cantitate + @CantiD3
            WHERE  IdProdus=@IdProdus AND IdDepozit=3
        ELSE
            INSERT INTO STOC_DEPOZIT(IdProdus, IdDepozit, Cantitate)
            VALUES (@IdProdus, 3, @CantiD3)

        UPDATE PRODUSE
        SET    StocTotal = (
                   SELECT SUM(Cantitate) FROM STOC_DEPOZIT
                   WHERE IdProdus = @IdProdus
               )
        WHERE  IdProdus = @IdProdus

        COMMIT TRANSACTION Reaprovizionare

        SELECT
            p.Denumire              AS Produs,
            p.StocTotal             AS StocGlobalActualizat,
            d.Denumire              AS Depozit,
            sd.Cantitate            AS StocDepozit
        FROM PRODUSE p
        INNER JOIN STOC_DEPOZIT sd ON p.IdProdus   = sd.IdProdus
        INNER JOIN DEPOZITE     d  ON sd.IdDepozit = d.IdDepozit
        WHERE p.IdProdus = @IdProdus

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE usp_IstoricClient
    @IdClient int
AS
BEGIN
    SET NOCOUNT ON

    SELECT
        co.IdComanda,
        co.DataComanda,
        co.Status,
        co.ValoareTotala,
        COUNT(dc.IdDetaliu)             AS NrLinii,
        SUM(dc.Cantitate)               AS TotalBucati,
        STRING_AGG(p.Denumire, ', ')    AS Produse
    FROM COMENZI co
    INNER JOIN CLIENTI         cl ON co.IdClient  = cl.IdClient
    LEFT  JOIN DETALII_COMANDA dc ON co.IdComanda = dc.IdComanda
    LEFT  JOIN PRODUSE          p  ON dc.IdProdus  = p.IdProdus
    WHERE co.IdClient = @IdClient
    GROUP BY co.IdComanda, co.DataComanda, co.Status, co.ValoareTotala
    ORDER BY co.DataComanda DESC
END
GO

SELECT * FROM vw_CatalogProduse ORDER BY Categorie, Pret DESC
GO

SELECT
    p.Denumire                                          AS Produs,
    p.SKU,
    c.Denumire                                          AS Categorie,
    d.Denumire                                          AS Depozit,
    sd.Cantitate                                        AS StocDepozit,
    p.StocTotal                                         AS StocGlobal,
    SUM(sd.Cantitate) OVER (PARTITION BY p.IdProdus)    AS SumaDepozite
FROM STOC_DEPOZIT sd
INNER JOIN PRODUSE    p  ON sd.IdProdus  = p.IdProdus
INNER JOIN CATEGORII  c  ON p.IdCateg    = c.IdCateg
INNER JOIN DEPOZITE   d  ON sd.IdDepozit = d.IdDepozit
ORDER BY p.Denumire, d.Denumire
GO

SELECT
    p.Denumire      AS Produs,
    p.SKU,
    c.Denumire      AS Categorie,
    p.StocTotal
FROM PRODUSE p
INNER JOIN CATEGORII       c  ON p.IdCateg  = c.IdCateg
LEFT  JOIN DETALII_COMANDA dc ON p.IdProdus = dc.IdProdus
WHERE dc.IdDetaliu IS NULL
GO

SELECT TOP 5
    cl.NumeComplet,
    cl.Tara,
    COUNT(DISTINCT co.IdComanda)    AS TotalComenzi,
    SUM(co.ValoareTotala)           AS ValoareTotalaCheltuta,
    AVG(co.ValoareTotala)           AS ValoareMedieComanda
FROM CLIENTI cl
INNER JOIN COMENZI co ON cl.IdClient = co.IdClient
WHERE co.Status <> 'Anulata'
GROUP BY cl.NumeComplet, cl.Tara
ORDER BY ValoareTotalaCheltuta DESC
GO

SELECT * FROM vw_VenituriPeCategorie ORDER BY VenitTotal DESC
GO

EXEC usp_PlaseazaComanda @IdClient=1, @IdProdus=1, @Cantitate=2, @IdDepozit=1
EXEC usp_PlaseazaComanda @IdClient=2, @IdProdus=4, @Cantitate=1, @IdDepozit=2
EXEC usp_PlaseazaComanda @IdClient=3, @IdProdus=6, @Cantitate=3, @IdDepozit=1
GO

EXEC usp_SchimbaStatusComanda @IdComanda=2, @StatusNou='Expediata'
GO

GO

EXEC usp_AnuleazaComanda @IdComanda=1
GO

EXEC usp_RaportStoc
GO

EXEC usp_ReaprovizionareDepozite @IdProdus=1, @CantiD1=50, @CantiD2=40, @CantiD3=30
GO

EXEC usp_IstoricClient @IdClient=2
GO

SELECT * FROM AUDIT_LOG ORDER BY ModificatLa DESC
GO

SELECT * FROM vw_StocPeDepozite ORDER BY Produs, Depozit
GO

