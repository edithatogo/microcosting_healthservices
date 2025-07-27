"""Avoidable Hospital Readmission (AHR) Grouper in Python.

This module provides a minimal implementation of the SAS script
``Avoidable Hospital Readmission Grouper 030.sas``. It loads the
ICD‑to‑AHR mappings distributed with the IHACPA SAS calculator and
applies them to patient level data. The grouper also exposes an
interface to the LightGBM based scorer used by IHACPA.
"""
from __future__ import annotations

from pathlib import Path
from typing import Dict, Iterable, List

import pandas as pd


AHR_THRESHOLD_DAYS = {
    "AHR030c01p01": 14,
    "AHR030c01p02": 7,
    "AHR030c01p03": 14,
    "AHR030c01p04": 14,
    "AHR030c01p05": 14,
    "AHR030c02p01": 7,
    "AHR030c02p02": 30,
    "AHR030c02p03": 7,
    "AHR030c02p04": 2,
    "AHR030c02p05": 2,
    "AHR030c02p06": 2,
    "_AHR030c02p06": 2,
    "AHR030c02p07": 90,
    "AHR030c02p08": 30,
    "AHR030c02p09": 2,
    "AHR030c02p10": 28,
    "AHR030c02p11": 2,
    "AHR030c03p01": 28,
    "AHR030c03p02": 28,
    "AHR030c03p03": 28,
    "AHR030c03p04": 28,
    "AHR030c03p05": 14,
    "AHR030c03p06": 28,
    "AHR030c04p01": 21,
    "AHR030c04p02": 14,
    "AHR030c04p03": 30,
    "AHR030c05p01": 90,
    "AHR030c06p01": 21,
    "AHR030c07p01": 2,
    "AHR030c08p01": 2,
    "AHR030c08p02": 4,
    "_AHR030c08p02": 4,
    "AHR030c08p03": 14,
    "AHR030c08p04": 14,
    "AHR030c09p01": 10,
    "AHR030c10p01": 30,
    "AHR030c10p02": 30,
    "AHR030c10p03": 14,
    "AHR030c10p04": 30,
    "AHR030c11p01": 14,
    "AHR030c12p01": 7,
}


class LightGBMScorer:
    """Wrapper around the LightGBM scoring models."""

    def __init__(self, params_dir: Path, models_dir: Path):
        import lightgbm as lgb

        self.scaling = pd.read_csv(params_dir / "scaling_params.csv", index_col=0)
        self.cutoffs = pd.read_csv(params_dir / "cutoffs.csv", index_col=0)
        self.dampening = pd.read_csv(params_dir / "dampening.csv", index_col=0)
        self.risk_factors = pd.read_csv(models_dir / "risk_factors.csv", index_col=0)
        self.models = {
            i: lgb.Booster(model_file=str(models_dir / f"model_4year_sta_readm{i}_90_limited.txt"))
            for i in range(1, 13)
        }

    def _model_vars(self, n: int) -> List[str]:
        vars_ = [x for x in self.risk_factors[str(n)].dropna().tolist() if str(x) != "nan"]
        common = [
            "an110mdc_ra",
            "agegroup_rm",
            "flag_emergency",
            "pat_remoteness",
            "indstat_flag",
            "count_proc",
            "adm_past_year",
        ]
        for c in common:
            if c not in vars_:
                vars_.append(c)
        return vars_

    def score(self, data: pd.DataFrame) -> pd.DataFrame:
        import numpy as np

        df = data.copy()
        df.columns = df.columns.str.lower()
        drg_col = df.get("drg11_type")
        if drg_col is None:
            df["drg11_type_m"] = 0
        else:
            df["drg11_type_m"] = (drg_col == "M").astype("int8")

        an110 = df.get("an110mdc_ra")
        if an110 is not None:
            df["an110mdc_ra"] = an110.astype(str).replace({".": "99"})

        for col in df.columns:
            if col not in {"count_proc", "adm_past_year"}:
                df[col] = df[col].astype("category")
            else:
                df[col] = pd.to_numeric(df[col], errors="coerce").fillna(0).astype("int32")

        for i in range(1, 13):
            vars_ = self._model_vars(i)
            probs = self.models[i].predict(df[vars_])
            log_probs = np.log(probs)
            df[f"readm_points{i}"] = (
                (log_probs - self.scaling.loc[i, "mins"]) / (self.scaling.loc[i, "maxs"] - self.scaling.loc[i, "mins"]) * 99 + 1
            ).clip(1, 100)
            conditions = [
                df[f"readm_points{i}"] < self.cutoffs.iloc[0, i - 1],
                (df[f"readm_points{i}"] >= self.cutoffs.iloc[0, i - 1])
                & (df[f"readm_points{i}"] < self.cutoffs.iloc[1, i - 1]),
                df[f"readm_points{i}"] >= self.cutoffs.iloc[1, i - 1],
            ]
            choices = [
                self.dampening.iloc[0, i - 1],
                self.dampening.iloc[1, i - 1],
                self.dampening.iloc[2, i - 1],
            ]
            choices_cat = [0, 1, 2]
            df[f"dampening{i}"] = np.select(conditions, choices, default=None)
            df[f"risk_category{i}"] = np.select(conditions, choices_cat, default=None)
        return df[[f"dampening{i}" for i in range(1, 13)] + [f"risk_category{i}" for i in range(1, 13)] + [f"readm_points{i}" for i in range(1, 13)]]


