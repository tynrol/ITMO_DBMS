Select * from ALL_TAB_COLUMNS where OWNER = 'ISU_UCHEB'; /* table_name, column_name, data_type, data_length, nullable */
Select * from ALL_COL_COMMENTS where OWNER = 'ISU_UCHEB'; /* table_name, column_name, comments */

Select * from ALL_CONS_COLUMNS where OWNER = 'ISU_UCHEB'; /* constraint_name, table_name, column_name */
Select * from ALL_CONSTRAINTS where OWNER = 'ISU_UCHEB'; /* constraint_name, constraint_type, table_name, search_condition */

Select * from ALL_IND_COLUMNS where INDEX_OWNER = 'ISU_UCHEB'; /* index_name, table_name, column_name */
Select * from ALL_INDEXES where OWNER = 'ISU_UCHEB'; /* index_name, index_type, table_name */

Select COLUMN_NAME, TABLE_NAME, DATA_TYPE, DATA_LENGTH from ALL_TAB_COLUMNS
    where OWNER = 'ISU_UCHEB';
Select ALL_CONSTRAINTS.CONSTRAINT_NAME, CONSTRAINT_TYPE, SEARCH_CONDITION, R_CONSTRAINT_NAME from ALL_CONSTRAINTS
    inner join ALL_CONS_COLUMNS on ALL_CONSTRAINTS.CONSTRAINT_NAME = ALL_CONS_COLUMNS.CONSTRAINT_NAME;
Select INDEX_NAME from ALL_IND_COLUMNS;
Select COMMENTS from ALL_COL_COMMENTS where COLUMN_NAME='ПЛАН_ИД' and TABLE_NAME='Н_ГРУППЫ_ПЛАНОВ';


Declare
    cursor result is
        Select ALL_TAB_COLUMNS.COLUMN_NAME, ALL_TAB_COLUMNS.TABLE_NAME, DATA_TYPE, DATA_LENGTH, COMMENTS from ALL_TAB_COLUMNS
        inner join ALL_COL_COMMENTS on (ALL_TAB_COLUMNS.TABLE_NAME = ALL_COL_COMMENTS.TABLE_NAME and ALL_TAB_COLUMNS.COLUMN_NAME = ALL_COL_COMMENTS.COLUMN_NAME)
        where ALL_TAB_COLUMNS.OWNER = 'ISU_UCHEB';
    No_len Number :=3;
    Col_len Number := 33;
    Tab_len Number := 33;
    Atr_len Number := 233;

    No Number := 0;
    Table_name varchar2(128) := '';
    Column_name varchar2(128) := '';
    Atr varchar2(128) := '';

    Constraint varchar2(128) := '';
    Reference varchar2(128) := '';
    Commen varchar2(200) := '';
    Ind varchar2(128) := '';
    First boolean := True;


