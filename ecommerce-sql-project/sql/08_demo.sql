
USE ECommerceDB
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


SELECT * FROM vw_SumarComenzi ORDER BY DataComanda DESC
GO