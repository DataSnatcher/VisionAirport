USE [VisionAirport_OLTP];

DROP TABLE IF EXISTS [CLEANSED].[export_planning];
DROP TABLE IF EXISTS [CLEANSED].[export_luchthavens];
DROP TABLE IF EXISTS [CLEANSED].[export_klant];
DROP TABLE IF EXISTS [CLEANSED].[export_vertrek];
DROP TABLE IF EXISTS [CLEANSED].[export_aankomst];
DROP TABLE IF EXISTS [CLEANSED].[export_banen];
DROP TABLE IF EXISTS [CLEANSED].[export_vlucht];
DROP TABLE IF EXISTS [CLEANSED].[export_vliegtuig];
DROP TABLE IF EXISTS [CLEANSED].[export_vliegtuigtype];
DROP TABLE IF EXISTS [CLEANSED].[export_maatschappijen];
DROP TABLE IF EXISTS [CLEANSED].[export_weer]
DROP TABLE IF EXISTS [CLEANSED].[generated_datum];
DROP TABLE IF EXISTS [CLEANSED].[generated_time];

DROP TABLE IF EXISTS [ARCHIVE].[export_aankomst];
DROP TABLE IF EXISTS [ARCHIVE].[export_maatschappijen];
DROP TABLE IF EXISTS [ARCHIVE].[export_vliegtuigtype];
DROP TABLE IF EXISTS [ARCHIVE].[export_luchthavens];
DROP TABLE IF EXISTS [ARCHIVE].[export_vertrek];

