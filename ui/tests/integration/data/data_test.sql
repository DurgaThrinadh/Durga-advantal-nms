-- Disable host "Advantal server"
UPDATE hosts SET status=1 WHERE host='Advantal server';
-- clear changelog table
TRUNCATE TABLE changelog;

