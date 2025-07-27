import pandas as pd
from pathlib import Path

INPUT_FILE = 'archive/nwau25_calculator_for_acute_activity.xlsb'
SHEET_NAME = 'Parameters'
OUTPUT_PATH = Path('data/weights.csv')

def main():
    df = pd.read_excel(INPUT_FILE, sheet_name=SHEET_NAME, engine='pyxlsb')
    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    df.to_csv(OUTPUT_PATH, index=False)
    print(f"Wrote {len(df)} rows to {OUTPUT_PATH}")

if __name__ == '__main__':
    main()
