## Statements generation

### Comparing execution speed for:
- One template containing 18 statements, 120 to 180 characters each (0-5 variables each), 132 characters on average;
- Source dataset contains 2 rows;
- The template is generated 20,000 times, the result of computation is stored in a table

In total, we get 720,000 rows or ~95,040,000 characters.

#### 1 method:
Storing precomputed sql filler queries for each row and running them one by one when filling templates - 00:01:21 (1 minute 21 seconds)

#### 2 method:
Dividing statements in 'parts' each part containing a piece of text and a variable that is located after this piece of text, then unpivoting the dataset, joining it to statements parts and doing string aggregation - 00:00:30 (30 seconds)
