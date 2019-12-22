LOAD DATA LOCAL INFILE 'kindle_reviews_correct_schema.csv'
INTO TABLE historical_reviews
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;