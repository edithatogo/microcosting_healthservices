import sys
import os

import pandas as pd
import numpy as np
import lightgbm as lgb

import time

"""
fixed case issue (requires model to be retrained with lower case feature names)
Fixed type issue (requires model to be retrained with fixed types)
"""


def model_vars(n, risk_factors_df):
    """
    Returns a list of risk factors for the nth readmission category.
    
    Takes a readmission category index (1 to 12), and a dataframe
    with columns indexed 1 to 12 containing a list of risk factors.
    """
    
    ret = [x for x in risk_factors_df.iloc[:,n-1] if str(x) != 'nan']
    
    common_risk_factors = ['an110mdc_ra', 'agegroup_rm','flag_emergency',
                 'pat_remoteness', 'indstat_flag',
                'count_proc','adm_past_year']
    
    for risk in common_risk_factors:
        if risk not in ret:
            ret.append(risk)
    return ret

def rescale_to_points(x,data_min,data_max):
    """
    Returns a value scaled to between 1 and 100
    based on minimum and maximum values given in the
    2nd and 3rd arguements.
    """
    return ( ( (x - data_min) / (data_max - data_min) )*99 + 1).clip(1,100)

if __name__ == '__main__':
    start = time.time()
    
    try:
        data_path = sys.argv[1]
        params_path = sys.argv[2]
        models_path = sys.argv[3]
    except IndexError:
        print('No arguements given, defaulting working directory as root folder.')
        script_path = os.path.dirname(os.path.realpath(__file__))
        data_path = os.path.join(script_path,'temp')
        params_path = os.path.join(script_path,'params')
        models_path = os.path.join(script_path,'models')
    
    data = pd.read_csv(os.path.join(data_path,'prep_temp.csv'))
    orig_columns = data.columns;
    data.columns=data.columns.str.lower()
    
    scorer_params = pd.read_csv(os.path.join(params_path,'scaling_params.csv'),index_col=0)
    cutoffs_df = pd.read_csv(os.path.join(params_path,'cutoffs.csv'), index_col=0)
    dampening_df = pd.read_csv(os.path.join(params_path,'dampening.csv'), index_col=0)
    
    risk_factors_df = pd.read_csv(os.path.join(models_path,'risk_factors.csv'), index_col=0)
        
    model_dict_limited = dict()
    for i in range(1,13):
        model_dict_limited[i] = lgb.Booster(model_file = os.path.join(models_path,'model_4year_sta_readm'+str(i)+'_90_limited.txt'))
        
    data['drg11_type_m'] = (data['drg11_type'] == 'M').astype(np.int8)
    data.an110mdc_ra = data.an110mdc_ra.replace('.','99')

    risk_factors_list = [risk_factors_df[f'{i+1}'].dropna().tolist() for i in range(12)]
    modelVars = list(set().union(*risk_factors_list))

    for col in data.columns:
        if col in modelVars:
            data[col] = data[col].astype(np.int64)

    for col in data.columns:
        if col not in {'count_proc','adm_past_year'}:
            data[col] = data[col].astype('category')
        else:
            data[col] = data[col].astype(np.int32)
       
    for i in range(1,13):
        probs = model_dict_limited[i].predict(data[model_vars(i, risk_factors_df)])
        #data[f"probs{i}"] = probs
        
        log_probs = np.log(probs)
        
        data[f'readm_points{i}'] = rescale_to_points(x=log_probs,data_min=scorer_params.loc[i,'mins'],data_max=scorer_params.loc[i,'maxs'])

        # Sanity check - all values should be between 1 and 100
        print(i,np.min(data[f'readm_points{i}']),np.max(data[f'readm_points{i}']))
        
        # Determine risk category and dampening amount based on points
        conditions = [data[f'readm_points{i}'] < cutoffs_df.iloc[0,i-1], 
                      (data[f'readm_points{i}'] >= cutoffs_df.iloc[0,i-1]) & (data[f'readm_points{i}'] < cutoffs_df.iloc[1,i-1]),
                      data[f'readm_points{i}'] >= cutoffs_df.iloc[1,i-1]]

        choices = [dampening_df.iloc[0,i-1], dampening_df.iloc[1,i-1], dampening_df.iloc[2,i-1]]
        choices_cat = [0,1,2]
        default = None 

        data[f'dampening{i}'] = np.select(conditions, choices, default)
        data[f'risk_category{i}'] = np.select(conditions, choices_cat, default)
        
    # Print runtime
    print("Time taken:",time.time()-start)
    
    data.to_csv(os.path.join(data_path,'scored.csv'))
