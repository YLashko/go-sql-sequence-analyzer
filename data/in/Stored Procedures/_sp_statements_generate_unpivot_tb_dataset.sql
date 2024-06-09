CREATE PROCEDURE _sp_statements_generate_unpivot_tb_dataset
	@id_template INT
AS
BEGIN
	SET NOCOUNT ON
	DROP TABLE IF EXISTS #temp_out

	;WITH unpivot_dataset (id, column_code, column_value) AS (
		SELECT id, column_code, column_value FROM
		(SELECT id, var_start, var_1, var_2, var_3, var_end
		FROM _tb_dataset) td
		UNPIVOT (
    		column_value FOR column_code IN (var_start, var_1, var_2, var_3, var_end)
		) AS unpvt
	),
	statements_filled (id_dataset, id_statement, filled_text) AS ( 
		SELECT td.id, ts.id_statement, STRING_AGG(CONCAT(sp.plain_text, IIF(ISNULL(sp.variable_name, '') = '', '', ud.column_value)), '')
		FROM _tb_statements ts
		INNER JOIN _tb_dataset td 
		ON 1=1
		INNER JOIN _tb_statements_parts sp
		ON sp.id_statement = ts.id_statement
		LEFT JOIN unpivot_dataset ud
		ON ud.column_code = sp.variable_name
		AND ud.id = td.id
		GROUP BY td.id, ts.id_statement
	)

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
		sf.filled_text,
		sf.id_dataset
	FROM statements_filled sf
	INNER JOIN _tb_statements ts
	ON sf.id_statement = ts.id_statement
END
