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

CREATE TABLE "hersteller" (
	"id" SERIAL PRIMARY KEY,
	"hersteller" character varying(50),
	"modell" character varying(50)
);

-- hier kommen konten wie 8400,3400 usw rein
CREATE TABLE "konten" (
	"id" SERIAL PRIMARY KEY,
	"kontennr" integer NOT NULL,
	"kontenbezeichnung" character varying(100)
);

CREATE TABLE "preise" (
	"id" SERIAL PRIMARY KEY,
	"listenpreis" numeric(15,5),
	"verkaufspreis" numeric(15,5) NOT NULL,
	"einkaufspreis" numeric(15,5)
);

CREATE TABLE "vo_details" (
	"id" SERIAL PRIMARY KEY,
	"gewicht" integer,
	"einheit" character varying(50) DEFAULT 'Stck'
);

--  VerkaufsObjekt, weil es ware,dienstleistung oder lizenz sein kann. name halt
-- vo muss ein preis haben
CREATE TABLE "verkaufsobjekt" (
	"id" SERIAL PRIMARY KEY,
	"bezeichnung" character varying(50) NOT NULL,
	"art_nr" character varying(50),
	"preise_id" integer NOT NULL REFERENCES preise(id),
	"erloeskonto_id" integer NOT NULL REFERENCES konten(id),
	"aufwandskonto_id" integer NOT NULL REFERENCES konten(id),
	"hersteller_id" integer REFERENCES hersteller(id),
	"vo_details_id" integer REFERENCES vo_details(id)
);

GRANT ALL ON go_name to group unternehmer;
grant all on database d to group unternehmer;
grant all on go_name_id_seq to group unternehmer; 
grant all on adresse to group unternehmer;
grant all on preise to group unternehmer;
grant all on konten to group unternehmer;
grant all on verkaufsobjekt to group unternehmer;
grant all on preise_id_seq to group unternehmer;
grant all on konten_id_seq to group unternehmer;
grant all on hersteller_id_seq to group unternehmer;
grant all on verkaufsobjekt_id_seq to group unternehmer;
grant all on vo_details_id_seq to group unternehmer;
