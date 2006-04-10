CREATE TABLE "land" (
	"id" SERIAL PRIMARY KEY,
	"land" character varying(50)
);

CREATE TABLE "ort" (
	"id" SERIAL PRIMARY KEY,
	"plz" character varying(50),
	"stadt" character varying(50),
	"land_id" integer REFERENCES land(id)

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
GRANT ALL ON adresse_id_seq TO GROUP xyz;
GRANT ALL ON ort TO GROUP xyz;
GRANT ALL ON ort_id_seq TO GROUP xyz;
GRANT ALL ON rechnung_vo_id_seq TO GROUP xyz;

INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('0027', 'EDV-Software');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('0090', 'Gesch�ftsbauten');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('0200', 'Techn.Anlagen und Maschinen');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('0210', 'Maschinen');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('0380', 'Sonst.Transportmittel');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('0400', 'Betriebsausstattung');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('0410', 'Gesch�ftsausstattung');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('0420', 'B�roeinrichtung');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('0430', 'Ladeneinrichtung');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('0440', 'Werkzeuge');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('0480', 'Geringwertige Wirtschaftsg.b.410EUR');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('1200', 'Bank');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('1360', 'Geldtransit');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('1400', 'Ford. a.Lieferungen und Leistungen');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('1590', 'Durchlaufende Posten');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('1600', 'Verbindlichkeiten aus Lief.u.Leist.');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('1780', 'Umsatzsteuer-Vorauszahlungen');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('1790', 'Umsatzsteuer Vorjahr');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('1791', 'Umsatzsteuer fr�here Jahre');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('1800', 'Privatentnahme allgemein');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('1810', 'Privatsteuern');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('1820', 'Sonderausgaben beschr�nkt abzugsf�hig');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('1830', 'Sonderausgaben unbeschr.anzugsf�hig');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('1840', 'Zuwendungen, Spenden');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('1890', 'Privateinlagen');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('2110', 'Zinsaufwendung f.kurzf.Verbindlichk');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('2120', 'Zinsaufwendung f.langf.Verbindlichk');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('2130', 'Diskontaufwendung');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('2310', 'Anlagenabg�nge Sachanlagen Restbuchw.b.Buchverlust');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('2315', 'Anlagenabg�nge Sachanlagen Restbuchw.b.Buchgewinn');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('2320', 'Verluste Abgang Gegenst.d.Anlagever');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('2650', 'Sonstige Zinsen und �nliche Ertr�ge');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('2720', 'Ertr.a.d.Abgang v.Gegens.d.Anlageve');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('2742', 'Versicherungsentsch�digungen');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('3000', 'Roh,-Hilfs,-und Betriebsstoffe');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('3300', 'Wareneingang 7% Vorsteuer');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('3400', 'Wareneingang 16% Vorsteuer');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('3420', 'Innergemein.Erwerb 7% VorSt u. Ust');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('3425', 'Innergem.Erwerb 16% VorSt u. Ust');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('3440', 'Innergem.Erwerb v.Neufahrz.v.Lief.o.USt.Identnr.16%VSt.u.16%USt.');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('3550', 'Steuerfreier innergem.Erwerb');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('3731', 'Erhaltene Skonti 7% Vorsteuer');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('3735', 'Erhaltene Skonti 16% Vorsteuer');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('3750', 'Erhaltene Boni 7% Vorsteuer');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('3760', 'Erhaltene Boni 16% Vorsteuer');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('3780', 'Erhaltene Rabatte 7% Vorsteuer');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('3790', 'Erhaltene Rabatte 16% Vorsteuer');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('3800', 'Bezugsnebenkosten');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('3830', 'Leergut');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('3850', 'Z�lle und Einfuhrabgaben');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('3960', 'Bestandsver.Roh-,Hilfs-.Betriebs.sow.bez.Waren');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('3970', 'Bestand Roh-,Hilfs-,u.Betriebsstoff');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('3980', 'Bestand Waren');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4000', 'Material-und Stoffverbrauch');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4110', 'L�hne');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('3990', 'Verrechnete Stoffkosten');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4120', 'Geh�lter');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4125', 'Ehegattengehalt');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4138', 'Beitr�ge zur Berufsgenossenschaft');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4139', 'Ausgleichsabgabe i.S.d.Schwerbehinterdengesetzes');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4140', 'Freiwillig soziale Aufwendungen lohnsteuerfrei');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4145', 'Freiwillige sozi.Aufw.lohnsteuerpflichtig.');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4149', 'Pauschale Lohnsteuera.sons.Bez�ge (z.B.Fahrtkostenzu)');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4150', 'Krankengeldzusch�sse');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4175', 'Fahrtkostenerst.Wohnung/Arbeitsst�t');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4190', 'Aushilfsl�hne');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4199', 'Lohnsteuer f�r Aushilfe');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4200', 'Raumkosten');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4210', 'Miete');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4220', 'Pacht');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4230', 'Heizung');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4240', 'Gas,Strom, Wasser');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4250', 'Reinigung');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4260', 'Instandhaltung betrieb.R�ume');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4280', 'Sonstige Raumkosten');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4301', 'Nicht abziehbare Vorsteuer 7%');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4305', 'Nicht abziehbare Vorsteuer 16%');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4320', 'Gewerbesteuer');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4340', 'Sonstige Betriebssteuern');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4350', 'Verbrauchssteuer');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4355', '�kosteuer');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4396', 'Steuerl.abzugs.Versp�tungszuschl.u.Zwangsgelder');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4397', 'Steuerl.n.abzugsf.Versp�tungszuschl�ge u.Zwangsgelder');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4500', 'Fahrzugkosten');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4530', 'Laufende Kfz-Betriebskosten');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8100', 'Steuerfreie Ums�tze �4Nr.8ff UstG');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8110', 'Sonstige steuerfreie Ums�tze Inland');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8300', 'Erl�se 7%USt');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4540', 'Kfz-Reparaturen');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4550', 'Garagenmiete');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4570', 'Leasingfahrzeugkosten');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4580', 'Sonstige Kfz-Kosten');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4600', 'Werbe-und Reisekosten');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4610', 'Werbekosten');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4638', 'Geschenke ausschlie�l.betrieb.genut');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4640', 'Repr�sentationskosten');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4650', 'Bewirtungskosten');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4653', 'Aufmerksamkeiten');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4654', 'Nicht abzugsf�hige Bewirtungskosten');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4660', 'Reisekosten Arbeitnehmer');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4663', 'Reisekosten Arbeitn.m.Vorsteuerabzu f.�ffentl.Verkehrsm.');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4664', 'Reisekosten Arbeitn.Verpflegungmehr');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4666', 'Reisekosten Arbeitn.�bernachtungsaufwand');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4668', 'Kilometerentgelderstattung Arbeitnehmer');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4670', 'Reisekosten Unternehmer');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4673', 'Reisek.Untern.m.Vorsteuerabzug (�ffentl.Verkehrsm.');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4674', 'Reisekosten Untern.Verpflegungsmehr');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4676', 'Reisekosten Untern.�bernachtungsauf');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4700', 'Kosten der Warenabgabe');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4710', 'Verpackungsmaterial');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4730', 'Ausgangsfracht');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4750', 'Transportversicherung');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4760', 'Verkaufsprovision');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4780', 'Fremdarbeiten');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4790', 'Aufwand f�r Gew�hrleistungen');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4800', 'Rep.u.Instandhaltungen v.techn.Anlagen u.Maschinen');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4806', 'Wartungskosten f�r Hard-u.Software');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4809', 'Sonstige Reparaturen u.Instandhalt.');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4810', 'Mietleasing');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4815', 'Kaufleasing');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4822', 'Abschreibungen a.immat.Verm�gensgeg');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4824', 'Abschreibung a.d.Gesch�ft-o.Firmenw');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4840', 'Au�erplanm��ig Abschr.a.Sachanlagen');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4855', 'Sofortabschreibung GWG');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4860', 'Abschreibungen auf aktivierte GWG');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4900', 'Sonstige betriebliche Aufwendungen');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4905', 'Sons.Aufw.betriebl. und regelm��ig');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4909', 'Fremdleistungen');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4910', 'Porto');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4920', 'Telefon');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4925', 'Telefax');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4930', 'B�robedarf');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4940', 'Zeitschriften, B�cher');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4945', 'Fortbildungskosten');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4946', 'Freiwillige Sozialleistungen');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4950', 'Rechts- und Beratungskosten');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4955', 'Buchf�hrungskosten');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4957', 'Abschlu�- und Pr�fungskosten');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4960', 'Mieten f�r Einrichtungen');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4969', 'Aufwend.f.Abraum-u.Abfallbeseitigung');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4970', 'Nebenkosten des Geldverkehrs');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4980', 'Betriebsbedarf');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4985', 'Werkzeuge und Kleinger�te');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8120', 'Steuerfreie Ums�tze �4Nr.1a UstG');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8125', 'Steuerfrei innergem. Lieferungen �41bUStG');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8130', 'Liefe.d.1.Abnehm.bei innergem.Dreiecksg �25b2UStG');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8135', 'Steuerfr.innergem.Lief.v.Neufahrz.an Abn.o.USt-Ident-Nr.');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8150', 'Sonstige steuerfreie Ums�tze �42-7UStG');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8200', 'Erl�se');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8310', 'Erl�se Inland stpfl. EG-Lieferung7%');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8315', 'Erl�s Inland stpfl.EG-Lieferung 16%');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8320', 'Erl�se aus im and.EG-Land steuerpfl.Lieferungen');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8500', 'Provisionserl�se');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8506', 'Provisionserl�se 7% USt.');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8508', 'Provisionserl�se 16% USt.');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8520', 'Erl�se Abfallverwertung');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8540', 'Erl�s Leergut');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8591', 'Sachbez�ge 7% Ust (Waren)');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8595', 'Sachbez�ge 16% Ust (Waren)');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8600', 'Sonstige Erl�se betriebl.u.regelm��');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8731', 'Gew�hrte Skonti 7% USt');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8735', 'Gew�hrte Skonti 16% USt.');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8750', 'Gew�hrte Boni 7% USt.');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8760', 'Gew�hrte Boni 16% USt.');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8780', 'Gew�hrte Rabatte 7% USt.');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8790', 'Gew�hrte Rabatte 16% Ust.');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8820', 'Erl�se aus Anlageverk�ufen Sachanl.verm.b.Buchgewinn16%Ust');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8829', 'Erl.a.Anlagenverk.bei Buchgewinn');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8900', 'Unentgeldliche Wertabgaben');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8905', 'Entnahme v. Gegenst.o.USt.');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8910', 'Entnahme des Untern.f.Zwecke ausserh.d.Untern 16%(Waren)');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8915', 'Entnah.d.Untern.f.Zwecke ausserh.d.Untern.7%USt');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8919', 'Entnahme durch den Untern.f.Zwecke au�erhalb d.Untern.(Waren)o.USt');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8924', 'Verwendung v.Gegenst�nden f.Zwecke au�erhalb d.Untern.o.USt.');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8925', 'Unentgeldl.Erbring.sons.Leis.16%USt');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8930', 'Verwendung v.Gegenst.f.Zwecke au�erhalb d.Unternehmens 7% USt.');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8935', 'Unentgeltl.Zuwend.v.Gegens. 16% Ust');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8950', 'Nicht steuerbare Ums�tze');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8955', 'Umsatzsteuerverg�tungen');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('9000', 'Saldenvertr�ge,Sachkonten');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('9008', 'Saldenvertr�ge,Debitoren');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('9009', 'Saldenvertr�ge,Kreditoren');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('9090', 'Summenvortragskonto');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8400', 'Erl�se 16% USt.');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8800', 'Erl�se aus Anlagenverk�ufen');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4380', 'Beitr�ge');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4360', 'Versicherungen');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4390', 'Sonstige Abgaben');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('0631', 'Vblk.geg.Kreditinst.- Restlaufzeit b.1 Jahr');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('0640', 'Vblk.geg.Kreditinst.- Restlaufzeit 1 bis 5 Jahre');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('0650', 'Vblk.geg.Kreditinst.- Restlaufzeit gr�sser als 5 Jahre');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4510', 'Kfz-Steuer');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4520', 'Kfz-Versicherungen');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('1771', 'Umsatzsteuer 7%');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('1775', 'Umsatzsteuer 16%');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('1767', 'Im anderen EG-Staat steuerpfl. Lieferung');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('0853', 'Satzungsm.R�cklagen 0% Vorbelast.(st.Einlagekto.)');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('1607', 'Vblk.a.LuL ohne Vorsteuer (E�R)');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('1609', 'Gegenkonto 1605-1607 b.Aufteilung d.Vblk.n.Steuers.(E�R)');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('2125', 'Zinsaufwend.f.Geb�ude,die z.Betriebsverm�gen geh�ren');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('1445', 'Ford.a.LuL z.allg.USt-Satz o.eines Kleinuntern.(E�R)');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('1446', 'Ford.aLuL z.erm.USt.-Satz (E�R)');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('1447', 'Ford.a.steuerfr.od.nicht steuerb.LuL (E�R)');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('1448', 'Ford.a.LuL n.Durchschnittss.gem.�24UStG(E�R)');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('1449', 'Gegenkto. 1445-1448 bei Aufteil.d.Ford.n.Steuers.(E�R)');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('1605', 'Vblk.a.LuL z.allg.Umsatzsteuersatz (E�R)');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('1606', 'Vblk.a.LuL zum erm.Umsatzsteuersatz (E�R)');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('2212', 'Kapitalertragssteuer 20%');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('2342', 'Einst.in SoPo m.R�cklageanteil (Existenzgr�ndungsr�cklage)');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('2351', 'Gr�ndst�cksaufwend.f.Geb�ude,die nicht z.Betriebsverm.geh�ren');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('2376', 'Grundsteuer f.Geb�ude,die nicht z.Betriebsverm�gen geh.');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('2733', 'Ertr�ge a.d.Aufl�sung v.SoPo m.R�cklageant.(Exitenzgr�ndungszusch.)');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('2746', 'Steuerfr.Ertr�ge a.d.Aufl�s.v.SoPo m.R�cklageanteil');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('2747', 'Sonst.steuerfreie Betriebseinnahmen');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('2797', 'Entnahmen a.satzungsm��igen R�cklagen');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('3559', 'Steuerfreie Einfuhren');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('3580', 'Wareneinkauf z.allg.Umsatzsteuersatz (E�R)');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('3581', 'Wareneinkauf z.erm.Umsatzsteuersatz(E�R)');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('3582', 'Wareneinkauf ohne Vorsteuerabzug(E�R)');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('3589', 'Gegenkto.3580-3582 b.Aufteilung d.WE n.Steuers�tzen(E�R)');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4261', 'Instandhlt.betriebl.R�ume in Geb.die nicht z.BV geh�ren');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4271', 'Abgaben f.betriebl.genutzten Grundbesitz,d.nicht z.BV geh�rt');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4288', 'Aufwend.f.ein h�usliches Arbeitszimmer(abziehb.Anteil)');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4289', 'Aufwend.f.ein h�usliches Arbeitszimmer(nicht abziehb.Anteil)');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4361', 'Versicherungen f.Geb�ude,die zum BV geh�ren');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4505', 'Fahrzeugkosten f.Kfz,die nicht zum BV geh�ren');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4515', 'Kfz-Steuer f.Kfz,die nicht zum BV geh�ren');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4525', 'Kfz-Versicherung f.Kfz,die nicht zum BV geh�ren');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4535', 'Lfd.Kfz-Betriebskosten f.Kfz,die nicht zum BV geh�ren');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4545', 'Kfz-Rep.f�r Kfz,die nicht zum BV geh�ren');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4555', 'Garagenmiete f.Kfz,die nicht zum BV geh�ren');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4560', 'Mautgeb�hren');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4565', 'Mautgeb�hren f. Kfz,die nicht zum BV geh�ren');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4651', 'Sonst.eingeschr.abziehb.Betriebsausgaben (abziehb.Anteil)');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4652', 'Sonst.eingeschr.abziehb.Betriebsausgaben(nicht abziehb.Teil)');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4678', 'Kilometergelderstatt.(Wohn.-Arbeitsst.abziehb.Teil)');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4679', 'Fahrten zw.Wohn.und Arbeitsst�tte (nicht abziehb.Teil)');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4680', 'Fahrten zw.Wohn.-und Arbeitsst�tte (Haben)');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4831', 'Abschreibung auf Geb�ude');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4830', 'Abschreibungen auf Sachanlagen (o.Kfz u.Geb.)');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4832', 'Abschreibungen auf Kfz');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4841', 'Absetzung f.au�ergew.techn.u.wirtschaftl.AfA bei Geb�uden');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4842', 'Absetzung f.au�ergew.techn.u.wirtschaftl.AfA des Kfz');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4843', 'Absetzung f.au�ergew.techn.u.wirtschaftl.AfA sonst.WG');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4851', 'Sonderabschreibung nach �7g(1)u.(2)EStG (ohne Kfz)');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4852', 'Sonderabschreibung n.�7g(1)u.(2)EStG (f�r Kfz)');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4965', 'Mietleasing');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4966', 'Gewerbest.zu ber�cksicht.Mietleasing �8 GewStG');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8580', 'Erl�se zum allg.Umsatzsteuersatz (E�R)');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8581', 'Erl�se zum erm�.Umsatzsteuersatz (E�R)');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8582', 'Erl�se steuerfrei u.nicht steuerbar (E�R)');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8589', 'Gegenkonto 8580-8582 b.Aufteilung d.Erl�se n.Steuers�tzen(E�R)');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8827', 'Erl�se a.Verk.Sachanlagen steuerfr.�4Nr.1aUStG(bei Buchgewinn)');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8828', 'Erl�se a.Verk.Sachanlagen steuerfr.�4Nr.1bUStG(b.Buchgewinn)');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8921', 'Verwend.v.Gegenst.f.Zwecke au�erh.d.Untern.16%USt(Kfz-Nutzung)');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8922', 'Verwend.f.Gegenst.f.Zwecke au�erh.d.Untern.16%USt(Telefonnutzung)');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('1000', 'Kasse');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('1572', 'Steuerpflicht. EG-Erwerb 7%');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('1571', 'Abziebare Vorsteuer 7%');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('1573', 'Steuerpflicht. EG-Erwerb 16%');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('1575', 'Abziehbare Vorsteuer 16%');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('1772', 'Steuerpflicht. EG-Lieferungen 7%');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('1773', 'Steuerpflicht. EG-Lieferungen 16%');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('2501', 'Ausserordentliche Ertr�ge finanzwirksam');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('2505', 'Ausserordentliche Ertr�ge nicht finanzwirksam');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4130', 'Gesetzlich soziale Aufwendungen');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4630', 'Geschenke bis 35 EUR abzugsf�hig');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4635', 'Geschenke �ber 35EUR nicht abzugsf.');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4655', 'Nicht abzugsf.Betriebsausg.a.Werbe-Repr�sentatisonk.etc.');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4805', 'Rep.u.Instandhalt.v.and.Anlagen u.Betriebs-u.Gesch�ftsausst.');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8190', 'Erl�se,die mit den Durchschnittss�tzen d.�24UStG vers.werd.');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8195', 'Erl�se als Kleinunternehmer i.S.d.�19(1)UStG');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8807', 'Erl�se a.Verk.Sachanlagen steuerfrei�4Nr.1aUStG(b.Buchverlust)');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8808', 'Erl�se a.Verk.Sachanlagen steuerfrei�4Nr.1bUStG(b.Buchverlust)');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8809', 'Erl�se aus Verk.Sachanlageverm�gen16% USt (bei Buchverlust)');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8801', 'Erl�se aus Anlagenverk�ufen Sachanl.verm.b.Buchverl.16%USt.');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8960', 'Bestandsver�nderung unf.Erz.');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8970', 'Bestandsver�nd.unf.Leist.');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8980', 'Bestandsver�nd.fert..Leist.');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8990', 'And.aktiv.Eigenleistungen');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('3090', 'Energiestoffe (Fert.).');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4595', 'Fremdfahrzeuge');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('1450', 'Ford.a.LuL n.Durchschnittss.gem.�24UStG(E�R)');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('1577', 'Abzieb.Vorst.n.allg.Durchschnittss.UStVA Kz.63');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('1578', 'Abzieb.Vorst.n.�13b');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('1580', 'Gegenkonto Vorsteuer �4/3 EStG');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('1581', 'Aufl�sung Vorst.a.Vorjahr �4/3 EStG');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('1582', 'Vorst.aus Investitionen �4/3 EStG');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('1584', 'abziehb.VorSt IG Erwerb Neufzg.b.Lief. o. USt.Ident.Nr');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('1588', 'Bezahlte Einfuhrumsatzsteuer');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('1592', 'Fremdgeld');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('3100', 'Fremdleistungen');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('3110', 'Leist.v.ausl�nd.Untern. 7% VSt.u.7%USt.');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('3120', 'Leist.v.ausl�nd.Untern. 16% VSt.u.16%USt.');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('3600', 'Nicht abziehbare Vorsteuer');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('3610', 'Nicht abziehb.Vorsteuer 7%');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('3650', 'Nicht abziehb.Vorsteuer 16%');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('2739', 'Ertr�ge Aufl. Sopo m.R.(Ansparafa)');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8590', 'Verrechnete sons. Sachbez�ge keine Waren');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8920', 'Verw.v.Gegens.f.Zwecke ausserh.d.Untern.16%USt.');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8939', 'Unentgeldl.Zuw.v.Gegens.ohne Ust');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8940', 'Unentgeltl.Zuw.v Waren 16% Ust');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8945', 'Unentgeltl.Zuw.von Waren 7% Ust');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8949', 'Unentgeltl.Zuwendung v.Waren o.USt.');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4126', 'Tantiemen');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4127', 'Gesch�ftsf�hrergeh�lter');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4167', 'Pauschale Lohnsteuer auf sonst.Bez�ge(z.B.Direktversicherung');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4170', 'Verm�genswirksame Leistungen');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4180', 'Bedienungsgelder');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4826', 'Au�erplan.AfA a.immat.Verm�gensgeg.');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4850', 'Abschr.a.Sachanl.aufgr.steuerl.Sondervorschriften');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4870', 'Abschreibungen auf Finanzanlagen');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4875', 'Abschr.a.Wertp.d.Umlaufverm�gens');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4880', 'Abschreibungen auf Umlaufverm. o.Wertpapiere (soweit un�bl.H�he');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('2208', 'Solidarit�tszuschlag');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('2209', 'Solidarit�tszuschlag f�r Vorjahr');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('2375', 'Grundsteuer');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('2400', 'Forderungsverlust-�bliche H�he');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('2401', 'Forderungsverluste 7% USt.(�bliche H�he');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('2405', 'Forderungsverluste 16% USt.(�bliche H�he');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('2341', 'Einstellungen in SoPo m.R�cklageanteil (Ansparabschreibung');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('2100', 'Zinsen und �hnl.Aufwendungen');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('2107', 'Zinsaufwendung-betriebliche Steuern �223aAO');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('2140', 'Zins�hnliche Aufwendungen');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('2000', 'Au�erordentliche Aufwendung');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('2010', 'Betriebsfremde Aufwendungen soweit n.au�erord.');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('2020', 'Periodenfremde Aufwend.(soweit n.au�erordentlich');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('2150', 'Aufwendungen aus Kursdifferenzen');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('2170', 'Nicht abziehbare Vorsteuer');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('2171', 'Nicht abziehbare Vorsteuer 7%');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('2175', 'Nicht abziehbare Vorsteuer 16%');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('2280', 'Stnachzahl.Vorj.v.Einkomm u.Ertrag');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('2285', 'Steuernachzahlung Vorj.f.sons.Steue');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('2289', 'Ertr�ge a.d.Aufl.v. R�ck.f.sons.Ste');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('2350', 'Grundst�cksaufwendungen');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('2380', 'Zuwend.,Spenden,steuerlich n.abziehbar');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('2450', 'Einstell.i.d.Pauschalwertbe.z.Forde');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('2657', 'Zinsertr�ge-betriebliche Steuern');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('2670', 'Diskontertr�ge');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('2680', 'Zins�hnliche Ertr�ge');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8650', 'Erl�se Zinsen und Diskotspesen');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8700', 'Erl�sschm�lerungen');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8710', 'Erl�sschm�lerung 7% USt.');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8720', 'Erl�sschm�lerung 16% USt.');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8725', 'Erl�sschm�.Inl.stpfl.EG-Lief. 7%USt');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8726', 'Erl�sschm�.Inl.stpfl.EG-Lief.16%USt');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('8727', 'Erl�sschm�.and.EG Land stpfl.Liefer');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('2500', 'Au�erordentliche Ertr�ge');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('2510', 'Betriebsfremde Ertr�ge nichtau�erorden');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('2520', 'Periodenfremde Ertr�ge nicht au�ero');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('2600', 'Ertr�ge aus Beteiligungen');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('2660', 'Ertr�ge aus Kursdifferenzen');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('2700', 'Sonstige Ertr�ge');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('2710', 'Ertrag a.d.Zuschreib.d.Anlageverm�g');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('2715', 'Ertr.a.Zuschreib.d.Umlaufverm�gens');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('2725', 'Ertr.a.d.Abg.v.Gegenst.d.Umlaufverm');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('2730', 'Ertr.a.Herabsetzung d.PWB zu Forderungen');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('2732', 'Ertr. aus abgeschriebenen Forderung');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('2735', 'Ertr.a.d.Aufl�sung v.R�ckstellungen');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('2743', 'Investitionszusch�sse-steuerpflicht');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('2744', 'Investitionszulage-steuerfrei');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('2750', 'Grundst�cksertr�ge');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('2284', 'Ertr.a.d.Aufl.v.R�cks.f.St.v.Ein.Er');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('2287', 'Steuererstattung Vorj.f.sons.Steuer');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('2282', 'Sterstat.Vorj.Steuer v.Eink.u.Ertrag');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('1785', 'Umsatzsteuer n.�13b UStG');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4990', 'Kalkulatorischer Unternehmerlohn');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4992', 'Kalkulatorische Zinsen');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4993', 'Kalkulatorische Aschreibungen');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4994', 'Kalkulatorische Wagnisse');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('4995', 'Kalkulatorischer Lohn f.unentgeltl.Mitarbeiter');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('2200', 'K�rperschaftssteuer');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('2214', 'Anrechenb.Soli auf Kapitalertragssteuer 20%');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('2215', 'Zinsabschlagsteuer');
INSERT INTO konten(kontennr, kontenbezeichnung) VALUES('2218', 'Anrechb.Solidari.zuschlag a.Zinsabschlagst.');
