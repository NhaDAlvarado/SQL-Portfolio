CREATE TABLE campaign_identifier (
  "campaign_id" INTEGER,
  "products" VARCHAR(3),
  "campaign_name" VARCHAR(33),
  "start_date" TIMESTAMP,
  "end_date" TIMESTAMP
);

INSERT INTO campaign_identifier
  ("campaign_id", "products", "campaign_name", "start_date", "end_date")
VALUES
  ('1', '1-3', 'BOGOF - Fishing For Compliments', '2020-01-01', '2020-01-14'),
  ('2', '4-5', '25% Off - Living The Lux Life', '2020-01-15', '2020-01-28'),
  ('3', '6-8', 'Half Off - Treat Your Shellf(ish)', '2020-02-01', '2020-03-31');
