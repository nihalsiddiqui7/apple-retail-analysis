# Apple-Retail-Sales-Analysis

Advanced SQL analysis of Apple retail sales data.  
This project demonstrates the use of advanced SQL techniques on a dataset of over **1 million rows**, focusing on solving real-world business problems, optimizing query performance, and extracting actionable insights from large datasets.

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Database Schema](#database-schema)
3. [Skills Highlighted](#skills-highlighted)
4. [Key Business Questions Solved](#key-business-questions-solved)
5. [Performance Optimization](#performance-optimization)

---

## Project Overview

This project is designed to analyze Apple retail sales data and uncover insights related to store performance, product trends, and warranty claims.  
Using advanced SQL features such as window functions, complex joins, and aggregations, the project addresses real-world analytical challenges on large-scale data.

The dataset includes transactional sales data, product information, store details, and warranty records from Apple retail locations across multiple regions.

---

## Database Schema

The database consists of five main tables:

- **stores** – Information about Apple retail stores (store ID, name, city, country)
- **category** – Product category details
- **products** – Product information including price and launch date
- **sales** – Sales transactions (sale date, store ID, product ID, quantity)
- **warranty** – Warranty claims with claim date and repair status

Refer to the `schema.sql` file for detailed table definitions.

---

## Skills Highlighted

- Advanced SQL querying and data analysis  
- Window functions (ranking, running totals, YoY growth)  
- Complex joins and multi-level aggregations  
- Time-based trend and growth analysis  
- Query performance optimization using indexing  
- Business-oriented problem solving using data  

---

## Key Business Questions Solved

- How many Apple stores exist in each country?
- Which store sold the highest number of units in the past year?
- What is the average price of products in each category?
- What percentage of warranty claims were rejected?
- What is the least-selling product in each country for each year?
- What is the year-over-year revenue growth for each store?
- What is the monthly running total of sales for each store over the past four years?

All queries used to answer these questions can be found in the `queries.sql` file.

---

## Performance Optimization

Query performance was a key focus due to the size of the dataset.

### Execution Time Improvement
- **Before optimization:** ~136 ms  
- **After optimization:** ~6 ms  

### Indexes Created
- `sales(product_id)`
- `sales(store_id)`
- `sales(quantity)`
- `sales(sale_date)`
- `sales(product_id, store_id)`

These indexes significantly improved performance for join-heavy and aggregation queries.

---

## Conclusion

This project demonstrates the ability to work with large datasets, write efficient and scalable SQL queries, and translate business requirements into meaningful analytical insights.  
It serves as a strong example of applying SQL to real-world retail analytics problems.