-- Create all the tables.
CREATE TABLE [CLEANSED].[export_weer](
	Datum	date		NOT NULL	PRIMARY KEY,
	DDVEC	smallint	NOT NULL,
	FHVEC	tinyint		NOT NULL,
	FG		tinyint		NOT NULL,
	FHX		smallint	NOT NULL,
	FHXH	tinyint		NOT NULL,
	FHN		tinyint		NOT NULL,
	FHNH	tinyint		NOT NULL,
	FXX		smallint	NOT NULL,
	FXXH	tinyint		NOT NULL,
	TG		smallint	NOT NULL,
	TN		smallint	NOT NULL,
	TNH		tinyint 	NOT NULL,
	TX		smallint 	NOT NULL,
	TXH		tinyint 	NOT NULL,
	T10N	smallint 	NOT NULL,
	T10NH	tinyint 	NOT NULL,
	SQ		smallint 	NOT NULL,
	SP		tinyint 	NOT NULL,
	Q		smallint 	NOT NULL,
	DR 		smallint 	NOT NULL,
	RH 		smallint 	NOT NULL,
	RHX 	smallint 	NOT NULL,
	RHXH 	tinyint 	NOT NULL,
	PG 		smallint 	NOT NULL,
	PX 		smallint 	NOT NULL,
	PXH 	tinyint 	NOT NULL,
	PN 		smallint 	NOT NULL,
	PNH 	tinyint 	NOT NULL,
	VVN 	tinyint 	NOT NULL,
	VVNH 	tinyint 	NOT NULL,
	VVX	 	tinyint 	NOT NULL,
	VVXH 	tinyint 	NOT NULL,
	NG 		tinyint 	NOT NULL,
	UG 		tinyint 	NOT NULL,
	UX 		tinyint 	NOT NULL,
	UXH 	tinyint 	NOT NULL,
	UN 		tinyint 	NOT NULL,
	UNH 	tinyint 	NOT NULL,
	EV2 	tinyint 	NOT NULL
);
CREATE TABLE [CLEANSED].[export_maatschappijen] (
	Id		bigint		NOT NULL	IDENTITY	PRIMARY KEY,
	Name	varchar(50) NOT NULL,
	IATA	varchar(2)	NULL,
	ICAO	varchar(3)	NULL
);
CREATE TABLE [CLEANSED].[export_vliegtuigtype](
	IATA				char(3)			NOT NULL	PRIMARY KEY,
	ICAO				char(4)			NULL,
	Merk				varchar(50)		NOT NULL,
	[Type]				varchar(100)	NOT NULL,
	Wake				char(1)			NULL,
	Cat					varchar(50)		NULL,
	Capaciteit			int				NULL,
	Vracht				int				NULL
);
CREATE TABLE [CLEANSED].[export_vliegtuig](
	VliegtuigCode		varchar(8)		NOT NULL	PRIMARY KEY,
	VliegtuigType		char(3)			NOT NULL,
	AirlineCode			varchar(5)		NULL,
	Bouwjaar			int				NULL,
	FOREIGN KEY (VliegtuigType) REFERENCES [CLEANSED].[export_vliegtuigtype](IATA),
);
CREATE TABLE [CLEANSED].[export_vlucht] (
	VluchtId		bigint			NOT NULL	PRIMARY KEY,
	VluchtNr		varchar(7)		NULL,
	AirlineCode		varchar(3)		NULL,		-- TODO
	DestCode		varchar(3)		NOT NULL,	-- TODO
	VliegtuigCode	varchar(8)		NOT NULL,
	Datum			date			NOT NULL,
	FOREIGN KEY (VliegtuigCode) REFERENCES [CLEANSED].[export_vliegtuig](VliegtuigCode),
);
CREATE TABLE [CLEANSED].[export_banen] (
	Baannummer	int			NOT NULL	PRIMARY KEY,
	Code		varchar(7)	NOT NULL,
	Naam		varchar(50) NOT NULL,
	Lengte		int			NOT NULL
);
CREATE TABLE [CLEANSED].[export_aankomst](
	VluchtId		bigint		NOT NULL	PRIMARY KEY,
	VliegtuigCode	varchar(10) NOT NULL,
	Terminal		char(1)		NULL,
	Gate			char(2)		NULL,
	Baan			int			NULL,
	Bezetting		int			NULL,
	Vracht			int			NULL,
	Datum			date		NULL,
	Uur				tinyint		NULL,
	Minuut			tinyint		NULL
	FOREIGN KEY (VluchtId) REFERENCES [CLEANSED].[export_vlucht](VluchtId),
	FOREIGN KEY (Baan) REFERENCES [CLEANSED].[export_banen](Baannummer),
);
CREATE TABLE [CLEANSED].[export_vertrek](
	VluchtId		bigint		NOT NULL	PRIMARY KEY,
	VliegtuigCode	varchar(10)	NOT NULL,
	Terminal		char(1)		NULL,
	Gate			char(2)		NULL,
	Baan			int			NULL,
	Bezetting		int			NULL,
	Vracht			int			NULL,
	Datum			date		NULL,
	Uur				tinyint		NULL,
	Minuut			tinyint		NULL
	FOREIGN KEY (VluchtId) REFERENCES [CLEANSED].[export_vlucht](VluchtId),
	FOREIGN KEY (Baan) REFERENCES [CLEANSED].[export_banen](Baannummer),
);
CREATE TABLE [CLEANSED].[export_klant] (
	VluchtId		bigint	NOT NULL	PRIMARY KEY,
	Operatie		float	NOT NULL,
	Faciliteiten	float	NOT NULL,
	Shops			float	NULL,
	FOREIGN KEY (VluchtId) REFERENCES [CLEANSED].[export_vlucht](VluchtId),
);
CREATE TABLE [CLEANSED].[export_luchthavens] (
	Id			bigint			NOT NULL	IDENTITY	PRIMARY KEY,
	Naam		varchar(100)	NOT NULL,
	Stad		varchar(50)		NOT NULL,
	Land		varchar(50)		NOT NULL,
	IATA		varchar(3)		NULL,
	ICAO		varchar(4)		NOT NULL,
	Latitude	float			NOT NULL,
	Longitude	float			NOT NULL,
	Altitude	smallint		NOT NULL,
	Timezone	float			NOT NULL,
	DST			char(1)			NOT NULL,
	Area		varchar(100)	NULL
);
CREATE TABLE [CLEANSED].[export_planning] (
	VluchtNr		varchar(8)	NOT NULL	PRIMARY KEY,
    AirlineCode		varchar(3)	NOT NULL,
    DestCode		char(3)		NOT NULL,
    PlanTerminal	char(1)		NULL,
    PlanGate		char(2)		NULL,
    PlanTijd		time		NULL,
	Uur				tinyint		NULL,
	Minuut			tinyint		NULL
);
CREATE TABLE [CLEANSED].[generated_datum]
(
	DatumKey		bigint	IDENTITY(1,1),
	DagNummer		smallint,
	DagTekst 		varchar(10),
	FiscaleWeek 	tinyint,
	Maand 			tinyint,
	Jaar 			smallint,
	VolledigeDatum 	date,
	PRIMARY KEY (DatumKey)
)
CREATE TABLE [CLEANSED].[generated_time]
(
	TimeKey	smallint,
	Uur		tinyint,
	Minuut 	tinyint,
	PRIMARY KEY (TimeKey)
)

