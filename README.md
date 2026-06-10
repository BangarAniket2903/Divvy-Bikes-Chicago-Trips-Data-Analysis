
# 🚴‍♂️ Divvy Bike-Share Cloud Analytics Pipeline (AWS & Tableau)

## 📌 Project Overview
This project builds an end-to-end, serverless cloud data pipeline on **AWS** to store, transform, and analyze historical bike-share trip data for **Cyclistic**, a fictional bike-share company operating in Chicago. 

The primary business objective is to solve a core marketing challenge set by the Director of Marketing, Lily Moreno: **Understand how casual riders and annual members use Cyclistic bikes differently**. These data-driven insights will be utilized by the marketing analytics team to design strategies aimed at converting high-value casual riders into profitable annual members.

Instead of using desktop spreadsheet tools that crash under massive datasets, this solution implements a decoupled cloud architecture using **Amazon S3, AWS Glue, Amazon Athena (Presto SQL), and Tableau Public** to process full-year data efficiently.

---

## 🏗️ Data Pipeline Architecture
The system architecture decouples storage, metadata cataloging, compute analytics, and business intelligence visualization layer.

### 📐 Text-Based Architecture Flow
```text
┌──────────────────────┐      ┌─────────────────────────┐      ┌────────────────────────┐
│  Raw Data (.CSV)     │ ───> │  Amazon S3 (Raw Zone)   │ ───> │   AWS Glue Crawler     │
│  Historical Trips    │      │  s3://.../raw-data/     │      │   Automated Discovery  │
└──────────────────────┘      └─────────────────────────┘      └────────────────────────┘
                                                                           │
                                                                           ▼
┌──────────────────────┐      ┌─────────────────────────┐      ┌────────────────────────┐
│ Tableau Public BI    │ <─── │ Download Aggregated CSV │ <─── │ AWS Glue Data Catalog  │
│ Executive Dashboard  │      │ s3://.../query-results/ │      │ Metadata Base Schema   │
└──────────────────────┘      └─────────────────────────┘      └────────────────────────┘
                                           ▲                               │
                                           │                               ▼
                                           └─────────────────────── [ Amazon Athena ]
                                                                     Presto SQL ETL Engine
                                                                     (CTAS Transformations)


🛠️ Data Transformation & Cleaning (ETL)
Data cleaning and feature engineering were executed completely in the cloud using Amazon Athena via CTAS (Create Table As Select) statements. This approach shifted the processing load to AWS serverless infrastructure, bypassing local memory limits.

🧹 Data Cleaning Steps:
Outlier Removal: Filtered out negative trip durations, test station entries, and trips lasting less than 60 seconds or longer than 24 hours.

Missing Value Handling: Standardized or dropped rows with missing critical spatial details (e.g., blank start/end station names and coordinates).

Feature Engineering: * Extracted ride_length by calculating the difference between end and start timestamps.

Derived day_of_week and month attributes to analyze temporal behavior trends.

Schema Optimization: Dropped redundant or highly sparse fields to reduce column-store scan costs for subsequent queries.

⚡ Performance Optimization & Benchmarking
1. Cloud Compute vs. Local Infrastructure
Running analytics queries via Amazon Athena demonstrated a significant performance increase compared to running the same workloads on a local database instance like pgAdmin/PostgreSQL.

Local Bottleneck: Local queries suffered from disk I/O bottlenecks and high CPU utilization.

Cloud Solution: Athena’s distributed Presto engine executed parallelized column-scans, cutting query execution time drastically and handling millions of rows seamlessly.

2. Business Intelligence Layer Acceleration
To prevent slow dashboard loading times on Tableau, the connection strategy was optimized:

The Strategy: Avoided live queries back to the database for every interactive filter toggle.

The Implementation: Built an Extract Connection to pull pre-aggregated, cleaned data directly into Tableau's in-memory data engine.

The Result: Maximized dashboard rendering speed, removed query latency, and created a seamless interactive user experience for stakeholders.


Summary of Findings:
Ride Duration: Casual riders tend to take significantly longer trips on average compared to members, suggesting leisure or tourism usage.

Temporal Patterns: Members show massive activity spikes during typical weekday commuting hours (8 AM and 5 PM), while casual riders dominate weekend afternoons.

Station Popularity: Casual riders cluster heavily around coastal and tourist-heavy stations, whereas members are evenly distributed across commercial and residential zones.




