EXEC _sp_statements_create_parts 9

SELECT SUM(LEN(display_text) / 18.0) FROM _tb_statements ts
SELECT * FROM _tb_statements ts
SELECT * FROM _tb_statements_parts tsp

DECLARE @out NVARCHAR(MAX)
EXEC _sp_statements_agg_text 9, '_tb_dataset', @out OUTPUT
PRINT @out

PRINT dbo._fn_statements_generate_dynamic_filler(9, '_tb_dataset')

EXEC _sp_statements_create_parts_for_template 1
EXEC _sp_statements_create_fillers 1, NULL, '_tb_dataset'

DROP TABLE IF EXISTS temp_statements
CREATE TABLE temp_statements (
	id_statement INT PRIMARY KEY IDENTITY,
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
	filled_text NVARCHAR(MAX),
	id_dataset INT
)
TRUNCATE TABLE temp_statements
SELECT * FROM temp_statements


DECLARE @c INT = 0
WHILE @c < 20000
BEGIN
	EXEC _sp_statements_generate_tb_dataset 1
	UPDATE _tb_dataset
	SET var_start = IIF(len(var_start) > 80, SUBSTRING(var_start, 1, len(var_start) - 1), var_start + CAST(@c AS NVARCHAR(100)))
	SET @c = @c + 1
END

DECLARE @c2 INT = 0
WHILE @c2 < 20000
BEGIN
	EXEC _sp_statements_generate_unpivot_tb_dataset 1
	UPDATE _tb_dataset
	SET var_start = IIF(len(var_start) > 80, SUBSTRING(var_start, 1, len(var_start) - 1), var_start + CAST(@c2 AS NVARCHAR(100)))
	SET @c2 = @c2 + 1
END

DECLARE @ParmDefinition NVARCHAR(100) = N'@retvalOUT NVARCHAR(MAX) OUTPUT',
		@return_value NVARCHAR(MAX)
EXEC sp_executesql @out_text_sql, @ParmDefinition, @retvalOUT = @return_value OUTPUT

SELECT * FROM _tb_dataset td

SELECT * FROM _tb_statements ts WHERE ts.id_statement = 9
SELECT * FROM _tb_statements_parts tsp
