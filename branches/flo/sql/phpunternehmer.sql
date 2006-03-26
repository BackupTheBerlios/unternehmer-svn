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
	
