

USE ECommerceDB
GO


CREATE OR ALTER PROCEDURE usp_PlaseazaComanda
    @IdClient   int,
    @IdProdus   int,
    @Cantitate  int,
    @IdDepozit  int
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @PretUnitar    decimal(10,2)
    DECLARE @IdComandaNoua int

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
            ROLLBACK TRANSACTION
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
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
        THROW
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
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
        THROW
    END CATCH
END
GO


CREATE OR ALTER PROCEDURE usp_SchimbaStatusComanda
    @IdComanda int,
    @StatusNou varchar(30)
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
                )
            RAISERROR('%s', 16, 1, @msg)
            ROLLBACK TRANSACTION
            RETURN
        END

        UPDATE COMENZI SET Status = @StatusNou WHERE IdComanda = @IdComanda

        COMMIT TRANSACTION

        SELECT @IdComanda AS IdComanda, @StatusCurent AS StatusVechi, @StatusNou AS StatusNou

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
        THROW
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
        INNER JOIN CATEGORII    c  ON p.IdCateg  = c.IdCateg
        INNER JOIN STOC_DEPOZIT sd ON p.IdProdus = sd.IdProdus
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
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
        THROW
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