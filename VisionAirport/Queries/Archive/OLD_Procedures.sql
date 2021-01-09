-- Drop the CleanseExportAankomst Procedure in case it already exists
Drop Procedure IF EXISTS CleanseExportAankomst
GO
-- CleanseExportAankomst procedure will create a new table in the schema cleansed if it doesn't exist and fill it with cleansed values.
CREATE PROCEDURE CleanseExportAankomst
AS
BEGIN
	SET ANSI_NULLS ON;

	SET QUOTED_IDENTIFIER ON;

	DROP TABLE IF EXISTS [VisionAirport_OLTP].[CLEANSED].[export_aankomst];

	CREATE TABLE VisionAirport_OLTP.[CLEANSED].[export_aankomst](
		[Vluchtid] BIGINT NOT NULL PRIMARY KEY,
		[Vliegtuigcode] [varchar](10) NOT NULL,
		[Terminal] [char](1) NULL,
		[Gate] [char](2) NULL,
		[Baan] [INT] NULL,
		[Bezetting] [INT] NULL,
		[Vracht] [INT] NULL,
		[Aankomsttijd] [DATETIME] NULL
	) ON [PRIMARY];
	
	INSERT INTO VisionAirport_OLTP.[CLEANSED].export_aankomst 
	SELECT 
		CAST(CAST(REPLACE(vluchtid, ',', '.') AS FLOAT) AS BIGINT), -- Important because some fields are written in scientific notation with "," instead of "."
		CAST(VliegtuigCode AS VARCHAR(10)), 
		CAST(Terminal AS CHAR(1)), 
		NULLIF(CAST(Gate AS CHAR(2)),''), 
		CAST(Baan AS INT), 
		CAST(Bezetting AS INT), 
		CAST(Vracht AS INT), 
		CAST(AankomstTijd AS DATETIME)
	FROM 
		VisionAirport_OLTP.[RAW].export_aankomst
END
GO



-- Drop the CleanseExportVliegtuig Procedure in case it already exists
Drop Procedure IF EXISTS CleanseExportVliegtuig
GO
CREATE PROCEDURE CleanseExportVliegtuig
AS
BEGIN
	SET ANSI_NULLS ON;

	SET QUOTED_IDENTIFIER ON;

	DROP TABLE IF EXISTS [VisionAirport_OLTP].[CLEANSED].[export_vliegtuig];

	CREATE TABLE VisionAirport_OLTP.[CLEANSED].[export_vliegtuig](
		[VliegtuigKey] [INT] IDENTITY(1,1) NOT NULL,
		[VliegtuigtypeKey] [INT] NOT NULL,
		[MaatschappijKEY] [INT] NOT NULL,
		[VliegtuigCode] VARCHAR(10) NOT NULL,
		[AirlineCode] VARCHAR(5) NULL,
		[Bouwjaar] [INT] NULL,
		PRIMARY KEY ([VliegtuigKey]),
		FOREIGN KEY ([VliegtuigtypeKey]) REFERENCES [VisionAirport_OLTP].[CLEANSED].[export_vliegtuigtype]([VliegtuigtypeKey]),
	) ON [PRIMARY];
	
	INSERT INTO VisionAirport_OLTP.[CLEANSED].[export_vliegtuig] 
	SELECT
		(SELECT VliegtuigTypeKey FROM [VisionAirport_OLTP].[CLEANSED].[export_vliegtuigtype] AS VT WHERE V.VLIEGTUIGTYPE = VT.IATA),
		NULLIF(CAST(VliegtuigCode AS VARCHAR(10)),''),
		NULLIF(NULLIF(CAST(AirlineCode AS VARCHAR(5)),''), '-'), 
		CAST(NULLIF(Bouwjaar, '') AS INT)
	FROM 
		VisionAirport_OLTP.[RAW].[export_vliegtuig] AS V
END
GO

