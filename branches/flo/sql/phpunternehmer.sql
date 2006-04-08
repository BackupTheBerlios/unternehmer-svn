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
	"adresse_id" integer REFERENCES adresse(id),
	"pg_shadow_usesysid" integer REFERENCES pg_user(usesysid)
);

CREATE TABLE "kontakt" (
	"name_id" integer NOT NULL REFERENCES go_name(id)
);

CREATE TABLE "adresse" (
	"id" integer NOT NULL REFERENCES go_name(id),
	"strasse" character varying(50),
	"hausnr" character varying(50),
	"ort_id" integer REFERENCES ort(id)
);

CREATE TABLE "ort" (
	"id" SERIAL PRIMARY KEY,
	"plz" character varying(50),
	"stadt" character varying(50),
	"land_id" integer NOT NULL REFERENCES land(id)

);

CREATE TABLE "land" (
	"id" SERIAL PRIMARY KEY,
	"land" character varying(50)
);

CREATE TABLE "hersteller" (
	"id" SERIAL PRIMARY KEY,
	"hersteller" character varying(50),
	"modell" character varying(50)
);

-- hier kommen konten wie 8400,3400 usw rein
-- in die tabelle kontenart, kann man festlegen in welchen auswahlfeldern dieses konto erscheinen soll
CREATE TABLE "konten" (
	"id" SERIAL PRIMARY KEY,
	"kontennr" integer NOT NULL,
	"kontenbezeichnung" character varying(100),
	"kontenart_id" integer REFERENCES kontenart(id)
);

-- hier stehen dann die arten (in welchem auswahlfeld) ein konto stehen soll
-- problem: wenn man verschiedene user haben, die aber verschieden die konten sotieren
-- alle user greifen auf dieselbe tabelle zu
CREATE TABLE "kontenart" (
	"id" SERIAL PRIMARY KEY,
	"erloeskonto" boolean,
	"aufwandskonto" boolean
);

CREATE TABLE "preise" (
	"id" SERIAL PRIMARY KEY,
	"listenpreis" numeric(15,5),
	"verkaufspreis" numeric(15,5) NOT NULL,
	"einkaufspreis" numeric(15,5)
);

CREATE TABLE "waehrung" (
	"id" SERIAL PRIMARY KEY,
	"waehrung" character varying(20)
);

CREATE TABLE "vo_details" (
	"id" SERIAL PRIMARY KEY,
	"gewicht" integer,
	"einheit" character varying(50) DEFAULT 'Stck',
	"waehrung_id" integer  NOT NULL REFERENCES waehrung(id)
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
-- besseren namen finden
CREATE TABLE "rechnung_bezahlt" (
	"id" SERIAL PRIMARY KEY,
	"summe" numeric(15,5) NOT NULL,
	"kunde_id" integer NOT NULL REFERENCES go_name(id),
	"rechnung_id" integer NOT NULL REFERENCES rechnung(id),
	"rechnung_vo_id" integer,
	"erloeskonto_id" integer NOT NULL REFERENCES konten(id)
);


CREATE TABLE "rechnung" (
	"id" SERIAL PRIMARY KEY,
	"kunde_id" integer NOT NULL REFERENCES go_name(id),
	"rechnungsdatum" date DEFAULT date ('now'::text),
	"faelligkeitsdatum" date
);


CREATE TABLE "rechnung_vo" (
	"id" SERIAL PRIMARY KEY,
	"rechnung_id" integer NOT NULL REFERENCES rechnung(id),
	"vo_id" integer NOT NULL REFERENCES verkaufsobjekt(id),
	"vo_preise_id" integer NOT NULL REFERENCES preise(id),
	"buchungskonto_id" integer NOT NULL REFERENCES konten(id),
	"anzahl" integer DEFAULT 1,
	"rabatt" integer DEFAULT 0
);


GRANT ALL ON kontakt TO GROUP unternehmer;
GRANT ALL ON waehrung TO GROUP unternehmer;
grant all on rechnung_bezahlt to group unternehmer;
grant all on rechnung_bezahlt_id_seq to group unternehmer;
grant all on rechnung_vo to group unternehmer;
grant all on rechnung to group unternehmer;
grant all on rechnung_id_seq to group unternehmer;
GRANT ALL ON angestellte TO GROUP unternehmer;
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
