CREATE TABLE "go_name" (
	"id" SERIAL PRIMARY KEY,
	"firmenname" character varying(50),
	"vorname" character varying(50),
	"nachname" character varying(50)
);
CREATE TABLE "geschaeftsobjekt" (
	"name_id" integer NOT NULL REFERENCES go_name(id),
	"adresse_id" integer
);
CREATE TABLE "angestellte" (
	"name_id" integer  NOT NULL REFERENCES go_name(id),
	"adresse_id" integer,
	"pg_shadow_usesysid" integer
);
CREATE TABLE "adresse" (
	"id" integer NOT NULL REFERENCES go_name(id),
	"strasse" character varying(50),
	"hausnr" character varying(50),
	"plz" character varying(50),
	"stadt" character varying(50),
	"land" character varying(50)
);
-- vo_minimal heist VerkaufsObjekt, weil es ware,dienstleistung oder lizenz sein kann. name halt
CREATE TABLE "vo_minimal" (
	"id" SERIAL PRIMARY KEY,
	"art_bezeichnung" character varying(50),
	"art_nr" character varying(50)
);

CREATE TABLE "hersteller" (
	"id" integer NOT NULL REFERENCES vo_minimal(id),
	"hersteller" character varying(50),
	"modell" character varying(50)
);

-- konten fuer verkaufsobjekt, weiss nicht ob alle zusammen in eine tabelle sollen
CREATE TABLE "vo_erloeskonten" (
	"id" integer NOT NULL REFERENCES vo_minimal(id),
	"8300" boolean,
	"8400" boolean
);

CREATE TABLE "vo_aufwandskonten" (
	"id" integer NOT NULL REFERENCES vo_minimal(id),
	"3300" boolean,
	"3400" boolean
);

CREATE TABLE "preise" (
	"id" SERIAL PRIMARY KEY,
	"vo_minimal_id" integer NOT NULL,
	"listenpreis" numeric(15,5),
	"verkaufspreis" numeric(15,5),
	"einkaufspreis" numeric(15,5)
);

CREATE TABLE "vo_details" (
	"id" integer NOT NULL REFERENCES vo_minimal(id),
	"gewicht" integer,
	"einheit" character varying(50)
);
