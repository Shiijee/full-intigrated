USE db_attendance;

DROP TRIGGER IF EXISTS after_excuse_update;
DELIMITER //
CREATE TRIGGER after_excuse_update
AFTER UPDATE ON Excuse_Letters
FOR EACH ROW
BEGIN
    DECLARE subj_code VARCHAR(50);
    IF NEW.status != OLD.status AND NEW.status IN ('Approved', 'Rejected') THEN
        SELECT subject_code INTO subj_code FROM Subjects WHERE subject_id = NEW.subject_id LIMIT 1;
        
        INSERT INTO Notifications (user_id, message, type)
        VALUES (NEW.user_id, CONCAT('Your excuse letter for ', IFNULL(subj_code, 'a class'), ' has been ', LOWER(NEW.status), '.'), 'Info');
    END IF;
END //
DELIMITER ;
