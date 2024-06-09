CREATE TABLE _tb_statements_parts (
	id_part INT PRIMARY KEY IDENTITY,
	id_statement INT,
	plain_text NVARCHAR(MAX),
	variable_name NVARCHAR(250),
	sort_index INT,
	FOREIGN KEY (id_statement) REFERENCES _tb_statements (id_statement)
		ON UPDATE CASCADE
		ON DELETE SET NULL
)

CREATE NONCLUSTERED INDEX NI_tb_statements_parts_variable_name ON _tb_statements_parts (variable_name) 
