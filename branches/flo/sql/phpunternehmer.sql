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
	"pg_shadow_usesysid" integer
);