begin
    DBMS_OUTPUT.PUT_LINE(RPAD('No.',No_len)||' '||RPAD('Имя столбца',Col_len)||' '||RPAD('Имя таблицы',Tab_len)||' '||RPAD('Атрибуты',Atr_len));
    DBMS_OUTPUT.PUT_LINE(RPAD('-',No_len,'-')||' '||RPAD('-',Col_len,'-')||' '||RPAD('-',Tab_len,'-')||' '||RPAD('-',Atr_len,'-'));
    for Row in result loop
        No := No+1;
        First := True;
        Column_name := Row.COLUMN_NAME;
        Table_name := Row.TABLE_NAME;
        Atr := 'Type  : '||TO_CHAR(Row.DATA_TYPE)||'('||TO_CHAR(Row.DATA_LENGTH)||')';
        DBMS_OUTPUT.PUT_LINE(RPAD(TO_CHAR(No),No_len)||' '||RPAD(Column_name,Col_len)||' '||RPAD(Table_name,Tab_len)||' '||RPAD(Atr,Atr_len));
        for Constraints in (
            Select ALL_CONSTRAINTS.CONSTRAINT_NAME, CONSTRAINT_TYPE, SEARCH_CONDITION, R_CONSTRAINT_NAME, ALL_CONSTRAINTS.TABLE_NAME from ALL_CONSTRAINTS
            inner join ALL_CONS_COLUMNS on ALL_CONSTRAINTS.CONSTRAINT_NAME = ALL_CONS_COLUMNS.CONSTRAINT_NAME
            where ALL_CONS_COLUMNS.TABLE_NAME = Row.TABLE_NAME
            and ALL_CONS_COLUMNS.COLUMN_NAME = Row.COLUMN_NAME
            and ALL_CONSTRAINTS.OWNER = 'ISU_UCHEB'
            ) loop
            if First then
                DBMS_OUTPUT.PUT_LINE(RPAD('. ',No_len)||' '||RPAD(' ',Col_len+Tab_len+1,' ')||' '||RPAD('Constr: CONSTRAINT',Atr_len));
                First := False;
            end if;
            if Constraints.CONSTRAINT_TYPE = 'C' then
                Constraint := '"'||Constraints.CONSTRAINT_NAME||'" '||Constraints.SEARCH_CONDITION;
                DBMS_OUTPUT.PUT_LINE(RPAD('. ',No_len)||' '||RPAD(' ',Col_len+Tab_len+8,' ')||' '||RPAD(Constraint,Atr_len));
            end if;
            if Constraints.CONSTRAINT_TYPE = 'P' then
                Constraint := '"'||Constraints.CONSTRAINT_NAME||'" '||'PRIMARY KEY';
                DBMS_OUTPUT.PUT_LINE(RPAD('. ',No_len)||' '||RPAD(' ',Col_len+Tab_len+8,' ')||' '||RPAD(Constraint,Atr_len));
            end if;
            if Constraints.CONSTRAINT_TYPE = 'R' then
                for Reference in (
                Select COLUMN_NAME from ALL_CONS_COLUMNS
                where CONSTRAINT_NAME = Constraints.R_CONSTRAINT_NAME
                  and TABLE_NAME = Constraints.TABLE_NAME
                  and OWNER = 'ISU_UCHEB'
                ) loop
                Constraint := '"'||Constraints.CONSTRAINT_NAME||'" '||'REFERENCES '||Constraints.TABLE_NAME||' ('||Reference.COLUMN_NAME||')';
                DBMS_OUTPUT.PUT_LINE(RPAD('. ',No_len)||' '||RPAD(' ',Col_len+Tab_len+8,' ')||' '||RPAD(Constraint,Atr_len));
                end loop;
            end if;
            if Constraints.CONSTRAINT_TYPE = 'U' then
                Constraint := '"'||Constraints.CONSTRAINT_NAME||'" '||'UNIQUE KEY';
                DBMS_OUTPUT.PUT_LINE(RPAD('. ',No_len)||' '||RPAD(' ',Col_len+Tab_len+8,' ')||' '||RPAD(Constraint,Atr_len));
            end if;
        end loop;
        Commen := 'Commen: '||'"'||Row.COMMENTS||'"';
        DBMS_OUTPUT.PUT_LINE(RPAD('. ',No_len)||' '||RPAD(' ',Col_len+Tab_len+1,' ')||' '||RPAD(Commen,Atr_len));
        First := True;
        for Inds in (
            Select INDEX_NAME from ALL_IND_COLUMNS
            where TABLE_NAME = Row.TABLE_NAME
            and COLUMN_NAME = Row.COLUMN_NAME
            and INDEX_OWNER = 'ISU_UCHEB'
        ) loop
            if First then
                Ind := 'Index : '||'"'||Inds.INDEX_NAME||'"';
                DBMS_OUTPUT.PUT_LINE(RPAD('. ',No_len)||' '||RPAD(' ',Col_len+Tab_len+1,' ')||' '||RPAD(Ind,Atr_len));
                First := False;
            else
                Ind := '"'||Inds.INDEX_NAME||'"';
                DBMS_OUTPUT.PUT_LINE(RPAD('. ',No_len)||' '||RPAD(' ',Col_len+Tab_len+8,' ')||' '||RPAD(Ind,Atr_len));
            end if;
        end loop;
    end loop;
end;

