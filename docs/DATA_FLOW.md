# SmartSoil AI - Soil Data Interface

## Purpose

This document defines the soil-data format produced by the Sprint 1
soil-processing module.

The output can be used by later SmartSoil AI modules.

## Source

The data is currently generated from simulated soil readings stored in:

data/soil_data.csv

Later, the simulated input can be replaced by real ESP32 sensor readings.

## Processing

Raw Soil Data
    ↓
soil_processor.py
    ↓
Read and convert values
    ↓
Validate values
    ↓
Reject invalid readings
    ↓
Structure valid readings
    ↓
Standard Soil Data

## Standard Soil Reading

Each valid soil reading contains exactly these fields:

```json
{
    "pH": 6.8,
    "moisture": 42.0,
    "N": 40.0,
    "P": 20.0,
    "K": 30.0,
    "temperature": 27.0
}