DROP TABLE IF exists historical_reviews;

create table historical_reviews(
    id INT NOT NULL AUTO_INCREMENT,
    asin VARCHAR(255) NOT NULL,
    helpful VARCHAR(255) NOT NULL,
    overall int NOT NULL,
    reviewText VARCHAR(4000) NOT NULL,
    reviewTime VARCHAR(255) NOT NULL,
    reviewerID VARCHAR(255) NOT NULL,
    reviewerName VARCHAR(255) NOT NULL,
    summary VARCHAR(255) NOT NULL,
    unixReviewTime INT NOT NULL,
    PRIMARY KEY (id),
    INDEX (asin)
);

LOAD DATA LOCAL INFILE 'kindle_reviews.csv'
INTO TABLE historical_reviews
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;