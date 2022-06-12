CREATE TABLE IF NOT EXISTS CPQG AS 
  SELECT course_title, instructor, year, quarter, 
  COUNT(CASE WHEN grade IN ('A+', 'A', 'A-') THEN 1 END) AS count_a,
  COUNT(CASE WHEN grade IN ('B+', 'B', 'B-') THEN 1 END) AS count_b,
  COUNT(CASE WHEN grade IN ('C+', 'C', 'C-') THEN 1 END) AS count_c,
  COUNT(CASE WHEN grade IN ('D+', 'D', 'D-') THEN 1 END) AS count_d,
  COUNT(CASE WHEN grade IN ('F', 'G', 'S', 'U', 'IN') THEN 1 END) AS count_other
  FROM class_taken_in_the_past
  GROUP BY course_title, instructor, year, quarter;


CREATE OR REPLACE FUNCTION cpqg_insert() RETURNS trigger AS $cpqg_insert$
BEGIN
  IF NOT EXISTS(SELECT * FROM CPQG c 
              WHERE c.course_title = NEW.course_title AND c.instructor = NEW.instructor 
              AND c.year = NEW.year AND c.quarter = NEW.quarter) THEN
		 INSERT INTO CPQG VALUES (NEW.course_title, NEW.instructor, NEW.year, NEW.quarter,
     (CASE WHEN NEW.grade IN ('A+', 'A', 'A-') THEN 1 ELSE 0 END),
     (CASE WHEN NEW.grade IN ('B+', 'B', 'B-') THEN 1 ELSE 0 END),
     (CASE WHEN NEW.grade IN ('C+', 'C', 'C-') THEN 1 ELSE 0 END),
     (CASE WHEN NEW.grade IN ('D+', 'D', 'D-') THEN 1 ELSE 0 END),
     (CASE WHEN NEW.grade IN ('F', 'G', 'S', 'U', 'IN') THEN 1 ELSE 0 END));
  ELSE 
    UPDATE CPQG SET 
    count_a = CASE WHEN NEW.grade IN ('A+', 'A', 'A-') THEN count_a + 1 ELSE count_a END,
    count_b = CASE WHEN NEW.grade IN ('B+', 'B', 'B-') THEN count_b + 1 ELSE count_b END,
    count_c = CASE WHEN NEW.grade IN ('C+', 'C', 'C-') THEN count_c + 1 ELSE count_c END,
    count_d = CASE WHEN NEW.grade IN ('D+', 'D', 'D-') THEN count_d + 1 ELSE count_d END,
    count_other = CASE WHEN NEW.grade IN ('F', 'G', 'S', 'U', 'IN') THEN count_other + 1 ELSE count_other END
    WHERE CPQG.course_title = NEW.course_title AND CPQG.instructor = NEW.instructor AND 
    CPQG.year = NEW.year AND CPQG.quarter = NEW.quarter;
	END IF;
	RETURN NULL;
END;

$cpqg_insert$ LANGUAGE plpgsql;

CREATE TRIGGER insert_cpqg
AFTER INSERT ON class_taken_in_the_past
FOR EACH ROW
EXECUTE PROCEDURE cpqg_insert();


CREATE OR REPLACE FUNCTION cpqg_delete() RETURNS trigger AS $cpqg_delete$
BEGIN
    UPDATE CPQG SET 
    count_a = CASE WHEN OLD.grade IN ('A+', 'A', 'A-') THEN count_a - 1 ELSE count_a END,
    count_b = CASE WHEN OLD.grade IN ('B+', 'B', 'B-') THEN count_b - 1 ELSE count_b END,
    count_c = CASE WHEN OLD.grade IN ('C+', 'C', 'C-') THEN count_c - 1 ELSE count_c END,
    count_d = CASE WHEN OLD.grade IN ('D+', 'D', 'D-') THEN count_d - 1 ELSE count_d END,
    count_other = CASE WHEN OLD.grade IN ('F', 'G', 'S', 'U', 'IN') THEN count_other - 1 ELSE count_other END
    WHERE CPQG.course_title = OLD.course_title AND CPQG.instructor = OLD.instructor AND 
    CPQG.year = OLD.year AND CPQG.quarter = OLD.quarter;
	RETURN NULL;
END;

$cpqg_delete$ LANGUAGE plpgsql;

