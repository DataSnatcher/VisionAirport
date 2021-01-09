USE VisionAirport_OLTP;

ALTER DATABASE VisionAirport_DWH SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
ALTER DATABASE VisionAirport_DWH COLLATE Latin1_General_CI_AS; 
ALTER DATABASE VisionAirport_DWH SET MULTI_USER WITH NO_WAIT;

USE VisionAirport_DWH;

DROP TABLE IF EXISTS FactVlucht;
DROP TABLE IF EXISTS DimVliegtuig;
DROP TABLE IF EXISTS DimVliegtuigType;
DROP TABLE IF EXISTS DimGate;
DROP TABLE IF EXISTS DimLuchthaven;
DROP TABLE IF EXISTS DimBanen;
DROP TABLE IF EXISTS DimDatum;
DROP TABLE IF EXISTS DimTijd;
DROP TABLE IF EXISTS DimMaatschappij;

CREATE TABLE DimMaatschappij
(
	MaatschappijKey		BIGINT		IDENTITY(1,1),
	Naam				VARCHAR(50)	COLLATE Latin1_General_CI_AS	NOT NULL,
	IATA				CHAR(3)		COLLATE Latin1_General_CI_AS	NOT NULL,
	ICAO				CHAR(4)		COLLATE Latin1_General_CI_AS	NULL,
	PRIMARY KEY (MaatschappijKey)
)

CREATE TABLE DimTijd
(
	TijdKey	BIGINT IDENTITY(1,1),
	Uur		tinyint NOT NULL,
	Minuut	tinyint NOT NULL,
	PRIMARY KEY (TijdKey)
)

CREATE TABLE DimDatum
(
	DatumKey		bigint	IDENTITY(1,1),
	DagNummer		smallint,
	DagTekst 		varchar(10),
	FiscaleWeek 	tinyint,
	Maand 			tinyint,
	Jaar 			smallint,
	VolledigeDatum 	date,
	DDVEC			smallint	NULL,
	FHVEC			tinyint		NULL,
	FG				tinyint		NULL,
	FHX				smallint	NULL,
	FHXH			tinyint		NULL,
	FHN				tinyint		NULL,
	FHNH			tinyint		NULL,
	FXX				smallint	NULL,
	FXXH			tinyint		NULL,
	TG				smallint	NULL,
	TN				smallint	NULL,
	TNH				tinyint 	NULL,
	TX				smallint 	NULL,
	TXH				tinyint 	NULL,
	T10N			smallint 	NULL,
	T10NH			tinyint 	NULL,
	SQ				smallint 	NULL,
	SP				tinyint 	NULL,
	Q				smallint 	NULL,
	DR 				smallint 	NULL,
	RH 				smallint 	NULL,
	RHX 			smallint 	NULL,
	RHXH 			tinyint 	NULL,
	PG 				smallint 	NULL,
	PX 				smallint 	NULL,
	PXH 			tinyint 	NULL,
	PN 				smallint 	NULL,
	PNH 			tinyint 	NULL,
	VVN 			tinyint 	NULL,
	VVNH 			tinyint 	NULL,
	VVX	 			tinyint 	NULL,
	VVXH 			tinyint 	NULL,
	NG 				tinyint 	NULL,
	UG 				tinyint 	NULL,
	UX 				tinyint 	NULL,
	UXH 			tinyint 	NULL,
	UN 				tinyint 	NULL,
	UNH 			tinyint 	NULL,
	EV2 			tinyint 	NULL,
	PRIMARY KEY (DatumKey)
)

CREATE TABLE DimBanen
(
	BaanKey		BIGINT		IDENTITY(1,1),
	BaanCode	VARCHAR(7)	NOT NULL,
	Naam		VARCHAR(50) NOT NULL,
	Lengte		INT 		NOT NULL,
	PRIMARY KEY (BaanKey)
)

