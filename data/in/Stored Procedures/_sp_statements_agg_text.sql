CREATE PROCEDURE _sp_statements_agg_text
	@id_statement INT,
	@data_query NVARCHAR(1000),
	@out_text NVARCHAR(MAX) OUTPUT
AS
BEGIN
	DECLARE @out_text_sql NVARCHAR(MAX) = (
		SELECT 'SELECT @retvalOUT = (SELECT CONCAT(' +
		STRING_AGG('''' + sp.plain_text + ''', ' + 
				IIF(ISNULL(sp.variable_name, '') = '', '''''', 'dq.[' + sp.variable_name + ']'),
			', ')
		+ ') FROM ' + @data_query + ' dq)'
		FROM _tb_statements_parts sp
		WHERE sp.id_statement = @id_statement
	)

	DECLARE @ParmDefinition NVARCHAR(100) = N'@retvalOUT NVARCHAR(MAX) OUTPUT',
			@return_value NVARCHAR(MAX)
	EXEC sp_executesql @out_text_sql, @ParmDefinition, @retvalOUT = @return_value OUTPUT
	SELECT @out_text = @return_value
END
