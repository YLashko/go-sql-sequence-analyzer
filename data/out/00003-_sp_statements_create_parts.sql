CREATE PROCEDURE _sp_statements_create_parts 
	@id_statement INT
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @display_text NVARCHAR(MAX) = (SELECT display_text FROM _tb_statements ts WHERE ts.id_statement = @id_statement),
			@next_open_bracket_index INT = -1,
			@next_closed_bracket_index INT = -1,
			@prev_closed_bracket_index INT

	DROP TABLE IF EXISTS #temp_parts
	CREATE TABLE #temp_parts (
		id INT PRIMARY KEY IDENTITY,
		plain_text NVARCHAR(MAX),
		variable_name NVARCHAR(250)
	)

	WHILE 1=1
	BEGIN
		SET @prev_closed_bracket_index = @next_closed_bracket_index
		SET @next_open_bracket_index = CHARINDEX('[', @display_text, @next_open_bracket_index + 1)
		SET @next_closed_bracket_index = CHARINDEX(']', @display_text, @next_closed_bracket_index + 1)

		IF @next_open_bracket_index = 0 OR @next_closed_bracket_index = 0 BREAK -- all variables found

		INSERT INTO #temp_parts (plain_text, variable_name)
		VALUES (
			SUBSTRING(@display_text, @prev_closed_bracket_index + 1, (@next_open_bracket_index - @prev_closed_bracket_index - 1)), -- from previous closed bracket excl to next open bracket excl
			SUBSTRING(@display_text, @next_open_bracket_index + 1, (@next_closed_bracket_index - @next_open_bracket_index - 1)) -- from next open bracket excl to next closed bracket excl
		)
	END

	INSERT INTO #temp_parts (plain_text, variable_name) -- udpate statements_parts to match #temp_parts
		VALUES (
			SUBSTRING(@display_text, @prev_closed_bracket_index + 1, LEN(@display_text) - @prev_closed_bracket_index), -- from previous closed bracket excl to next open bracket excl
			NULL
		)
	MERGE _tb_statements_parts sp
	USING #temp_parts tp
	ON sp.id_statement = @id_statement
		AND sp.sort_index = tp.id
	WHEN MATCHED THEN UPDATE SET
		sp.plain_text = tp.plain_text,
		sp.variable_name = tp.variable_name
	WHEN NOT MATCHED THEN INSERT
		(id_statement, plain_text, variable_name, sort_index)
		VALUES
		(@id_statement, tp.plain_text, tp.variable_name, tp.id)
	WHEN NOT MATCHED BY SOURCE AND sp.id_statement = @id_statement
	THEN DELETE;
END
