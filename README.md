# 🚀 Data Warehouse & Analytics Project

A complete end-to-end **Data Warehouse + Analytics solution** built using SQL.  
This project demonstrates how raw data is transformed into **business-ready insights** using modern data engineering practices.

---

## 📌 Project Summary

- Project Link :- pujarigovinda1999-hash/My-Repository: Building a modern Data Warehouse with Postgres SQL, including ETL processes, data modeling and analytics.
<img width="81" height="25" alt="image" src="https://github.com/user-attachments/assets/5893a235-02a9-425d-8eb7-9aa278a4951e" />

- Built a **Medallion Architecture (Bronze → Silver → Gold)** data warehouse  
- Developed **ETL pipelines** to clean and transform raw data  
- Designed **star schema (fact & dimension tables)**  
- Generated **business insights using SQL**  

🎯 Goal: Enable data-driven decision-making for **sales, customers, and product performance**

---

## 🏗️ Data Architecture

![Data Architecture](docs/data_architecture.png)

### 🔹 Layers Explained

- **Bronze Layer**  
  Raw data ingested from CSV files into database (no transformation)

- **Silver Layer**  
  Data cleaning, standardization, and transformation applied

- **Gold Layer**  
  Business-ready data modeled into **fact and dimension tables** for analytics

---

## 🛠️ Tech Stack

- SQL (Data Transformation, Analysis)  
- PostgreSQL / SQL Server  
- pgAdmin  
- Excel (Reporting / Dashboarding)  
- Draw.io (Data Architecture Design)  
- Git & GitHub  

---

## 🔄 ETL Pipeline

1. Extract data from ERP & CRM CSV files  
2. Load raw data into Bronze layer  
3. Transform & clean data in Silver layer  
4. Build analytical model (Star Schema) in Gold layer  

---

## 📊 Data Model (Star Schema)

- **Fact Table:** Sales  
- **Dimension Tables:** Customers, Products  

👉 Optimized for fast analytical queries and reporting

---

## 📊 Key Business Insights

- Top customers contribute a significant portion of total revenue  
- Sales trends show seasonal patterns across months  
- Certain products consistently outperform others  
- Cleaned data improves reporting accuracy and reliability  

---


## 📂 Repository Structure
```
data-warehouse-project/
│
├── datasets/                           # Raw datasets used for the project (ERP and CRM data)
│
├── docs/                               # Project documentation and architecture details
│   ├── etl.drawio                      # Draw.io file shows all different techniquies and methods of ETL
│   ├── data_architecture.drawio        # Draw.io file shows the project's architecture
│   ├── data_catalog.md                 # Catalog of datasets, including field descriptions and metadata
│   ├── data_flow.drawio                # Draw.io file for the data flow diagram
│   ├── data_models.drawio              # Draw.io file for data models (star schema)
│   ├── naming-conventions.md           # Consistent naming guidelines for tables, columns, and files
│
├── scripts/                            # SQL scripts for ETL and transformations
│   ├── bronze/                         # Scripts for extracting and loading raw data
│   ├── silver/                         # Scripts for cleaning and transforming data
│   ├── gold/                           # Scripts for creating analytical models
│
├── tests/                              # Test scripts and quality files
│
├── README.md                           # Project overview and instructions
├── LICENSE                             # License information for the repository
├── .gitignore                          # Files and directories to be ignored by Git
└── requirements.txt                    # Dependencies and requirements for the project
```
---


---

## ▶️ How to Run the Project

1. Download datasets from `/datasets`  
2. Load data into PostgreSQL / SQL Server  
3. Run scripts in order:  
   - `bronze` → `silver` → `gold`  
4. Explore analytical queries inside `/scripts/gold`  

---

## 🎯 What This Project Demonstrates

- Data Warehouse Design  
- ETL Pipeline Development  
- Data Cleaning & Transformation  
- SQL for Data Analysis  
- Business Insight Generation  

---

## 🌐 Connect with Me

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Govinda%20Pujari-blue?logo=linkedin&logoColor=white)](https://www.linkedin.com/in/govinda-pujari-48a83936b)

---

## 🛡️ License

This project is licensed under the MIT License.
