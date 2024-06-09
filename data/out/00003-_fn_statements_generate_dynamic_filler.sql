CREATE FUNCTION _fn_statements_generate_dynamic_filler (@id_statement INT, @dataset_name NVARCHAR(250))
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @out_text_sql NVARCHAR(MAX) = (
		SELECT 'SELECT CONCAT(' +
		STRING_AGG('''' + sp.plain_text + ''', ' + 
				CASE WHEN ISNULL(sp.variable_name, '') = '' THEN ''''''
					 WHEN col.COLUMN_NAME IS NOT NULL THEN 'dq.[' + sp.variable_name + ']'
					 ELSE '''[' + sp.variable_name + ']'''
				END,
			', ')
		+ ') FROM ' + @dataset_name + ' dq'
		FROM _tb_statements_parts sp
			LEFT JOIN INFORMATION_SCHEMA.COLUMNS col
			ON col.COLUMN_NAME = sp.variable_name
		WHERE sp.id_statement = @id_statement
	)

	RETURN @out_text_sql
END
