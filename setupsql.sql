DROP TABLE IF exists historical_reviews;

CREATE TABLE `historical_reviews` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `asin` varchar(20) NOT NULL,
  `helpful_rating` int(11) DEFAULT NULL,
  `total_helpful_rating` int(11) DEFAULT NULL,
  `review_rating` int(11) DEFAULT NULL,
  `review_text` text,
  `summary_text` varchar(15000) DEFAULT NULL,
  `username` varchar(200) DEFAULT NULL,
  `reviewer_id` varchar(200) DEFAULT NULL,
  `date_time` datetime DEFAULT NULL,
  `unix_timestamp` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_historical_reviews_asin` (`asin`)
);

LOAD DATA LOCAL INFILE 'kindle_reviews_correct_schema.csv'
INTO TABLE historical_reviews
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;