-- Drop the CleanseExportVliegtuigType Procedure in case it already exists
Drop Procedure IF EXISTS CleanseExportVliegtuigType
GO
CREATE PROCEDURE CleanseExportVliegtuigType
AS
BEGIN
	SET ANSI_NULLS ON;

	SET QUOTED_IDENTIFIER ON;

	DROP TABLE IF EXISTS [VisionAirport_OLTP].[CLEANSED].[export_vliegtuig];
	DROP TABLE IF EXISTS [VisionAirport_OLTP].[CLEANSED].[export_vliegtuigtype];

	CREATE TABLE VisionAirport_OLTP.[CLEANSED].[export_vliegtuigtype](
		[VliegtuigTypeKey] [INT] IDENTITY(1,1) NOT NULL,
		[IATA] CHAR(3) NOT NULL,
		[ICAO] CHAR(4) NULL,
		[MERK] VARCHAR(50) NULL,
		[TYPE] VARCHAR(100) NULL,
		[Wake] CHAR(1) NULL,
		[Cat] VARCHAR(50) NULL,
		[Capaciteit] [INT] NULL,
		[Vracht] [INT] NULL,
		PRIMARY KEY (VliegtuigTypeKey)
	) ON [PRIMARY];
	
	INSERT INTO VisionAirport_OLTP.[CLEANSED].[export_vliegtuigtype]
	SELECT
		NULLIF(CAST(IATA AS CHAR(3)),''), 
		CAST(NULLIF(NULLIF(ICAO, ''), 'n/a') AS CHAR(4)), -- check on two expressions
		NULLIF(CAST(MERK AS VARCHAR(50)),''),
		NULLIF(CAST(TYPE AS VARCHAR(100)),''),
		CAST(NULLIF(NULLIF(WAKE, ''), 'n/a') AS CHAR(1)), -- check on two expressions
		NULLIF(CAST(CAT AS VARCHAR(50)), ''),
		CAST(NULLIF(Capaciteit, '') AS INT),
		CAST(NULLIF(Vracht, '') AS INT)
	FROM 
		VisionAirport_OLTP.[RAW].[export_vliegtuigtype]
END
GO

USE [VisionAirport_OLTP]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Drop the CleanseExportVertrek Procedure in case it already exists
Drop Procedure IF EXISTS CleanseExportVertrek
GO
CREATE PROCEDURE [dbo].[CleanseExportVertrek]
AS
BEGIN
	DROP TABLE IF EXISTS [VisionAirport_OLTP].[CLEANSED].[export_vertrek];

	CREATE TABLE VisionAirport_OLTP.[CLEANSED].[export_vertrek](
		[Vluchtid] BIGINT NOT NULL,
		[Vliegtuigcode] [varchar](10) NOT NULL,
		[Terminal] [char](1) NULL,
		[Gate] [char](2) NULL,
		[Baan] [INT] NULL,
		[Bezetting] [INT] NULL,
		[Vracht] [INT] NULL,
		[Vertrektijd] [DATETIME] NULL
	) ON [PRIMARY];
	
	INSERT INTO VisionAirport_OLTP.[CLEANSED].export_vertrek 
	SELECT 
		CAST(CAST(REPLACE(Vluchtid, ',', '.') AS FLOAT) AS BIGINT),
		CAST(VliegtuigCode AS VARCHAR(10)), 
		NULLIF(CAST(Terminal AS CHAR(1)), ''), 
		NULLIF(CAST(Gate AS CHAR(2)),''), 
		CAST(NULLIF(Baan, '') AS INT), 
		CAST(NULLIF(Bezetting, '') AS INT), 
		CAST(NULLIF(Vracht, '') AS INT), 
		CAST(VertrekTijd AS DATETIME)
	FROM 
		VisionAirport_OLTP.[RAW].export_vertrek
END


-- Drop the CleanseExportMaatschappijen Procedure in case it already exists
Drop Procedure IF EXISTS CleanseExportMaatschappijen
GO
CREATE PROCEDURE [dbo].[CleanseExportMaatschappijen]
AS
BEGIN
	DROP TABLE IF EXISTS [VisionAirport_OLTP].[CLEANSED].[export_maatschappijen];
	CREATE TABLE [VisionAirport_OLTP].[CLEANSED].[export_maatschappijen] (
		[Name] varchar(50) NOT NULL,
		[IATA] varchar(2) NOT NULL,
		[ICAO] varchar(3) NOT NULL
		PRIMARY KEY(Name, IATA, ICAO)
	);

	INSERT INTO [VisionAirport_OLTP].[CLEANSED].[export_maatschappijen]
		SELECT 
			CAST(Name AS varchar(50)),
			CAST(IATA AS varchar(2)), 
			CAST(ICAO AS varchar(3))
		FROM [VisionAirport_OLTP].[RAW].[export_maatschappijen];