CREATE TRIGGER delete_cpqg
AFTER DELETE ON class_taken_in_the_past
FOR EACH ROW
EXECUTE PROCEDURE cpqg_delete();

CREATE OR REPLACE FUNCTION cpqg_update_only_grade() RETURNS trigger AS $cpqg_update_only_grade$
BEGIN
    UPDATE CPQG SET 
    count_a = CASE WHEN NEW.grade IN ('A+', 'A', 'A-') THEN count_a + 1 ELSE count_a END,
    count_b = CASE WHEN NEW.grade IN ('B+', 'B', 'B-') THEN count_b + 1 ELSE count_b END,
    count_c = CASE WHEN NEW.grade IN ('C+', 'C', 'C-') THEN count_c + 1 ELSE count_c END,
    count_d = CASE WHEN NEW.grade IN ('D+', 'D', 'D-') THEN count_d + 1 ELSE count_d END,
    count_other = CASE WHEN NEW.grade IN ('F', 'G', 'S', 'U', 'IN') THEN count_other + 1 ELSE count_other END
    WHERE CPQG.course_title = NEW.course_title AND CPQG.instructor = NEW.instructor AND 
    CPQG.year = NEW.year AND CPQG.quarter = NEW.quarter;

    UPDATE CPQG SET 
    count_a = CASE WHEN OLD.grade IN ('A+', 'A', 'A-') THEN count_a - 1 ELSE count_a END,
    count_b = CASE WHEN OLD.grade IN ('B+', 'B', 'B-') THEN count_b - 1 ELSE count_b END,
    count_c = CASE WHEN OLD.grade IN ('C+', 'C', 'C-') THEN count_c - 1 ELSE count_c END,
    count_d = CASE WHEN OLD.grade IN ('D+', 'D', 'D-') THEN count_d - 1 ELSE count_d END,
    count_other = CASE WHEN OLD.grade IN ('F', 'G', 'S', 'U', 'IN') THEN count_other - 1 ELSE count_other END
    WHERE CPQG.course_title = OLD.course_title AND CPQG.instructor = OLD.instructor AND 
    CPQG.year = OLD.year AND CPQG.quarter = OLD.quarter;
	
  RETURN NULL;
END;

$cpqg_update_only_grade$ LANGUAGE plpgsql;

CREATE TRIGGER update_cpqg
AFTER UPDATE ON class_taken_in_the_past
FOR EACH ROW
EXECUTE PROCEDURE cpqg_update_only_grade();













CREATE TABLE IF NOT EXISTS CPG AS 
  SELECT course_title, instructor, 
  COUNT(CASE WHEN grade IN ('A+', 'A', 'A-') THEN 1 END) AS count_a,
  COUNT(CASE WHEN grade IN ('B+', 'B', 'B-') THEN 1 END) AS count_b,
  COUNT(CASE WHEN grade IN ('C+', 'C', 'C-') THEN 1 END) AS count_c,
  COUNT(CASE WHEN grade IN ('D+', 'D', 'D-') THEN 1 END) AS count_d,
  COUNT(CASE WHEN grade IN ('F', 'G', 'S', 'U', 'IN') THEN 1 END) AS count_other
  FROM class_taken_in_the_past
  GROUP BY course_title, instructor;



CREATE OR REPLACE FUNCTION cpg_insert() RETURNS trigger AS $cpg_insert$
BEGIN
  IF NOT EXISTS(SELECT * FROM CPG c 
              WHERE c.course_title = NEW.course_title AND c.instructor = NEW.instructor) THEN
		 INSERT INTO CPG VALUES (NEW.course_title, NEW.instructor,
     (CASE WHEN NEW.grade IN ('A+', 'A', 'A-') THEN 1 ELSE 0 END),
     (CASE WHEN NEW.grade IN ('B+', 'B', 'B-') THEN 1 ELSE 0 END),
     (CASE WHEN NEW.grade IN ('C+', 'C', 'C-') THEN 1 ELSE 0 END),
     (CASE WHEN NEW.grade IN ('D+', 'D', 'D-') THEN 1 ELSE 0 END),
     (CASE WHEN NEW.grade IN ('F', 'G', 'S', 'U', 'IN') THEN 1 ELSE 0 END));
  ELSE 
    UPDATE CPG SET 
    count_a = CASE WHEN NEW.grade IN ('A+', 'A', 'A-') THEN count_a + 1 ELSE count_a END,
    count_b = CASE WHEN NEW.grade IN ('B+', 'B', 'B-') THEN count_b + 1 ELSE count_b END,
    count_c = CASE WHEN NEW.grade IN ('C+', 'C', 'C-') THEN count_c + 1 ELSE count_c END,
    count_d = CASE WHEN NEW.grade IN ('D+', 'D', 'D-') THEN count_d + 1 ELSE count_d END,
    count_other = CASE WHEN NEW.grade IN ('F', 'G', 'S', 'U', 'IN') THEN count_other + 1 ELSE count_other END
    WHERE CPG.course_title = NEW.course_title AND CPG.instructor = NEW.instructor;
	END IF;
	RETURN NULL;
