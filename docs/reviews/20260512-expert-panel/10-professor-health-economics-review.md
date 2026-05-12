# Simulated Professor of Health Economics Review

## Role

Reviewer focused on health-service costing, activity-based funding, cost
buckets, AHPCS, NHCDC, and practical analyst use.

## Findings

1. The package could become valuable for costing studies if it links NWAU,
   price weights, NEP, AHPCS, NHCDC, and cost buckets coherently.

2. Cost buckets should be separate from formula kernels.
   They support cost analysis and benchmarking, not core NWAU calculation unless
   an official source says otherwise.

3. Tutorials are necessary for adoption.
   Analysts need end-to-end examples: activity data to NWAU, NWAU to estimated
   efficient revenue, observed cost to cost bucket distribution, and benchmark
   interpretation.

4. Synthetic data is the right default.
   Real hospital costing data is sensitive and jurisdiction-specific.

5. Classification/version readiness is essential.
   Health economists need to know whether a result is invalid because a coding
   version, price year, or cost bucket mapping is incompatible.

## Recommended Health Economics Additions

- Add a costing-study tutorial suite.
- Add synthetic activity and cost datasets.
- Add AHPCS concept models and cost bucket registries.
- Add data-quality and interpretation caveats.
- Add examples comparing cost per NWAU by stream and cost bucket.

## Priority Recommendation

After core validation gates, prioritise tutorials and synthetic datasets that
show safe, policy-aware costing-study workflows.
