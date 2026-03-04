
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
    IdComanda     int PRIMARY KEY IDENTITY,
    IdClient      int NOT NULL,
    DataComanda   datetime2 DEFAULT SYSDATETIME(),
    Status        varchar(30) NOT NULL DEFAULT 'In asteptare'
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
