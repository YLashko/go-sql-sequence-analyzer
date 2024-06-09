CREATE PROCEDURE _sp_statements_create_parts_for_template -- create parts for all statements from a single template
	@id_template INT
AS
BEGIN
	DROP TABLE IF EXISTS #statements_to_update
	SELECT ts.id_statement INTO #statements_to_update FROM _tb_statements ts

	DECLARE @statement_counter INT = (SELECT MIN(id_statement) FROM #statements_to_update stu)
	WHILE 1=1
	BEGIN
		EXEC _sp_statements_create_parts @statement_counter
		SET @statement_counter = (
			SELECT TOP 1 stu.id_statement 
			FROM #statements_to_update stu
			WHERE stu.id_statement > @statement_counter
			ORDER BY stu.id_statement ASC
		)
		IF @statement_counter IS NULL BREAK
	END
END
