CREATE OR REPLACE TRIGGER trg_update_engagement_summary
AFTER INSERT ON Engagements
FOR EACH ROW
DECLARE
  v_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_count
  FROM Engagement_Summary
  WHERE post_id = :NEW.post_id;

  IF v_count = 0 THEN
    INSERT INTO Engagement_Summary (post_id, total_likes, total_comments, total_shares)
    VALUES (:NEW.post_id, :NEW.likes, :NEW.comments, :NEW.shares);
  ELSE
    UPDATE Engagement_Summary
    SET total_likes    = total_likes + :NEW.likes,
        total_comments = total_comments + :NEW.comments,
        total_shares   = total_shares + :NEW.shares
    WHERE post_id = :NEW.post_id;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    -- Log or handle errors if necessary, else just re-raise
    RAISE;
END;
/
