--- CREATE TABLES: regions, customers, transactions
CREATE TABLE bank_data..regions (
	region_id CHAR(4) NOT NULL,
	region_name VARCHAR(10) NOT NULL,
	PRIMARY KEY(region_id));

CREATE TABLE bank_data..customers (
	customer_id CHAR(4) NOT NULL,
	region_id CHAR(4) NOT NULL,
	start_date date NOT NULL,
	end_date date NOT NULL,
	PRIMARY KEY(customer_id),
	FOREIGN KEY(region_id) REFERENCES bank_data..regions(region_id));

CREATE TABLE bank_data..transactions (
	customer_id CHAR(4) NOT NULL,
	txn_date date NOT NULL,
	txn_type VARCHAR(10) NOT NULL,
	txn_amount int NOT NULL,
	FOREIGN KEY(customer_id) REFERENCES bank_data..customers(customer_id));


--- INSERT DATA INTO THE TABLES
INSERT INTO bank_data..regions(region_id, region_name)
	VALUES 
	('R001', 'Africa'),
	('R002', 'Amerfica'),
	('R003', 'Asia'),
	('R004','Europe'),
	('R005', 'Oceania');
		
INSERT INTO bank_data..customers(customer_id, region_id, start_date, end_date)
	VALUES 
	('C001','R003', '2020-02-01', '2020-03-01'),
	('C002','R003', '2020-03-01', '2020-01-17'),
	('C003','R005', '2020-01-07', '2020-02-18'),
	('C004','R005', '2020-07-01', '2020-01-19'),
	('C005','R003', '2020-01-15', '2020-01-23'),
	('C006','R001', '2020-11-01', '2020-06-02'),
	('C007','R002', '2020-01-20', '2020-04-02'),
	('C008','R001', '2020-01-15', '2020-01-28'),
	('C009','R004', '2020-01-20', '2020-01-25'),
	('C010','R003', '2020-01-13', '2020-01-14');


INSERT INTO bank_data..transactions(customer_id, txn_date, txn_type, txn_amount)
	VALUES 
	('C001', '2020-01-21', 'deposit', '82'),
	('C002', '2020-01-10', 'deposit', '712'),
	('C003', '2020-01-01', 'deposit', '196'),
	('C001', '2020-01-14', 'withdrawl', '563'),
	('C004', '2020-01-29', 'deposit', '626'),
	('C005', '2020-01-13', 'deposit', '995'),
	('C002', '2020-01-20', 'deposit', '485'),
	('C008', '2020-01-03', 'deposit', '706'),
	('C009', '2020-01-13', 'deposit', '601'),
	('C008', '2020-01-11', 'withdrawl', '520');

--- QUICK CHECK ON THE TABLES' DATA:
SELECT *
FROM bank_data..regions;

SELECT *
FROM bank_data..customers; --- Note that some of the end_data is smaller than start_date;

SELECT *
FROM bank_data..transactions;

--- CLEAN DATA: mispelling: withdrawl
UPDATE bank_data..transactions
SET txn_type = 'withdrawal'
WHERE txn_type = 'withdrawl';

--- WHAT IS THE CLOSING BALANCE FOR EACH CUSTOMER AT THE END OF THE MONTH?
--- Using CTE

WITH w_d (customer_id, EoMonth, txn_type, txn_amount) AS (

SELECT customer_id, 
	CASE 
		WHEN DATEPART(month, txn_date) = 1 THEN 'January' 
		END AS EoMonth,
	txn_type,
	CASE
		WHEN txn_type='withdrawal' THEN -txn_amount
		ELSE txn_amount
		END AS txn_amount
FROM bank_data..transactions)


SELECT customer_id, EoMonth, SUM(txn_amount) AS balance
FROM w_d
GROUP BY customer_id, EoMonth
