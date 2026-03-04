
USE ECommerceDB
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
    SET NOCOUNT ON

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
    WHERE i.Status <> d.Status OR i.ValoareTotala <> d.ValoareTotala
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