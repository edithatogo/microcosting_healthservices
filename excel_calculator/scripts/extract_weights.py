import pandas as pd
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parents[1]
INPUT_FILE = BASE_DIR / 'archive' / 'nwau25_calculator_for_acute_activity.xlsb'
SHEET_NAME = 'Parameters'
OUTPUT_PATH = BASE_DIR / 'data' / 'weights.csv'

def main():
    df = pd.read_excel(INPUT_FILE, sheet_name=SHEET_NAME, engine='pyxlsb')
    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    df.to_csv(OUTPUT_PATH, index=False)
    print(f"Wrote {len(df)} rows to {OUTPUT_PATH}")

if __name__ == '__main__':
    main()
