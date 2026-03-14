DECLARE
  v_hashtags VARCHAR2(100) := '#one,#two,#three,#four,#five,#six';
  v_count NUMBER;
BEGIN
  v_count := LENGTH(v_hashtags) - LENGTH(REPLACE(v_hashtags, ',', '')) + 1;
  
  IF v_count > 5 THEN
    DBMS_OUTPUT.PUT_LINE('❌ More than 5 hashtags are not allowed.');
  ELSE
    DBMS_OUTPUT.PUT_LINE('✅ Hashtag count is acceptable: ' || v_count);
  END IF;
END;
/
