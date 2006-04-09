CREATE TABLE "land" (
	"id" SERIAL PRIMARY KEY,
	"land" character varying(50)
);

CREATE TABLE "ort" (
	"id" SERIAL PRIMARY KEY,
	"plz" character varying(50),
	"stadt" character varying(50),
	"land_id" integer NOT NULL REFERENCES land(id)

);

CREATE TABLE "go_name" (
	"id" SERIAL PRIMARY KEY,
	"firmenname" character varying(50),
	"vorname" character varying(50),
	"nachname" character varying(50)
);

CREATE TABLE "adresse" (
	"id" SERIAL PRIMARY KEY,
	"go_name_id" integer NOT NULL REFERENCES go_name(id),
	"strasse" character varying(50),
	"hausnr" character varying(50),
	"ort_id" integer REFERENCES ort(id)
);


CREATE TABLE "geschaeftsobjekt" (
	"go_name_id" integer NOT NULL REFERENCES go_name(id),
	"adresse_id" integer REFERENCES adresse(id),
	"ist_kunde" boolean,
	"ist_lieferant" boolean
);

CREATE TABLE "programmoberflaeche" (
	"id" SERIAL PRIMARY KEY,
	"kundeerfassen" integer NOT NULL DEFAULT 1,
	"wareerfassen" integer NOT NULL DEFAULT 1,
	"rechnungerfassen" integer NOT NULL DEFAULT 1
);

-- ein angestellter kann auch programmbenutzer sein, daher pg_shadow_usesysid referenz
-- wenn angestellter programmbenutzer ist, braucht er eine programmoberflaeche
-- programmoberflaeche heist, man kann mehrere verschiedene front-end seiten bauen und auswahlen
-- welche man benutzen moechte. jeder user seine eigene, und zu jedem mandant auch nochmal eine eigene
-- weil man unterschiedliche mandanten haben kann, welche unterschiedliche aufgaben/programmoeberflaechen
-- benoetigen.
-- man kann keine system-tables referenzieren, also muss pg_shadow_usesysid mit php-code erledigt werden
CREATE TABLE "angestellte" (
	"go_name_id" integer  NOT NULL REFERENCES go_name(id),
	"adresse_id" integer REFERENCES adresse(id),
	"programmoeberflaeche_id" integer REFERENCES programmoberflaeche(id),
	"pg_shadow_usesysid" integer 
);

CREATE TABLE "kontakt" (
	"go_name_id" integer NOT NULL REFERENCES go_name(id)
);


-- ein mandant ist z.b. firma mueller, und firma schmidt, die man betreut. Man kann fuer mehrere
-- personen, firmen eine db anlegen, also in der tabelle mandant gibt es immer nur einen eintrag
-- weil eine db zu einem mandanten gehoert
CREATE TABLE "mandant" (
	"id" SERIAL PRIMARY KEY,
	"go_name_id" integer NOT NULL REFERENCES go_name(id),
	"adresse_id" integer NOT NULL REFERENCES adresse(id)
);

CREATE TABLE "hersteller" (
	"id" SERIAL PRIMARY KEY,
	"hersteller" character varying(50),
	"modell" character varying(50)
);

-- hier stehen dann die arten (in welchem auswahlfeld) ein konto stehen soll
-- problem: wenn man verschiedene user haben, die aber verschieden die konten sotieren
-- alle user greifen auf dieselbe tabelle zu
CREATE TABLE "kontenart" (
	"id" SERIAL PRIMARY KEY,
	"erloeskonto" boolean,
	"aufwandskonto" boolean
);

-- hier kommen konten wie 8400,3400 usw rein
-- in die tabelle kontenart, kann man festlegen in welchen auswahlfeldern dieses konto erscheinen soll
CREATE TABLE "konten" (
	"id" SERIAL PRIMARY KEY,
	"kontennr" integer NOT NULL,
	"kontenbezeichnung" character varying(100),
	"kontenart_id" integer REFERENCES kontenart(id)
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

CREATE TABLE "rechnung" (
	"id" SERIAL PRIMARY KEY,
	"kunde_id" integer NOT NULL REFERENCES go_name(id),
	"rechnungsdatum" date DEFAULT date ('now'::text),
	"faelligkeitsdatum" date
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



CREATE TABLE "rechnung_vo" (
	"id" SERIAL PRIMARY KEY,
	"rechnung_id" integer NOT NULL REFERENCES rechnung(id),
	"vo_id" integer NOT NULL REFERENCES verkaufsobjekt(id),
	"vo_preise_id" integer NOT NULL REFERENCES preise(id),
	"buchungskonto_id" integer NOT NULL REFERENCES konten(id),
	"anzahl" integer DEFAULT 1,
	"rabatt" integer DEFAULT 0
);

-- an welche gruppe muesste automatisch vergeben werden, der mandantenname. dann bruacht man
-- angestellte nur in diese gruppe schmeissen und sie haben nur zugriff auf diese db
-- xyz wird vom mandant-erfassen script ersetzt durch mandantenname
GRANT ALL ON kontakt TO GROUP xyz;
GRANT ALL ON waehrung TO GROUP xyz;
grant all on rechnung_bezahlt to group xyz;
grant all on rechnung_bezahlt_id_seq to group xyz;
grant all on rechnung_vo to group xyz;
grant all on rechnung to group xyz;
grant all on rechnung_id_seq to group xyz;
GRANT ALL ON go_name to group xyz;
grant all on database d to group xyz;
grant all on go_name_id_seq to group xyz; 
grant all on adresse to group xyz;
grant all on preise to group xyz;
grant all on konten to group xyz;
grant all on verkaufsobjekt to group xyz;
grant all on preise_id_seq to group xyz;
grant all on konten_id_seq to group xyz;
grant all on hersteller_id_seq to group xyz;
grant all on verkaufsobjekt_id_seq to group xyz;
grant all on vo_details_id_seq to group xyz;
GRANT ALL ON angestellte TO GROUP xyz;