CREATE TABLE [ARCHIVE].[export_aankomst] (
	VluchtId		bigint		NULL,
	VliegtuigCode	varchar(10) NULL,
	Terminal		char(1)		NULL,
	Gate			char(2)		NULL,
	Baan			int			NULL,
	Bezetting		int			NULL,
	Vracht			int			NULL,
	Aankomsttijd	datetime	NULL,
);
CREATE TABLE [ARCHIVE].[export_maatschappijen] (
	MaatschappijKey		bigint			NOT NULL	IDENTITY	PRIMARY KEY,
	Name	varchar(50) NOT NULL,
	IATA	varchar(2)	NULL,
	ICAO	varchar(3)	NULL
);
CREATE TABLE [ARCHIVE].[export_luchthavens] (
	Id			bigint			NOT NULL	IDENTITY	PRIMARY KEY,
	Naam		varchar(100)	NOT NULL,
	Stad		varchar(50)		NOT NULL,
	Land		varchar(50)		NOT NULL,
	IATA		varchar(3)		NULL,
	ICAO		varchar(4)		NULL,
	Latitude	float			NOT NULL,
	Longitude	float			NOT NULL,
	Altitude	smallint		NOT NULL,
	Timezone	float			NOT NULL,
	DST			char(1)			NOT NULL,
	Area		varchar(100)	NULL
);
CREATE TABLE [ARCHIVE].[export_vliegtuigtype](
	IATA				char(3)			NOT NULL	PRIMARY KEY,
	ICAO				char(4)			NULL,
	Merk				varchar(50)		NULL,
	[Type]				varchar(100)	NULL,
	Wake				char(1)			NULL,
	Cat					varchar(50)		NULL,
	Capaciteit			int				NULL,
	Vracht				int				NULL
);
CREATE TABLE [ARCHIVE].[export_vertrek](
	VluchtId		bigint		NOT NULL	PRIMARY KEY,
	VliegtuigCode	varchar(10)	NOT NULL,
	Terminal		char(1)		NULL,
	Gate			char(2)		NULL,
	Baan			int			NULL,
	Bezetting		int			NULL,
	Vracht			int			NULL,
	Datum			date		NULL,
	Uur				tinyint		NULL,
	Minuut			tinyint		NULL
);

-- Input the actual data in the new tables.
INSERT INTO [CLEANSED].[export_weer] 
	SELECT 
		CAST(Datum AS datetime),
		CAST(DDVEC AS smallint),
		CAST(FHVEC AS tinyint),
		CAST(FG AS tinyint),
		CAST(FHX AS smallint),
		CAST(FHXH AS tinyint),
		CAST(FHN AS tinyint),
		CAST(FHNH AS tinyint),
		CAST(FXX AS smallint),
		CAST(FXXH AS tinyint),
		CAST(TG AS smallint),
		CAST(TN AS smallint),
		CAST(TNH AS tinyint),
		CAST(TX AS smallint),
		CAST(TXH AS tinyint),
	    CAST(T10N AS smallint),
	    CAST(T10NH AS tinyint),
		CAST(SQ AS smallint),
		CAST(SP AS tinyint),
		CAST(Q AS smallint),
		CAST(DR AS smallint),
		CAST(RH AS smallint),
		CAST(RHX AS smallint),
		CAST(RHXH AS tinyint),
		CAST(PG AS smallint),
		CAST(PX AS smallint),
		CAST(PXH AS tinyint),
		CAST(PN AS smallint),
		CAST(PNH AS tinyint),
		CAST(VVN AS tinyint),
		CAST(VVNH AS tinyint),
		CAST(VVX AS tinyint),
		CAST(VVXH AS tinyint),
		CAST(NG AS tinyint),
		CAST(UG AS tinyint),
		CAST(UX AS tinyint),
		CAST(UXH AS tinyint),
		CAST(UN AS tinyint),
		CAST(UNH AS tinyint),
		CAST(EV2 AS tinyint)
	FROM [RAW].export_weer
