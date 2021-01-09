CREATE SCHEMA [RAW]
GO
CREATE SCHEMA [ARCHIVE]
GO
CREATE SCHEMA [CLEANSED]
GO

-- Drop the MoveToSchema procedure in case it already exists
Drop Procedure IF EXISTS VisionAirport_OLTP.MoveToSchema
GO
-- MoveToSchema procedure allows us to quickly change the schema of any table from any schema to another schema
-- This procedures contains no error handlers
CREATE PROCEDURE MoveToSchema
	@Database SYSNAME,
	@Uncleansed SYSNAME,
	@OldSchema SYSNAME,
	@NewSchema SYSNAME
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @SQL NVARCHAR(MAX) =
		N'USE ' + @Database + ' ALTER SCHEMA ' + @NewSchema + ' TRANSFER ' + @OldSchema + '.' + @Uncleansed;
	EXECUTE sp_executesql @SQL;
END

-- Execution of moveschema procedure: Moving from DBO -> RAW
EXEC MoveToSchema [VisionAirport_OLTP], [export_aankomst], [dbo], [RAW]
GO
EXEC MoveToSchema [VisionAirport_OLTP], [export_banen], [dbo], [RAW]
GO
EXEC MoveToSchema [VisionAirport_OLTP], [export_klant], [dbo], [RAW]
GO
EXEC MoveToSchema [VisionAirport_OLTP], [export_luchthavens], [dbo], [RAW]
GO
EXEC MoveToSchema [VisionAirport_OLTP], [export_maatschappijen], [dbo], [RAW]
GO
EXEC MoveToSchema [VisionAirport_OLTP], [export_planning], [dbo], [RAW]
GO
EXEC MoveToSchema [VisionAirport_OLTP], [export_vertrek], [dbo], [RAW]
GO
EXEC MoveToSchema [VisionAirport_OLTP], [export_vliegtuig], [dbo], [RAW]
GO
EXEC MoveToSchema [VisionAirport_OLTP], [export_vliegtuigtype], [dbo], [RAW]
GO
EXEC MoveToSchema [VisionAirport_OLTP], [export_vlucht], [dbo], [RAW]
GO
EXEC MoveToSchema [VisionAirport_OLTP], [export_weer], [dbo], [RAW]
GO




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
		[VliegtuigKey] INT IDENTITY(1,1) NOT NULL,
		[VliegtuigtypeKey] [INT] NOT NULL,
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


CREATE PROCEDURE CleanseExportVliegtuigType
AS
BEGIN
	SET ANSI_NULLS ON;

	SET QUOTED_IDENTIFIER ON;

	DROP TABLE IF EXISTS [VisionAirport_OLTP].[CLEANSED].[export_vliegtuigtype];

	CREATE TABLE VisionAirport_OLTP.[CLEANSED].[export_vliegtuigtype](
		VliegtuigTypeKey INT IDENTITY(1,1) NOT NULL,
		IATA CHAR(3) NOT NULL,
		ICAO CHAR(4) NULL,
		MERK VARCHAR(50) NULL,
		TYPE VARCHAR(100) NULL,
		Wake CHAR(1) NULL,
		Cat VARCHAR(50) NULL,
		Capaciteit INT NULL,
		Vracht INT NULL,
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

CREATE PROCEDURE [dbo].[CleanseExportVertrek]
AS
BEGIN
	IF NOT EXISTS (
	SELECT * FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'export_vertrek'
    AND TABLE_SCHEMA = 'CLEANSED')
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
		CAST(Terminal AS CHAR(1)), 
		NULLIF(CAST(Gate AS CHAR(2)),''), 
		CAST(Baan AS INT), 
		CAST(Bezetting AS INT), 
		CAST(Vracht AS INT), 
		CAST(VertrekTijd AS DATETIME)
	FROM 
		VisionAirport_OLTP.[RAW].export_vertrek
END

-- Executing cleanse procedures
EXEC CleanseExportAankomst
EXEC CleanseExportVliegtuigType
EXEC CleanseExportVertrek
EXEC CleanseExportVliegtuig
