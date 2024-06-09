CREATE TABLE _tb_statements (
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
	sql_filler NVARCHAR(MAX),
	FOREIGN KEY (id_section) REFERENCES _tb_sections (id_section)
		ON UPDATE CASCADE
		ON DELETE SET NULL,
	FOREIGN KEY (id_template) REFERENCES _tb_templates (id_template)
		ON UPDATE CASCADE
		ON DELETE SET NULL
)

CREATE NONCLUSTERED INDEX NI_tb_statements_code ON _tb_statements (code)