INSERT INTO [CLEANSED].[export_maatschappijen]
	SELECT *
	FROM (
		SELECT 
			REPLACE(CAST(Name AS varchar(50)), '\', '') Name,
			NULLIF(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(CAST(IATA AS varchar(2)), '?', ''), '+', ''), ';', ''), '"', ''), '^', ''), '-', ''), '\N', ''), '') IATA, 
			NULLIF(REPLACE(REPLACE(REPLACE(REPLACE(CAST(ICAO AS varchar(3)), '+', ''), '-', ''), 'N/A', ''), '\N', ''), '') ICAO 
		FROM [RAW].[export_maatschappijen]
	) AS [export_maatschappijen]
	WHERE IATA IS NOT NULL
		AND Name <> 'China Airlines Cargo'
		AND Name <> 'Cathay Pacific Cargo'
		AND Name <> 'Iran Air Cargo'
		AND Name <> 'Japan Airlines Domestic'
		AND Name <> 'Korean Air Cargo'
		AND Name <> 'MASkargo'
		AND Name <> 'Qatar Airways Cargo'
		AND Name <> 'Royal Nepal Airlines'
		AND Name <> 'Tiger Airways Australia'
		AND Name <> 'Turkish Airlines Cargo'
		AND Name <> 'Emirates SkyCargo'
		AND Name <> 'Emirates SkyCargo';
INSERT INTO [ARCHIVE].[export_maatschappijen]
	SELECT *
	FROM (
		SELECT 
			REPLACE(CAST(Name AS varchar(50)), '\', '') Name,
			NULLIF(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(CAST(IATA AS varchar(2)), '?', ''), '+', ''), ';', ''), '"', ''), '^', ''), '-', ''), '\N', ''), '') IATA, 
			NULLIF(REPLACE(REPLACE(REPLACE(REPLACE(CAST(ICAO AS varchar(3)), '+', ''), '-', ''), 'N/A', ''), '\N', ''), '') ICAO 
		FROM [RAW].[export_maatschappijen]
	) AS export_maatschappijen
	WHERE IATA IS NULL
		OR Name = 'China Airlines Cargo'
		OR Name = 'Cathay Pacific Cargo'
		OR Name = 'Iran Air Cargo'
		OR Name = 'Japan Airlines Domestic'
		OR Name = 'Korean Air Cargo'
		OR Name = 'MASkargo'
		OR Name = 'Qatar Airways Cargo'
		OR Name = 'Royal Nepal Airlines'
		OR Name = 'Tiger Airways Australia'
		OR Name = 'Turkish Airlines Cargo'
		OR Name = 'Emirates SkyCargo';
INSERT INTO [CLEANSED].[export_vliegtuigtype]
	SELECT *
	FROM (
		SELECT 
			NULLIF(CAST(IATA AS char(3)),'') IATA, 
			CAST(NULLIF(NULLIF(ICAO, ''), 'n/a') AS char(4)) ICAO, -- check on two expressions
			NULLIF(CAST(Merk AS varchar(50)),'') Merk,
			NULLIF(CAST(Type AS varchar(100)),'') [Type],
			CAST(NULLIF(NULLIF(WAKE, ''), 'n/a') AS char(1)) Wake, -- check on two expressions
			NULLIF(CAST(CAT AS varchar(50)), '') Cat,
			CAST(NULLIF(Capaciteit, '') AS int) Capaciteit,
			CAST(NULLIF(Vracht, '') AS int) Vracht	
		FROM [RAW].[export_vliegtuigtype]
	) AS [export_vliegtuigtype]
	WHERE Merk IS NOT NULL;
