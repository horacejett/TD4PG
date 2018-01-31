-- Function: p_mon_tri()
-- DROP FUNCTION p_mon_tri();

CREATE OR REPLACE FUNCTION p_mon_tri()
  RETURNS void AS
$BODY$
DECLARE
  /*
   Author   : Horace Jett
   Date     : 20180130
   Function : Monitor any change of triggers
  */
  
  v_cnt     INT;
  v_rec     RECORD;
  v_stime   TIMESTAMP := clock_timestamp();
  
  v_cur     CURSOR IS
    SELECT t.tgrelid, t.tgname, t.tgenabled, n.nspname, p.proname
      FROM pg_trigger t, pg_class c, pg_namespace n, pg_proc p
        WHERE t.tgrelid = c.oid
          AND t.tgfoid = p.oid
          AND c.relnamespace = n.oid
          AND t.tgisinternal = 'f';
      
BEGIN
  FOR v_rec IN v_cur LOOP
    
    -- Check record status
    SELECT m.isvalid 
      INTO v_cnt
      FROM t_mon_tri m
        WHERE m.tgrelid = v_rec.tgrelid
      LIMIT 1;
      
    -- Define v_cnt if no record returned
    v_cnt := COALESCE(v_cnt,2);
    
    IF v_cnt = 1 THEN
    
      -- Update when record is valid   
      UPDATE t_mon_tri m
         SET m.rtime = v_stime,
             m.mtime = CASE WHEN m.tgenabled = v_rec.tgenabled 
                            THEN mtime ELSE v_stime END,
             m.tgenabled = CASE WHEN m.tgenabled = v_rec.tgenabled 
                                THEN m.tgenabled ELSE v_rec.tgenabled END,
             m.remark = CASE WHEN m.tgenabled = v_rec.tgenabled 
                             THEN m.remark ELSE m.tgenabled||'>'||v_rec.tgenabled END
       WHERE m.tgrelid = v_rec.tgrelid
         AND m.isvalid = 1;
      
    ELSE

      IF v_cnt = 2 THEN
        -- Insert when record is none
        INSERT INTO t_mon_tri
            (tgrelid, tgname, tgenabled, nspname, relname, proname, 
             ctime, mtime, rtime, isvalid, remark)
          VALUES
            (v_rec.tgrelid, v_rec.tgname, v_rec.tgenabled, v_rec.nspname, v_rec.relname, v_rec.proname,
             v_stime, v_stime, v_stime, 1, 'N>'||v_rec.tgenabled);
      END IF;
      
    -- Ignore when record is invalid  
    END IF;
    
  END LOOP;
  
  -- Triggers will be regarded as deleted when record not found
  -- Add mark 'N' for deleted triggers based on original marks 'O' 'D' 'R' 'A'
  UPDATE t_mon_tri m
     SET m.rtime = v_stime,
         m.mtime = CASE WHEN m.tgenabled = 'N' 
                        THEN m.mtime ELSE v_stime END,
         m.tgenabled = 'N'
         m.remark = CASE WHEN m.tgenabled = 'N'
                         THEN m.remark ELSE m.tgenabled||'>N' END
   WHERE m.rtime < v_stime
     AND m.isvalid = 1;
     
  EXCEPTION
    WHEN OTHERS THEN
      ve_descp := SQLERRM;
      RAISE NOTICE '%',ve_descp;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
      
      
      
      
      
      
      
      