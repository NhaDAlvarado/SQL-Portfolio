CREATE SCHEMA "clique_bait";

CREATE TABLE "clique_bait"."event_identifier" (
  "event_type" INTEGER,
  "event_name" VARCHAR
);

CREATE TABLE "clique_bait"."campaign_identifier" (
  "campaign_id" INTEGER,
  "products" VARCHAR,
  "campaign_name" VARCHAR,
  "start_date" TIMESTAMP,
  "end_date" TIMESTAMP
);

CREATE TABLE "clique_bait"."page_hierarchy" (
  "page_id" INTEGER,
  "page_name" VARCHAR,
  "product_category" VARCHAR,
  "product_id" INTEGER
);

CREATE TABLE "clique_bait"."users" (
  "user_id" INTEGER,
  "cookie_id" VARCHAR,
  "start_date" TIMESTAMP
);

CREATE TABLE "clique_bait"."events" (
  "visit_id" VARCHAR,
  "cookie_id" VARCHAR,
  "page_id" INTEGER,
  "event_type" INTEGER,
  "sequence_number" INTEGER,
  "event_time" TIMESTAMP
);

ALTER TABLE "clique_bait"."event_identifier" ADD FOREIGN KEY ("event_type") REFERENCES "clique_bait"."events" ("event_type");

ALTER TABLE "clique_bait"."page_hierarchy" ADD FOREIGN KEY ("page_id") REFERENCES "clique_bait"."events" ("page_id");

ALTER TABLE "clique_bait"."users" ADD FOREIGN KEY ("cookie_id") REFERENCES "clique_bait"."events" ("cookie_id");
