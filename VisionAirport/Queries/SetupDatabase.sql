CREATE SCHEMA [RAW]
GO
CREATE SCHEMA [ARCHIVE]
GO
CREATE SCHEMA [CLEANSED]
GO

-- Drop any database named VisionAirport_DWH and Create a new VisionAirport_DWH Database
DROP DATABASE IF EXISTS VisionAirport_DWH;
CREATE DATABASE VisionAirport_DWH;

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