INSERT INTO [ARCHIVE].[export_vliegtuigtype]
	SELECT *
	FROM (
		SELECT 
			NULLIF(CAST(IATA AS char(3)),'') IATA, 
			CAST(NULLIF(NULLIF(ICAO, ''), 'n/a') AS char(4)) ICAO, -- check on two expressions
			NULLIF(CAST(Merk AS varchar(50)),'') Merk,
			NULLIF(CAST(Type AS varchar(100)),'') [Type],
			CAST(NULLIF(NULLIF(WAKE, ''), 'n/a') AS char(1)) Wake, -- check on two expressions
			NULLIF(CAST(CAT AS varchar(50)), '') Cat,
			CAST(NULLIF(Capaciteit, '') AS int) Capaciteit,
			CAST(NULLIF(Vracht, '') AS int) Vracht	
		FROM [RAW].[export_vliegtuigtype]
	) AS [export_vliegtuigtype]
	WHERE Merk IS NULL;
INSERT INTO [CLEANSED].[export_vliegtuig] 
	SELECT
		CAST(VliegtuigCode AS varchar(10)) VliegtuigCode,
		CAST(VliegtuigType AS char(3)) VliegtuigType,
		NULLIF(NULLIF(NULLIF(CAST(AirlineCode AS varchar(5)),''), '-'), 'CAI') AirlineCode, 
		CAST(NULLIF(Bouwjaar, '') AS int) Bouwjaar
	FROM [RAW].[export_vliegtuig] AS V
		OUTER APPLY (
			SELECT TOP(1) *
				FROM [CLEANSED].[export_maatschappijen] m
				WHERE
					V.AirlineCode = m.ICAO OR V.AirlineCode =  m.IATA
		) M;
INSERT INTO [CLEANSED].[export_vlucht]
	SELECT 
		CAST(VluchtId AS bigint),
		NULLIF(CAST(VluchtNr AS varchar(7)), ''),
		NULLIF(CAST(AirlineCode AS varchar(3)), '-'),
		CAST(DestCode AS varchar(3)),
		CAST(Vliegtuigcode AS varchar(8)),
		CAST(Datum AS date)
	FROM [RAW].[export_vlucht];
INSERT INTO [CLEANSED].[export_banen]
	SELECT 
		CAST(Baannummer AS int),
		CAST(Code AS varchar(7)),
		CAST(dbo.DecodeUTF8String(Naam) AS varchar(50)),
		CAST(Lengte AS int)
	FROM [RAW].[export_banen];
INSERT INTO [CLEANSED].[export_aankomst] 
	SELECT 
		CAST(CAST(REPLACE(A.VluchtId, ',', '.') AS float) AS bigint), -- Important because some fields are written in scientific notation with "," instead of "."
		CAST(A.VliegtuigCode AS varchar(10)), 
		NULLIF(CAST(Terminal AS char(1)), ''), 
		NULLIF(CAST(Gate AS char(2)), ''), 
		NULLIF(CAST(Baan AS int), ''), 
		NULLIF(CAST(Bezetting AS int), ''), 
		NULLIF(CAST(Vracht AS int), ''),
		NULLIF(CAST(AankomstTijd AS DATE), ''),
		REPLACE(DATEPART(HOUR, AankomstTijd), '', 0),
		REPLACE(DATEPART(MINUTE, AankomstTijd), '', 0)
	FROM [RAW].[export_aankomst] A
		LEFT OUTER JOIN [CLEANSED].[export_vlucht] V
			ON V.VluchtId = CAST(CAST(REPLACE(A.VluchtId, ',', '.') AS float) AS bigint)
	WHERE Aankomsttijd <> '' AND V.VluchtId IS NOT NULL;
INSERT INTO [ARCHIVE].[export_aankomst] 
	SELECT 
		CAST(CAST(REPLACE(A.VluchtId, ',', '.') AS float) AS bigint), -- Important because some fields are written in scientific notation with "," instead of "."
		CAST(A.VliegtuigCode AS varchar(10)), 
		CAST(Terminal AS char(1)), 
		NULLIF(CAST(Gate AS char(2)),''), 
		CAST(Baan AS int), 
		CAST(Bezetting AS int), 
		CAST(Vracht AS int), 
		CAST(AankomstTijd AS datetime) AankomstTijd
	FROM [RAW].[export_aankomst] A
		LEFT OUTER JOIN [CLEANSED].[export_vlucht] V
			ON V.VluchtId = CAST(CAST(REPLACE(A.VluchtId, ',', '.') AS float) AS bigint)
	WHERE Aankomsttijd = '' OR V.VluchtId IS NULL;
