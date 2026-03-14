-- ======================================================
-- Project Title: Social Media Analytics Database
-- Description: Comprehensive system to manage and analyze
--              social media interactions and engagement.
-- ======================================================

-- 1. TABLE CREATION
---------------------------------------------------------

-- Users Table: Tracks social media handles and account info
CREATE TABLE users (
    user_id INT PRIMARY KEY,
    username VARCHAR2(255) NOT NULL,
    joined_date DATE,
    country VARCHAR2(100)
);

-- Posts Table: Tracks content and hashtags per user
CREATE TABLE Posts (
    post_id INT PRIMARY KEY,
    user_id INT,
    content VARCHAR2(1000),
    post_date DATE,
    hashtags VARCHAR2(500),
    CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- Engagements Table: Tracks likes, comments, and shares per post
CREATE TABLE Engagements1 (
    engagement_id INT PRIMARY KEY,
    post_id INT,
    likes INT,
    comments INT,
    shares INT,
    CONSTRAINT fk_post FOREIGN KEY (post_id) REFERENCES Posts(post_id)
);

-- Engagement Summary Table (Required for Trigger 3)
CREATE TABLE Engagement_Summary (
    post_id INT PRIMARY KEY,
    total_likes INT,
    total_comments INT,
    total_shares INT
);

-- 2. DATA INSERTION (SAMPLES)
---------------------------------------------------------
INSERT INTO users (user_id, username, joined_date, country) VALUES (1, '@user1', TO_DATE('2021-01-01', 'YYYY-MM-DD'), 'USA');
INSERT INTO users (user_id, username, joined_date, country) VALUES (2, '@user2', TO_DATE('2021-01-02', 'YYYY-MM-DD'), 'Canada');
INSERT INTO users (user_id, username, joined_date, country) VALUES (3, '@user3', TO_DATE('2021-01-03', 'YYYY-MM-DD'), 'UK');
INSERT INTO users (user_id, username, joined_date, country) VALUES (4, '@user4', TO_DATE('2021-01-04', 'YYYY-MM-DD'), 'India');
INSERT INTO users (user_id, username, joined_date, country) VALUES (5, '@user5', TO_DATE('2021-01-05', 'YYYY-MM-DD'), 'Australia');

INSERT INTO Posts (post_id, user_id, content, post_date, hashtags) VALUES (101, 1, 'Post content 1', TO_DATE('2023-01-01', 'YYYY-MM-DD'), '#tag1, #tag2');
INSERT INTO Posts (post_id, user_id, content, post_date, hashtags) VALUES (102, 2, 'Post content 2', TO_DATE('2023-01-02', 'YYYY-MM-DD'), '#tag2, #tag3');

INSERT INTO Engagements1 (engagement_id, post_id, likes, comments, shares) VALUES (1, 101, 120, 20, 10);
INSERT INTO Engagements1 (engagement_id, post_id, likes, comments, shares) VALUES (2, 102, 130, 22, 11);

-- 3. TRIGGERS
---------------------------------------------------------

-- Trigger 1: Notify on high-performing posts (>300 total engagement)
CREATE OR REPLACE TRIGGER notify_high_engagement
AFTER INSERT ON Engagements1
FOR EACH ROW
BEGIN
    IF (:NEW.likes + :NEW.comments + :NEW.shares) > 300 THEN
        DBMS_OUTPUT.PUT_LINE('High engagement detected for Post ID: ' || :NEW.post_id);
    END IF;
END;
/

-- Trigger 2: Auto-update engagement summary table
CREATE OR REPLACE TRIGGER trg_update_engagement_summary
AFTER INSERT ON Engagements1
FOR EACH ROW
DECLARE
    v_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM Engagement_Summary WHERE post_id = :NEW.post_id;
    IF v_count = 0 THEN
        INSERT INTO Engagement_Summary (post_id, total_likes, total_comments, total_shares)
        VALUES (:NEW.post_id, :NEW.likes, :NEW.comments, :NEW.shares);
    ELSE
        UPDATE Engagement_Summary
        SET total_likes = total_likes + :NEW.likes,
            total_comments = total_comments + :NEW.comments,
            total_shares = total_shares + :NEW.shares
        WHERE post_id = :NEW.post_id;
    END IF;
END;
/

-- 4. PROCEDURES
---------------------------------------------------------

-- Procedure 1: Fetch top 5 posts by total engagement
CREATE OR REPLACE PROCEDURE get_top_5_posts IS
BEGIN
    FOR rec IN (
        SELECT p.post_id, (e.likes + e.comments + e.shares) AS total_engagement
        FROM Posts p
        JOIN Engagements1 e ON p.post_id = e.post_id
        ORDER BY total_engagement DESC
        FETCH FIRST 5 ROWS ONLY
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Post ID: ' || rec.post_id || ' | Engagement: ' || rec.total_engagement);
    END LOOP;
END;
/

-- Procedure 2: Insert new post with hashtags
CREATE OR REPLACE PROCEDURE insert_post (
    p_post_id IN INT,
    p_user_id IN INT,
    p_content IN CLOB,
    p_post_date IN DATE,
    p_hashtags IN VARCHAR2
) IS
BEGIN
    INSERT INTO Posts (post_id, user_id, content, post_date, hashtags)
    VALUES (p_post_id, p_user_id, p_content, p_post_date, p_hashtags);
END;
/

-- 5. VIEWS
---------------------------------------------------------

-- View 1: Daily post engagement statistics
CREATE OR REPLACE VIEW PostEngagementSummary AS
SELECT p.post_id, p.content, p.post_date, u.username,
       (e.likes + e.comments + e.shares) AS total_engagement
FROM Posts p
JOIN users u ON p.user_id = u.user_id
JOIN Engagements1 e ON p.post_id = e.post_id;

-- View 2: Trending posts (> 300 engagement)
CREATE OR REPLACE VIEW TopPerformingPosts AS
SELECT * FROM PostEngagementSummary WHERE total_engagement > 300;

-- View 3: User-wise engagement summary
CREATE OR REPLACE VIEW UserActivity AS
SELECT u.user_id, u.username, COUNT(DISTINCT p.post_id) AS total_posts,
       SUM(e.likes + e.comments + e.shares) AS total_engagements
FROM users u
JOIN Posts p ON u.user_id = p.user_id
JOIN Engagements1 e ON p.post_id = e.post_id
GROUP BY u.user_id, u.username;

-- 6. ANALYTICS QUERIES
---------------------------------------------------------

-- Query: Country-wise social media engagement trend
SELECT u.country, SUM(e.likes) AS total_likes, SUM(e.comments) AS total_comments, SUM(e.shares) AS total_shares
FROM users u
JOIN Posts p ON u.user_id = p.user_id
JOIN Engagements1 e ON p.post_id = e.post_id
GROUP BY u.country
ORDER BY total_likes DESC;

-- Query: Hashtags with highest average likes
SELECT p.hashtags, AVG(e.likes) AS avg_likes
FROM Posts p
JOIN Engagements1 e ON p.post_id = e.post_id
GROUP BY p.hashtags
ORDER BY avg_likes DESC;