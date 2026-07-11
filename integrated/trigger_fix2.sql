USE db_attendance;

DROP TRIGGER IF EXISTS after_attendance_insert;
DELIMITER //
CREATE TRIGGER after_attendance_insert
AFTER INSERT ON Attendance
FOR EACH ROW
BEGIN
    DECLARE subj_code VARCHAR(50);
    
    -- Corrected query to use the 'sessions' table
    SELECT s.subject_code INTO subj_code
    FROM sessions ses
    JOIN Subjects s ON ses.subject_id = s.subject_id
    JOIN Subjects s ON ses.subject_id = s.subject_id
    WHERE ses.session_id = NEW.session_id LIMIT 1;
    
    INSERT INTO Notifications (user_id, message, type)
    VALUES (NEW.user_id, CONCAT('Your attendance for ', IFNULL(subj_code, 'a class'), ' has been recorded as ', NEW.status, '.'), 'Info');
END //
DELIMITER ;
