# sap-master-data-quality-health-checker
ABAP-based master data quality monitoring with CDS views and SAP Gateway OData
# SAP Master Data Quality Health Checker

An SAP ABAP project for identifying, scoring, and tracking master-data quality issues.

## Features

- Validates master data for missing or invalid information.
- Uses reusable validation classes and an interface.
- Generates an ALV report with issue details and health scores.
- Maintains issue and run history.
- Exposes issue-history and run-history data through SAP Gateway OData.

## Technology Stack

- SAP ABAP
- SAP Gateway / OData
- Core Data Services (CDS)
- Eclipse ADT
- SAP GUI

## Main Components

| Component | Purpose |
|---|---|
| `ZMDQ_HEALTH_CHECK` | Main master-data quality report |
| `ZMDQ_HISTORY_VIEWER` | Views historical check results |
| `ZMDQ_INIT_RULES` | Initialises validation rules |
| `ZI_MDQ_ISSUE` | CDS view for issue history |
| `ZI_MDQ_RUN` | CDS view for run history |
| `ZCL_MDQ_CHECK_*` | Reusable validation classes |
| `ZIF_MDQ_CHECK` | Validation interface |

## OData Service

Service name: `ZMDQ_HEALTH_SRV_SRV`

Entity sets:
- `ZI_MDQ_ISSUE`
- `ZI_MDQ_RUN`

The issue-history endpoint returned HTTP 200 with JSON data during testing.

## Repository Contents

This repository contains exported source files for learning, review, and portfolio demonstration. The files are not a complete SAP system export.

## Setup Notes

Running this project requires a compatible SAP ABAP development system, the required custom tables and data definitions, suitable authorisations, and SAP Gateway configuration.

The OData service must be generated and registered before its endpoints can be used.

## Security

Use synthetic or anonymised sample data. Do not commit credentials, private system URLs, internal hostnames, or real customer data.

## Project Status

The core report and both OData entity sets have been tested in a development system. Further deployment and portability testing may be required.
