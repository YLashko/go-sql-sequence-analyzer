CREATE PROCEDURE _sp_statements_generate_tb_dataset
	@id_template INT
AS
BEGIN
	SET NOCOUNT ON
	DROP TABLE IF EXISTS #temp_statement
	CREATE TABLE #temp_statement (
		id INT PRIMARY KEY IDENTITY,
		id_statement INT,
		id_section INT,
		id_template INT,
		code NVARCHAR(250) NOT NULL,
		display_text NVARCHAR(MAX) NOT NULL,
		font_size INT,
		padding_up INT,
		padding_right INT,
		padding_bottom INT,
		padding_left INT,
		text_align NVARCHAR(50),
		bold INT,
		underline INT,
		italic INT,
		sort_order INT,
		sql_filler NVARCHAR(MAX),
		id_dataset INT
	)

	INSERT INTO #temp_statement (id_statement, id_section, id_template, code, display_text, font_size, padding_up, padding_right, padding_bottom, padding_left, text_align, bold, underline, italic, sort_order, sql_filler, id_dataset)
	SELECT 
		ts.id_statement,
		ts.id_section,
		ts.id_template,
		ts.code,
		ts.display_text,
		ts.font_size,
		ts.padding_up,
		ts.padding_right,
		ts.padding_bottom,
		ts.padding_left,
		ts.text_align,
		ts.bold,
		ts.underline,
		ts.italic,
		ts.sort_order,
		ts.sql_filler,
		td.id
	FROM _tb_statements ts
	INNER JOIN _tb_dataset td
	ON 1=1

	DECLARE @counter INT = (SELECT MIN(id) FROM #temp_statement)
	DECLARE @dataset_id INT = (SELECT id_dataset FROM #temp_statement WHERE id = @counter)

	WHILE 1=1
	BEGIN
		DECLARE @ParmDefinition NVARCHAR(100) = N'@retvalOUT NVARCHAR(MAX) OUTPUT',
				@return_value NVARCHAR(MAX),
				@sql_filler NVARCHAR(MAX) = 'SET @retvalOUT = (' + (SELECT sql_filler FROM #temp_statement ts WHERE ts.id = @counter) + ' WHERE dq.id = ' + CAST(@dataset_id AS NVARCHAR(10)) + ')'
		EXEC sp_executesql @sql_filler, @ParmDefinition, @retvalOUT = @return_value OUTPUT
		UPDATE #temp_statement SET display_text = @return_value WHERE id = @counter
		SET @dataset_id = (SELECT TOP 1 ts.id_dataset FROM #temp_statement ts WHERE ts.id > @counter ORDER BY ts.id ASC)
		SET @counter = @counter + 1
		IF @dataset_id IS NULL BREAK
	END

	INSERT INTO temp_statements (
		id_section,
		id_template,
		code,
		display_text,
		font_size,
		padding_up,
		padding_right,
		padding_bottom,
		padding_left,
		text_align,
		bold,
		underline,
		italic,
		sort_order,
		filled_text,
		id_dataset
	)
	SELECT
		ts.id_section,
		ts.id_template,
		ts.code,
		ts.display_text,
		ts.font_size,
		ts.padding_up,
		ts.padding_right,
		ts.padding_bottom,
		ts.padding_left,
		ts.text_align,
		ts.bold,
		ts.underline,
		ts.italic,
		ts.sort_order,
		ts.display_text,
		ts.id_dataset
	FROM #temp_statement ts
END