END

CREATE PROCEDURE CleanseExportWeer
AS
BEGIN
	DROP TABLE IF EXISTS [VisionAirport_OLTP].[CLEANSED].[export_weer];

	CREATE TABLE VisionAirport_OLTP.[CLEANSED].[export_weer](
		[Datum] [DATETIME] NOT NULL PRIMARY KEY,
		[DDVEC] [INT] NOT NULL,
		[FHVEC] [INT] NOT NULL,
		[FG] [INT] NOT NULL,
		[FHX] [INT] NOT NULL,
		[FHXH] [INT] NOT NULL,
		[FHN] [INT] NOT NULL,
		[FHNH] [INT] NOT NULL,
		[FXX] [INT] NOT NULL,
		[FXXH] [INT] NOT NULL,
		[TG] [INT] NOT NULL,
		[TN] [INT] NOT NULL,
		[TNH] [INT] NOT NULL,
		[TX] [INT] NOT NULL,
		[TXH] [INT] NOT NULL,
	    [T10N] [INT] NOT NULL,
	    [T10NH] [INT] NOT NULL,
		[SQ] [INT] NOT NULL,
		[SP] [INT] NOT NULL,
		[Q] [INT] NOT NULL,
		[DR] [INT] NOT NULL,
		[RH] [INT] NOT NULL,
		[RHX] [INT] NOT NULL,
		[RHXH] [INT] NOT NULL,
		[PG] [INT] NOT NULL,
		[PX] [INT] NOT NULL,
		[PXH] [INT] NOT NULL,
		[PN] [INT] NOT NULL,
		[PNH] [INT] NOT NULL,
		[VVN] [INT] NOT NULL,
		[VVNH] [INT] NOT NULL,
		[VVX] [INT] NOT NULL,
		[VVXH] [INT] NOT NULL,
		[NG] [INT] NOT NULL,
		[UG] [INT] NOT NULL,
		[UX] [INT] NOT NULL,
		[UXH] [INT] NOT NULL,
		[UN] [INT] NOT NULL,
		[UNH] [INT] NOT NULL,
		[EV2] [INT] NOT NULL
	) ON [PRIMARY];
	
	INSERT INTO VisionAirport_OLTP.[CLEANSED].export_weer 
	SELECT 
		CAST(Datum AS DATETIME),
		CAST(DDVEC AS INT),
		CAST(FHVEC AS INT),
		CAST(FG AS INT),
		CAST(FHX AS INT),
		CAST(FHXH AS INT),
		CAST(FHN AS INT),
		CAST(FHNH AS INT),
		CAST(FXX AS INT),
		CAST(FXXH AS INT),
		CAST(TG AS INT),
		CAST(TN AS INT),
		CAST(TNH AS INT),
		CAST(TX AS INT),
		CAST(TXH AS INT),
	    CAST(T10N AS INT),
	    CAST(T10NH AS INT),
		CAST(SQ AS INT),
		CAST(SP AS INT),
		CAST(Q AS INT),
		CAST(DR AS INT),
		CAST(RH AS INT),
		CAST(RHX AS INT),
		CAST(RHXH AS INT),
		CAST(PG AS INT),
		CAST(PX AS INT),
		CAST(PXH AS INT),
		CAST(PN AS INT),
		CAST(PNH AS INT),
		CAST(VVN AS INT),
		CAST(VVNH AS INT),
		CAST(VVX AS INT),
		CAST(VVXH AS INT),
		CAST(NG AS INT),
		CAST(UG AS INT),
		CAST(UX AS INT),
		CAST(UXH AS INT),
		CAST(UN AS INT),
		CAST(UNH AS INT),
		CAST(EV2 AS INT)
	FROM 
		VisionAirport_OLTP.[RAW].export_weer
END
GO

-- Executing cleanse procedures
EXEC CleanseExportAankomst
EXEC CleanseExportVertrek
EXEC CleanseExportVliegtuigType
EXEC CleanseExportVliegtuig
EXEC CleanseExportMaatschappijen