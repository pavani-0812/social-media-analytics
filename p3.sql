CREATE OR REPLACE PROCEDURE get_monthly_user_growth (
  p_year IN INT
) IS
BEGIN
  FOR rec IN (
    SELECT TO_CHAR(joined_date, 'MM') AS month,
           COUNT(*) AS new_users
    FROM Users
    WHERE EXTRACT(YEAR FROM joined_date) = p_year
    GROUP BY TO_CHAR(joined_date, 'MM')
    ORDER BY month
  ) LOOP
    DBMS_OUTPUT.PUT_LINE('Month: ' || rec.month || ' | New Users: ' || rec.new_users);
  END LOOP;
END;
/
