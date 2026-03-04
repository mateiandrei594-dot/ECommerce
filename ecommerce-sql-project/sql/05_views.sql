
USE ECommerceDB
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