def load_ahr_maps(maps_dir: Path) -> Dict[str, pd.DataFrame]:
    """Load all ``ahr_map_XX.sas7bdat`` files found in ``maps_dir``."""
    maps: Dict[str, pd.DataFrame] = {}
    for path in sorted(maps_dir.glob("ahr_map_*.sas7bdat")):
        edition = path.stem.split("_")[-1]
        maps[edition] = pd.read_sas(path, format="sas7bdat")
    return maps


def flag_diagnoses(
    episode_df: pd.DataFrame,
    maps: Dict[str, pd.DataFrame],
    edition: str,
    diag_prefix: str = "ddx",
    onset_prefix: str = "onset",
) -> pd.DataFrame:
    """Flag diagnoses using the AHR mapping tables.

    ``episode_df`` must contain columns ``ddx1``–``ddx100`` and matching
    ``onset1``–``onset100`` values. Only diagnoses with onset value ``"2"``
    (condition arose in hospital) trigger flags.
    """
    map_df = maps[edition].set_index("DDX").fillna(0)
    flag_cols = [c for c in map_df.columns if c.startswith("AHR")]
    result = pd.DataFrame(0, index=episode_df.index, columns=flag_cols)
    for i in range(1, 101):
        dcol = f"{diag_prefix}{i}"
        ocol = f"{onset_prefix}{i}"
        if dcol not in episode_df.columns:
            break
        codes = episode_df[dcol].astype(str).str.upper()
        onset = episode_df.get(ocol)
        mask = onset.eq("2") if onset is not None else pd.Series(True, index=codes.index)
        matched = map_df.reindex(codes.where(mask).fillna(""))
        matched = matched.fillna(0).astype(int)
        result = result | matched.values
    episode_df = episode_df.join(result)
    return episode_df


def past_admissions(episodes: pd.DataFrame, patient_col: str, date_col: str) -> pd.Series:
    """Count admissions in the previous 365 days for each episode."""
    episodes = episodes.sort_values([patient_col, date_col])
    counts = pd.Series(0, index=episodes.index)
    for pid, group in episodes.groupby(patient_col):
        dates = pd.to_datetime(group[date_col])
        rolled = dates.rolling("365D", closed="left").count()
        counts.loc[group.index] = rolled.values
    return counts


def group_readmissions(
    episodes: pd.DataFrame,
    maps: Dict[str, pd.DataFrame],
    edition: str,
    patient_col: str = "patient_id",
    adm_col: str = "adm_date",
    sep_col: str = "sep_date",
) -> pd.DataFrame:
    """Group episodes into AHR categories.

    The input must be sorted by ``patient_id`` and ``adm_date``. Diagnostic flags
    are derived using :func:`flag_diagnoses` and time between episodes determines
    whether a readmission occurred.
    """
    df = flag_diagnoses(episodes, maps, edition)
    df = df.sort_values([patient_col, adm_col])
    df["ahr_time"] = pd.NaT
    flags = {c: [] for c in AHR_THRESHOLD_DAYS}
    prev_sep = None
    prev_idx = None
    prev_pid = None
    for idx, row in df.iterrows():
        pid = row[patient_col]
        if pid != prev_pid:
            prev_sep = None
        if prev_sep is not None:
            delta = (pd.to_datetime(row[adm_col]) - prev_sep).days
            df.at[idx, "ahr_time"] = delta
            for col, days in AHR_THRESHOLD_DAYS.items():
                if row.get(col) == 1 and delta <= days:
                    flags[col].append(idx)
        prev_sep = pd.to_datetime(row[sep_col])
        prev_pid = pid
    for col, rows in flags.items():
        df[col + "_flag"] = 0
        if rows:
            df.loc[rows, col + "_flag"] = 1
    df["adm_past_year"] = past_admissions(df, patient_col, adm_col)
    return df

__all__ = ["load_ahr_maps", "group_readmissions", "LightGBMScorer", "flag_diagnoses", "past_admissions"]
