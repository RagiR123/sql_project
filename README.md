E-Commerce Data Cleaning & SQL Analysis Project
Overview
The project works with three main datasets:
Customer Details
Product Details
E-Commerce Sales Data (2024)

Python is used to inspect, clean, transform, standardize, and prepare the raw datasets before they are imported into SQL for further analysis.

Workflow
Raw CSV Files → Python Data Cleaning & Preprocessing → Cleaned CSV Files → SQL Analysis

Technologies Used
Python
Pandas– Data cleaning, transformation, and preprocessing
NumPy – Numerical operations
Matplotlib – Data visualization
SQL– Data analysis

Datasets
1. Customer Details
The customer dataset contains customer-related information.
The Python preprocessing includes:
 Loading the customer dataset
 Inspecting the first few records
 Checking the number of rows and columns
 Checking for missing values
 Checking for duplicate records
 Standardizing column names
 Reviewing the dataset structure
 Exporting the cleaned dataset
The cleaned dataset is saved as:
cleaned_customer_details.csv

2. Product Details
The product dataset contains product-related information such as product names, selling prices, shipping weights, and other product attributes.
The preprocessing includes:
 Loading and inspecting the dataset
 Checking dataset dimensions
 Identifying missing values
 Removing completely empty columns
 Standardizing column names
 Extracting numerical values from shipping weight
 Extracting weight units
 Converting ounce measurements into pounds
 Cleaning and converting selling prices into numerical values
 Identifying unusually long product names
 Removing unnecessary product-related columns
 Handling missing values
 Cleaning non-ASCII characters
 Exporting the cleaned dataset

The cleaned dataset is saved as:cleaned_product_details.csv
Shipping Weight Processing
The `shipping_weight` field contains weight information along with units.
The preprocessing separates the information into:
 Numerical weight value
 Weight unit
Where required, ounce measurements are converted into pounds to maintain consistency in the dataset.

 3. E-Commerce Sales Data
The e-commerce sales dataset contains sales transaction information for 2024.
The preprocessing includes:
 Loading the dataset
 Inspecting the dataset structure
 Checking the number of rows and columns
 Reviewing data types
 Checking missing values
 Checking duplicate records
 Standardizing column names
 Converting timestamp information into a consistent date-time format
 Exporting the cleaned dataset
The cleaned dataset is saved as:
cleaned_ecommerce_details.csv

 Data Cleaning Process
The Python preprocessing stage is focused on improving the quality, consistency, and usability of the raw datasets before SQL analysis.

 Column Name Standardization
 Removing leading and trailing spaces
 Converting column names to lowercase
 Replacing spaces with underscores

For example:
Product Name → product_name
This makes the datasets easier to work with in both Python and SQL.

Missing Value Handling
Missing values are identified using Pandas.

Depending on the type and purpose of the column:

 Completely empty columns are removed
 Missing text values are replaced with "unknown"`
 Missing numerical values are replaced with `0`
 Missing selling prices are handled appropriately

Duplicate Detection
Duplicate records are checked in the datasets to identify repeated records before the data isexported.

Data Type Conversion
Relevant fields are converted into appropriate formats.

Examples include:
 Selling price → numerical format
 Timestamp → standardized date-time format

Text Cleaning
Product-related text is cleaned to remove unwanted characters and improve consistency.
Non-ASCII characters are removed where necessary, and leading/trailing whitespace is stripped.

 Cleaned Datasets

After the Python preprocessing stage, three cleaned CSV files are generated:
cleaned_customer_details.csv
cleaned_product_details.csv
cleaned_ecommerce_details.csv

These files are then used as the input datasets for the SQL analysis stage.

Project Objectives
The main objectives of this project are:

1. Clean raw e-commerce datasets using Python.
2. Identify and handle missing values.
3. Identify duplicate records.
4. Standardize column names and data formats.
5. Transform product weight and price information into usable formats.
6. Remove unnecessary or completely empty columns.
7. Clean text and character formatting.
8. Generate structured and consistent CSV files.
9. Import the cleaned datasets into SQL.
10. Perform meaningful e-commerce data analysis using SQL.



**Current Stage:** Python Data Cleaning & Preprocessing ✅

**Next Stage:** SQL Data Analysis

The cleaned datasets generated through Python will be used as the primary input for the SQL analysis stage.
