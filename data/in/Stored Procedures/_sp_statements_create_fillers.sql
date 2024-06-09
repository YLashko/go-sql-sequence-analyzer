CREATE PROCEDURE _sp_statements_create_fillers
	@id_template INT,
	@id_statement INT = NULL,
	@dataset_name NVARCHAR(250)
AS
BEGIN
	UPDATE s SET
		s.sql_filler = dbo._fn_statements_generate_dynamic_filler(s.id_statement, @dataset_name)
	FROM _tb_statements s
	WHERE s.id_template = @id_template
	AND (@id_statement IS NULL OR ISNULL(@id_statement, -1) = s.id_statement)
END
