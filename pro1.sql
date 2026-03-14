CREATE OR REPLACE TRIGGER notify_high_engagement
AFTER INSERT ON Engagements1
FOR EACH ROW
BEGIN
  IF (:NEW.likes + :NEW.comments + :NEW.shares) > 300 THEN
    DBMS_OUTPUT.PUT_LINE('🔥 High engagement detected for Post ID: ' || :NEW.post_id);
  END IF;
END;
/