INSERT INTO [CLEANSED].[export_vertrek]
	SELECT 
		CAST(CAST(REPLACE(Vluchtid, ',', '.') AS float) AS bigint),
		CAST(VliegtuigCode AS varchar(10)), 
		NULLIF(CAST(Terminal AS char(1)), ''), 
		NULLIF(CAST(Gate AS char(2)), ''), 
		NULLIF(CAST(Baan AS int), ''), 
		NULLIF(CAST(Bezetting AS int), ''), 
		NULLIF(CAST(Vracht AS int), ''), 
		NULLIF(CAST(Vertrektijd AS DATE), ''),
		NULLIF(DATEPART(HOUR, Vertrektijd), ''),
		NULLIF(DATEPART(MINUTE, Vertrektijd), '')			
	FROM [RAW].[export_vertrek]
	WHERE NULLIF(CAST(Vertrektijd AS DATE), '') IS NOT NULL;
INSERT INTO [ARCHIVE].[export_vertrek]
	SELECT 
		CAST(CAST(REPLACE(Vluchtid, ',', '.') AS float) AS bigint),
		CAST(VliegtuigCode AS varchar(10)), 
		NULLIF(CAST(Terminal AS char(1)), ''), 
		NULLIF(CAST(Gate AS char(2)), ''), 
		NULLIF(CAST(Baan AS int), ''), 
		NULLIF(CAST(Bezetting AS int), ''), 
		NULLIF(CAST(Vracht AS int), ''), 
		NULLIF(CAST(Vertrektijd AS DATE), ''),
		NULLIF(DATEPART(HOUR, Vertrektijd), ''),
		NULLIF(DATEPART(MINUTE, Vertrektijd), '')			
	FROM [RAW].[export_vertrek]
	WHERE NULLIF(CAST(Vertrektijd AS DATE), '') IS NULL;
INSERT INTO [CLEANSED].[export_klant]
	SELECT 
		CAST(VluchtId AS bigint),
		CAST(Operatie AS float), 
		CAST(Faciliteiten AS float),
		NULLIF(CAST(Shops AS float), 0)
	FROM [RAW].[export_klant]
INSERT INTO [CLEANSED].[export_luchthavens]
	SELECT *	
	FROM (
		SELECT 
			CAST(Naam AS varchar(100)) Naam,
			CAST(Stad AS varchar(50)) Stad,
			CAST(Land AS varchar(50)) Land,
			NULLIF(CAST(IATA AS varchar(3)), '') IATA,
			NULLIF(REPLACE(CAST(ICAO AS varchar(4)), '\N', ''), '') ICAO,
			CAST(Lat AS float) Latitude,
			CAST(Lon AS float) Longitude,
			CAST(Alt AS smallint) Altidue,
			CAST(TimeZoneNummer AS float) TimeZoneNummer,
			CAST(DST AS char(1)) DST,
			NULLIF(REPLACE(CAST(TimeZoneTekst AS varchar(100)), '\N', ''), '') TimeZoneTekst
		FROM [RAW].[export_luchthavens]
	) AS export_luchthavens
	WHERE ICAO IS NOT NULL;
INSERT INTO [ARCHIVE].[export_luchthavens]
	SELECT *	
	FROM (
		SELECT 
			CAST(Naam AS varchar(100)) Naam,
			CAST(Stad AS varchar(50)) Stad,
			CAST(Land AS varchar(50)) Land,
			NULLIF(CAST(IATA AS varchar(3)), '') IATA,
			NULLIF(REPLACE(CAST(ICAO AS varchar(4)), '\N', ''), '') ICAO,
			CAST(Lat AS float) Latitude,
			CAST(Lon AS float) Longitude,
			CAST(Alt AS smallint) Altidue,
			CAST(TimeZoneNummer AS float) TimeZoneNummer,
			CAST(DST AS char(1)) DST,
			NULLIF(REPLACE(CAST(TimeZoneTekst AS varchar(100)), '\N', ''), '') TimeZoneTekst
		FROM [RAW].[export_luchthavens]
	) AS export_luchthavens
	WHERE ICAO IS NULL;
