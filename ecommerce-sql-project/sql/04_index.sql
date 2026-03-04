
USE ECommerceDB
GO


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