CREATE TABLE DimLuchthaven
(
	LuchthavenKey	BIGINT		IDENTITY(1,1),
	Naam			VARCHAR(100) 	NOT NULL,
	Stad			VARCHAR(50) 	NOT NULL,
	Land			VARCHAR(50) 	NOT NULL,
	IATA			VARCHAR(3)		NULL,
	ICAO			VARCHAR(4) 		NOT NULL,
	Lat				FLOAT 			NOT NULL,
	Lon				FLOAT 			NOT NULL,
	ALT				SMALLINT 		NOT NULL,
	TimeZoneNummer	FLOAT		 	NOT NULL,
	DST				CHAR(1) 		NOT NULL,
	TimeZoneTekst	VARCHAR(100) 	NULL,
	PRIMARY KEY (LuchthavenKey)
)
CREATE TABLE DimGate
(
	GateKey		BIGINT			IDENTITY(1,1),
	GateNummer	CHAR(2)		NULL,
	Terminal	CHAR(1) 	NOT NULL,
	PRIMARY KEY (GateKey)
)

CREATE TABLE DimVliegtuigType
(
	VliegtuigTypeKey	BIGINT	IDENTITY(1,1),
	Categorie			varchar(50) 	NULL,
	IATA				char(3)			NOT NULL,
	ICAO				char(4)			NULL,
	Merk				varchar(50) 	NOT NULL,
	[Type]				varchar(100) 	NOT NULL,
	Wake				char(1) 		NULL,
	PersonenCapaciteit	int 			NOT NULL,
	VrachtCapaciteit	int 			NOT NULL,
	PRIMARY KEY (VliegtuigTypeKey)
)
CREATE TABLE DimVliegtuig
(
	VliegtuigKey		BIGINT IDENTITY(1,1) 	NOT NULL,
	MaatschappijKey		BIGINT 					NULL,
	VliegtuigtypeKey	BIGINT 					NOT NULL,
	VliegtuigCode		VARCHAR(10) 			NOT NULL,
	Bouwjaar			INT 					NOT NULL,
	PRIMARY KEY (VliegtuigKey),
	FOREIGN KEY (MaatschappijKey) REFERENCES DimMaatschappij(MaatschappijKey),
	FOREIGN KEY (VliegtuigtypeKey) REFERENCES DimVliegtuigType(VliegtuigtypeKey)
)

CREATE TABLE FactVlucht
(
	VluchtKey				BIGINT,
	VliegtuigKey			BIGINT,
	IsVertrek				bit,
	MaatschappijKey			BIGINT,
	GeplandTijdKey			BIGINT,
	TijdKey					BIGINT,
	DatumKey				BIGINT,
	BaanKey					BIGINT,
	LuchthavenKey			BIGINT,
	GateKey					BIGINT,
	GeplandGateKey			BIGINT,
	Operatie				decimal(2,1) 	NULL,
	Faciliteiten			decimal(2,1) 	NULL,
	Shops					decimal(2,1)	NULL,
	VluchtCode				VARCHAR(10)		NULL,
	Bezetting				INT				NULL,
	Vracht					INT				NULL,
	PRIMARY KEY (VluchtKey),
	FOREIGN KEY (VliegtuigKey) REFERENCES DimVliegtuig(VliegtuigKey),
	FOREIGN KEY (MaatschappijKey) REFERENCES DimMaatschappij(MaatschappijKey),
	FOREIGN KEY (GeplandTijdKey) REFERENCES DimTijd(TijdKey),
	FOREIGN KEY (TijdKey) REFERENCES DimTijd(TijdKey),
	FOREIGN KEY (DatumKey) REFERENCES DimDatum(DatumKey),
	FOREIGN KEY (BaanKey) REFERENCES DimBanen(BaanKey),
	FOREIGN KEY (LuchthavenKey) REFERENCES DimLuchthaven(LuchthavenKey),
	FOREIGN KEY (GateKey) REFERENCES DimGate(GateKey),
	FOREIGN KEY (GeplandGateKey) REFERENCES DimGate(GateKey),
)