END;

$cpg_insert$ LANGUAGE plpgsql;

CREATE TRIGGER insert_cpg
AFTER INSERT ON class_taken_in_the_past
FOR EACH ROW
EXECUTE PROCEDURE cpg_insert();


CREATE OR REPLACE FUNCTION cpg_delete() RETURNS trigger AS $cpg_delete$
BEGIN
    UPDATE CPG SET 
    count_a = CASE WHEN OLD.grade IN ('A+', 'A', 'A-') THEN count_a - 1 ELSE count_a END,
    count_b = CASE WHEN OLD.grade IN ('B+', 'B', 'B-') THEN count_b - 1 ELSE count_b END,
    count_c = CASE WHEN OLD.grade IN ('C+', 'C', 'C-') THEN count_c - 1 ELSE count_c END,
    count_d = CASE WHEN OLD.grade IN ('D+', 'D', 'D-') THEN count_d - 1 ELSE count_d END,
    count_other = CASE WHEN OLD.grade IN ('F', 'G', 'S', 'U', 'IN') THEN count_other - 1 ELSE count_other END
    WHERE CPG.course_title = OLD.course_title AND CPG.instructor = OLD.instructor;
	RETURN NULL;
END;

$cpg_delete$ LANGUAGE plpgsql;

CREATE TRIGGER delete_cpg
AFTER DELETE ON class_taken_in_the_past
FOR EACH ROW
EXECUTE PROCEDURE cpg_delete();


CREATE OR REPLACE FUNCTION cpg_update_only_grade() RETURNS trigger AS $cpg_update_only_grade$
BEGIN
    UPDATE CPG SET 
    count_a = CASE WHEN NEW.grade IN ('A+', 'A', 'A-') THEN count_a + 1 ELSE count_a END,
    count_b = CASE WHEN NEW.grade IN ('B+', 'B', 'B-') THEN count_b + 1 ELSE count_b END,
    count_c = CASE WHEN NEW.grade IN ('C+', 'C', 'C-') THEN count_c + 1 ELSE count_c END,
    count_d = CASE WHEN NEW.grade IN ('D+', 'D', 'D-') THEN count_d + 1 ELSE count_d END,
    count_other = CASE WHEN NEW.grade IN ('F', 'G', 'S', 'U', 'IN') THEN count_other + 1 ELSE count_other END
    WHERE CPG.course_title = NEW.course_title AND CPG.instructor = NEW.instructor;

    UPDATE CPG SET 
    count_a = CASE WHEN OLD.grade IN ('A+', 'A', 'A-') THEN count_a - 1 ELSE count_a END,
    count_b = CASE WHEN OLD.grade IN ('B+', 'B', 'B-') THEN count_b - 1 ELSE count_b END,
    count_c = CASE WHEN OLD.grade IN ('C+', 'C', 'C-') THEN count_c - 1 ELSE count_c END,
    count_d = CASE WHEN OLD.grade IN ('D+', 'D', 'D-') THEN count_d - 1 ELSE count_d END,
    count_other = CASE WHEN OLD.grade IN ('F', 'G', 'S', 'U', 'IN') THEN count_other - 1 ELSE count_other END
    WHERE CPG.course_title = OLD.course_title AND CPG.instructor = OLD.instructor;
	
  RETURN NULL;
END;

$cpg_update_only_grade$ LANGUAGE plpgsql;

CREATE TRIGGER update_cpg
AFTER UPDATE ON class_taken_in_the_past
FOR EACH ROW
EXECUTE PROCEDURE cpg_update_only_grade();





