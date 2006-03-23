-- go_ steht fuer geschaeftsobjekt, womit kunden/lieferanten/kontakte mit gemeint sind. kontakte muessen 
-- nichts kaufen/verkaufen sie koennen einfach nur gespeichert sein.
CREATE TABLE "go_name" (
	"id" SERIAL PRIMARY KEY,
	"firmenname" character varying(50),
	"vorname" character varying(50),
	"nachname" character varying(50)
);

-- die wurzel aller geschaefte. Diese muss mindestens einen namen (name_id) besitzen, welcher wiederrum ein
-- firmenname und/oder ein privatpersonen-name sein MUSS.
CREATE TABLE "geschaeftsobjekt" (
	"name_id" integer NOT NULL REFERENCES go_name(id),
	"adresse_id" integer
);

-- tabelle fuer loginname und passwort, damit man diese tabelle extra sperren kann, wenn noetig
CREATE TABLE "login_info" (
	"id" integer NOT NULL REFERENCES go_name(id),
	"loginname" character varying(20),
	"passwort" character varying(20)
);

-- angestelleter bruacht kein login_info, also kann einfach nur z.b. kassenverkaeufer sein
CREATE TABLE "angestellte" (
	"login_info_id" integer,
	"name_id" integer  NOT NULL REFERENCES go_name(id)
);
	

