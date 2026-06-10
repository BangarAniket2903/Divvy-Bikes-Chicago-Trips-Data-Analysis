# 🚴‍♂️ Divvy Bike-Share Cloud Analytics Pipeline (AWS & Tableau)

## 📌 Project Overview

This project builds an end-to-end, serverless cloud data pipeline on **AWS** to store, transform, and analyze historical bike-share trip data for **Divvy**, a bike-share company operating in Chicago.

The primary business objective is to solve a core marketing challenge set by the Director of Marketing, Lily Moreno:

> **Understand how casual riders and annual members use Cyclistic bikes differently.**

These data-driven insights help the marketing analytics team design strategies aimed at converting high-value casual riders into profitable annual members.

Instead of relying on desktop spreadsheet tools that struggle with large datasets, this solution leverages a cloud-native architecture using **Amazon S3, AWS Glue, Amazon Athena (Presto SQL), and Tableau Public** to process and analyze a full year of ride data efficiently.

---

## 🏗️ Data Pipeline Architecture

The solution follows a serverless architecture that separates storage, metadata management, analytics processing, and business intelligence visualization.

### 📐 Architecture Flow

```text
┌──────────────────────┐      ┌─────────────────────────┐      ┌────────────────────────┐
│  Raw Data (.CSV)     │ ───> │  Amazon S3 (Raw Zone)   │ ───> │   AWS Glue Crawler     │
│ Historical Trips     │      │  s3://.../raw-data/     │      │ Automated Discovery    │
└──────────────────────┘      └─────────────────────────┘      └────────────────────────┘
                                                                           │
                                                                           ▼
┌──────────────────────┐      ┌─────────────────────────┐      ┌────────────────────────┐
│ Tableau Public BI    │ <─── │ Download Aggregated CSV │ <─── │ AWS Glue Data Catalog  │
│ Executive Dashboard  │      │ s3://.../query-results/ │      │ Metadata Repository    │
└──────────────────────┘      └─────────────────────────┘      └────────────────────────┘
                                           ▲                               │
                                           │                               ▼
                                           └───────────────────── Amazon Athena
                                                                  (Presto SQL Engine)
                                                                  CTAS Transformations
```

---

## 🛠️ Data Transformation & Cleaning (ETL)

Data cleaning and feature engineering were performed entirely in the cloud using **Amazon Athena CTAS (Create Table As Select)** statements. This approach shifted processing workloads away from local machines and leveraged AWS serverless infrastructure.

### 🧹 Data Cleaning Steps

#### 1. Outlier Removal

* Removed trips shorter than **60 seconds**
* Removed trips longer than **24 hours**
* Filtered negative trip durations
* Excluded invalid or test station records

#### 2. Missing Value Handling

* Removed records with missing critical station information
* Standardized incomplete location fields where appropriate

#### 3. Feature Engineering

* Created **trip_duration_min**
* Derived **day_of_week**
* Derived **month**
* Generated additional analytical fields for behavioral analysis

#### 4. Schema Optimization

* Removed redundant columns
* Reduced unnecessary data scans
* Improved query performance and cost efficiency

---

## ⚡ Performance Optimization & Benchmarking

### 1. Cloud Compute vs. Local Infrastructure

Running analytical workloads on **Amazon Athena** delivered significantly better performance than processing the same dataset locally.

#### Local Challenges

* High CPU utilization
* Disk I/O bottlenecks
* Slow query execution on large datasets

#### Cloud Advantages

* Distributed query execution
* Parallel columnar scans
* Efficient processing of millions of records
* No infrastructure management required

---

### 2. Tableau Performance Optimization

To ensure a responsive dashboard experience, Tableau was configured using optimized extracts instead of live database connections.

#### Strategy

Avoid sending a new database query every time a dashboard filter changes.

#### Implementation

* Exported cleaned and aggregated datasets
* Connected Tableau using **Extract Mode**
* Leveraged Tableau's in-memory engine

#### Result

* Faster dashboard rendering
* Reduced query latency
* Improved stakeholder experience

---

## 📊 Key Business Insights

### ⏱️ Ride Duration

Casual riders typically take longer trips than annual members, indicating a stronger leisure and recreational usage pattern.

### 📅 Temporal Patterns

* Members show peak usage during weekday commuting hours.
* Casual riders are most active during weekends and afternoons.

### 📍 Station Popularity

* Casual riders are concentrated around tourist and waterfront stations.
* Members are more evenly distributed across residential and commercial areas.

---

## 🛠️ Technology Stack

| Layer         | Technology     |
| ------------- | -------------- |
| Cloud Storage | Amazon S3      |
| Data Catalog  | AWS Glue       |
| Query Engine  | Amazon Athena  |
| SQL Engine    | Presto SQL     |
| Visualization | Tableau Public |
| File Format   | CSV / Parquet  |

---

## 🎯 Business Outcome

The analysis clearly demonstrates distinct behavioral differences between casual riders and annual members. These findings can support targeted marketing campaigns designed to increase annual membership conversions and improve long-term customer retention.


