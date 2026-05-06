# Product Guide

## Product Purpose

This project provides accurate Python reflections of the IHACPA National Weighted Activity Unit (NWAU) funding calculators. The primary goal is fidelity to the official IHACPA calculator behavior, regardless of whether the best available reference source is SAS code, Excel calculator workbooks, compiled or Python reference files, or associated data tables.

The project should prioritize correctness, traceability, and reproducibility over convenience. Where multiple official or semi-official sources exist, implementation decisions should be grounded in the source that most directly explains or validates the target calculator behavior.

## Core Goals

- Accurately reproduce IHACPA calculator outputs for supported pricing years.
- Maintain clear parity with official SAS calculator logic where SAS files are available.
- Use Excel workbooks, extracted formulas, weight tables, and supporting files as validation or implementation references where they clarify behavior.
- Preserve a reliable Python API and command line interface for batch funding calculations.
- Support historical pricing years in a way that makes data provenance and validation status explicit.
- Keep calculator behavior auditable so differences between IHACPA source materials and Python outputs can be investigated.

## Target Users

The project is intended for analysts, developers, health funding specialists, and maintainers who need to calculate or validate IHACPA-style funding outputs outside the original SAS or Excel environments.

Typical users need to:

- Run NWAU calculations from Python or the command line.
- Compare Python results against IHACPA reference materials.
- Add or validate new pricing years.
- Understand how each calculator maps back to source SAS, Excel, or supporting reference files.
- Diagnose discrepancies between implementation output and official calculator behavior.

## Product Principles

Accuracy is the highest priority. If a simpler implementation conflicts with verified IHACPA behavior, the implementation must follow the verified behavior.

Source traceability is required. Calculator logic, weights, formulas, and adjustment behavior should be linked back to the relevant SAS, Excel, or supporting reference source wherever practical.

Validation status must be explicit. Supported pricing years should distinguish between archived source availability, extracted weights and formulas, and Python output that has an evidence-backed validation record.

The Python implementation should remain practical to use. The CLI and package API should make common batch calculation workflows straightforward while preserving the underlying calculator detail needed for auditability.

## Scope

The product includes Python implementations of IHACPA calculator modules for admitted acute, emergency department, mental health, subacute, outpatient, adjustment, HAC, and AHR-related logic where supported by available source material.

The project also includes tooling and conventions for extracting, archiving, comparing, and validating reference data from SAS releases, Excel calculator workbooks, and other supporting files.

## Success Criteria

The product succeeds when supported calculators produce outputs that match verified IHACPA references for their pricing year, with enough traceability for maintainers to explain how each result was derived.

A pricing year should only be considered validated when the relevant Python calculator behavior has been checked against trusted reference outputs or source logic.
