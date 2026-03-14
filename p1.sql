set serveroutput on;
CREATE OR REPLACE PROCEDURE get_top_5_posts_by_engagement
IS
BEGIN
  DBMS_OUTPUT.PUT_LINE('Top 5 Posts by Engagement:');
  FOR post_rec IN (
    SELECT p.post_id, p.content, e.likes + e.comments + e.shares AS total_engagement
    FROM Posts p
    JOIN Engagements e ON p.post_id = e.post_id
    ORDER BY total_engagement DESC
    FETCH FIRST 5 ROWS ONLY
  ) LOOP
    DBMS_OUTPUT.PUT_LINE('Post ID: ' || post_rec.post_id || 
                         ', Content: ' || post_rec.content || 
                         ', Engagement: ' || post_rec.total_engagement);
  END LOOP;
END;
/
