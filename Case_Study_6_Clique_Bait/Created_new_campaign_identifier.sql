create table new_campaign_identifier (
	"campaign_id" INTEGER,
  "product_id" integer,
  "campaign_name" VARCHAR(33),
  "start_date" TIMESTAMP,
  "end_date" TIMESTAMP
);

INSERT INTO new_campaign_identifier
  ("campaign_id", "product_id", "campaign_name", "start_date", "end_date")
VALUES
(1, 1, 'BOGOF - Fishing For Compliments', '2020-01-01', '2020-01-14'),
(1, 2, 'BOGOF - Fishing For Compliments', '2020-01-01', '2020-01-14'),
(1, 3, 'BOGOF - Fishing For Compliments', '2020-01-01', '2020-01-14'),
(2, 4, '25% Off - Living The Lux Life', '2020-01-15', '2020-01-28'),
(2, 5, '25% Off - Living The Lux Life', '2020-01-15', '2020-01-28'),
(3, 6, 'Half Off - Treat Your Shellf(ish)', '2020-02-01', '2020-03-31'),
(3, 7, 'Half Off - Treat Your Shellf(ish)', '2020-02-01', '2020-03-31'),
(3, 8, 'Half Off - Treat Your Shellf(ish)', '2020-02-01', '2020-03-31');
