CREATE DATABASE instagra_db_clone;
USE instagra_db_clone;

-- creatiing tables
CREATE TABLE users(
id INT PRIMARY KEY AUTO_INCREMENT,
username VARCHAR(30) NOT NULL UNIQUE,
created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE photos(
id INT PRIMARY KEY AUTO_INCREMENT,
image_url VARCHAR(255) NOT NULL,
user_id INT NOT NULL,
created_at TIMESTAMP DEFAULT NOW(),
FOREIGN KEY(user_id) REFERENCES users(id)
);

CREATE TABLE comments(
id INT PRIMARY KEY AUTO_INCREMENT,
comment_content VARCHAR(255) NOT NULL,
user_id INT NOT NULL,
photo_id INT NOT NULL,
created_at TIMESTAMP DEFAULT NOW(),
FOREIGN KEY(user_id) REFERENCES users(id),
FOREIGN KEY(photo_id) REFERENCES photos(id)
);

CREATE TABLE likes(
user_id INT NOT NULL,
photo_id INT NOT NULL,
created_at TIMESTAMP DEFAULT NOW(),
FOREIGN KEY(user_id) REFERENCES users(id),
FOREIGN KEY(photo_id) REFERENCES photos(id),
PRIMARY KEY(user_id, photo_id)
);

CREATE TABLE follows(
follower_id INT NOT NULL, 
followee_id INT NOT NULL,
created_at TIMESTAMP DEFAULT NOW(),
FOREIGN KEY(follower_id) REFERENCES users(id),
FOREIGN KEY(followee_id) REFERENCES users(id),
PRIMARY KEY(followee_id, follower_id)
);

CREATE TABLE tags (
id INT PRIMARY KEY AUTO_INCREMENT,
tag_name VARCHAR(20) UNIQUE,
created_at TIMESTAMP DEFAULT NOW()
);


CREATE TABLE photo_tags (
photo_id INT NOT NULL,
tag_id INT NOT NULL,
FOREIGN KEY(photo_id) REFERENCES photos(id),
FOREIGN KEY(tag_id) REFERENCES tags(id),
PRIMARY KEY(tag_id, photo_id)
);




-- DATA INSERTED
-- not shown because i do not own the data(also its way too big for comments)




-- questions meant for working with data that have hundreds of lines+:

--1 find the 5 oldest users
SELECT * FROM users ORDER BY created_at LIMIT 5;

--2 what day of the week do most users register on?
SELECT DAYNAME(created_at) AS created_day, COUNT(*)
FROM users 
    GROUP BY created_day;

--3 find the users who have never posted a photo
SELECT username
FROM users
    LEFT JOIN photos ON users.id = photos.user_id
      WHERE image_url IS NULL;

--4 find the most liked photo of all time and the person who posted it
SELECT user_id, username, image_url FROM photos
    JOIN users ON users.id = photos.user_id
    WHERE photos.id=(
        SELECT photos.id
        FROM photos 
        JOIN likes ON photos.id = likes.photo_id
        GROUP BY photos.id ORDER BY COUNT(*) DESC LIMIT 1);

--5 how many times does the average user post?
SELECT (SELECT COUNT(*) FROM photos) / (SELECT COUNT(*) FROM users); 
-- alternate: gets average of all active users:
FROM (SELECT COUNT(*) AS post FROM photos GROUP BY user_id) AS posts;

--6 what are the 5 most commonly used hashtags?
SELECT tag_name, COUNT(*) AS tag_count 
FROM tags
JOIN photo_tags 
	ON tags.id = photo_tags.tag_id 
GROUP BY tags.id 
ORDER BY tag_count DESC LIMIT 5;


--7 Find users who have liked every single photo on the site
SELECT 
    username, 
    COUNT(*) AS total_likes 
FROM users
JOIN likes 
    ON users.id = likes.user_id
GROUP BY users.id
    HAVING COUNT(*) = (SELECT COUNT(*) FROM photos);