INSERT INTO [CLEANSED].[export_planning]
	SELECT 
		CAST(VluchtNr AS varchar(8)),
		CAST(AirlineCode AS varchar(3)),
		CAST(DestCode AS char(3)),
		NULLIF(CAST(PlanTerminal AS char(1)), ''),
		NULLIF(CAST(PlanGate AS char(2)), ''),
		NULLIF(CAST(PlanTijd AS time), ''),
		REPLACE(DATEPART(HOUR, PlanTijd), '', 0),
		REPLACE(DATEPART(MINUTE, PlanTijd), '', 0)
	FROM [RAW].[export_planning];

-- Delete duplicates
WITH luchthavens AS (
    SELECT 
        Id, 
        Naam, 
        Stad, 
        Land, 
		IATA,
		ICAO,
		Latitude,
		Longitude,
		Altitude,
		Timezone,
		DST,
		Area,
        ROW_NUMBER() OVER (
            PARTITION BY 
                Naam, 
				Stad, 
				Land, 
				IATA,
				ICAO,
				Latitude,
				Longitude,
				Altitude,
				Timezone,
				DST,
				Area
			ORDER BY
				Naam
        ) row_num
     FROM [CLEANSED].[export_luchthavens]
)
DELETE FROM luchthavens
WHERE row_num > 1; 

-- Generate our own data.
DECLARE @StartDate  date = '20140101';
DECLARE @CutoffDate date = DATEADD(DAY, -1, DATEADD(YEAR, 30, @StartDate));

-- SET LANGUAGE Dutch;
SET LANGUAGE us_english;

WITH seq(n) AS 
(
  SELECT 0 UNION ALL SELECT n + 1 FROM seq
  WHERE n < DATEDIFF(DAY, @StartDate, @CutoffDate)
),
d(d) AS 
(
  SELECT DATEADD(DAY, n, @StartDate) FROM seq
),
src AS
(
  SELECT
    TheDate         = CONVERT(date, d),
    TheDay          = DATEPART(DAY,       d),
    TheDayName      = DATENAME(WEEKDAY,   d),
    TheWeek         = DATEPART(WEEK,      d),
    TheISOWeek      = DATEPART(ISO_WEEK,  d),
    TheDayOfWeek    = DATEPART(WEEKDAY,   d),
    TheMonth        = DATEPART(MONTH,     d),
    TheMonthName    = DATENAME(MONTH,     d),
    TheQuarter      = DATEPART(Quarter,   d),
    TheYear         = DATEPART(YEAR,      d),
    TheFirstOfMonth = DATEFROMPARTS(YEAR(d), MONTH(d), 1),
    TheLastOfYear   = DATEFROMPARTS(YEAR(d), 12, 31),
    TheDayOfYear    = DATEPART(DAYOFYEAR, d)
  FROM d
),
dim AS
(
  SELECT
	DagNummer		=	TheDay,
	DagTekst		=	TheDayName,
	FiscaleWeek		=	CASE WHEN (TheWeek - 1) <= 0 THEN TheWeek + 52 ELSE TheWeek - 1 END,
	Maand			=	TheMonth,
	Jaar			=	TheYear,
	VolledigeDatum	=	TheDate
  FROM src
)
INSERT
	INTO [CLEANSED].[generated_datum]
	SELECT * 
		FROM dim
		ORDER BY VolledigeDatum
		OPTION (MAXRECURSION 0)
GO

DECLARE @hour	int = 0;
DECLARE @minute int = 0;

WHILE @hour < 24
BEGIN
	SET @minute = 0;

	WHILE @minute < 60
	BEGIN
		INSERT INTO [CLEANSED].[generated_time]
			SELECT
			(@hour*100) + @minute as TimeKey,
			@hour as [Hour],
			@minute as [Minute];

		SET @minute = @minute + 1;
	END;

	SET @hour = @hour + 1;
END
GO