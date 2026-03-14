CREATE OR REPLACE PROCEDURE insert_post (
  p_post_id   IN INT,
  p_user_id   IN INT,
  p_content   IN CLOB,
  p_post_date IN DATE,
  p_hashtags  IN VARCHAR2
) IS
BEGIN
  INSERT INTO Posts (post_id, user_id, content, post_date, hashtags)
  VALUES (p_post_id, p_user_id, p_content, p_post_date, p_hashtags);
END;
/
