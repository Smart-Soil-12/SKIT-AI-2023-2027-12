

This README documents the Sprint 5 work completed from **17 October
through 22 October 2026** for the SmartSoil AI crop-prediction model. It
records the purpose of each day's work, commands, observed outputs,
decisions, and the final test results.

> **Reproducibility note:** Outputs below are the results recorded
> during this work. Where the exact original exploratory one-line
> command was not retained, a reproducible equivalent is provided.

## Project context

  ----------------------------------------------------------------------------
  Item                                Value
  ----------------------------------- ----------------------------------------
  Dataset                             `data/Crop_recommendation_encoded.csv`

  Crop-name dataset                   `data/Crop_recommendation.csv`

  Input features                      `N`, `P`, `K`, `temperature`,
                                      `humidity`, `ph`, `rainfall`

  Target column                       `label_encoded`

  Dataset rows                        2,200

  Training / test rows                1,760 / 440

  Model                               `RandomForestClassifier`

  Number of trees                     200

  Random state                        42

  Split                               80/20, stratified

  Crop classes                        22
  ----------------------------------------------------------------------------
------------------------------------------------------------------------

## Analyze model accuracy and prediction errors

### Objective

Review the saved evaluation metrics and inspect test records the model
misclassified. This helps identify the model's errors rather than
relying only on its overall accuracy.

### 1. Print saved evaluation metrics

The training script saves evaluation results in
`models/evaluation_metrics.json`.

``` bash
python -c "import json; print(json.dumps(json.load(open('models/evaluation_metrics.json')), indent=2))"
```

Key recorded results:

``` text
Accuracy: 0.9954545454545455
Training rows: 1760
Test rows: 440
Features: ['N', 'P', 'K', 'temperature', 'humidity', 'ph', 'rainfall']
Target: label_encoded
```

The accuracy is approximately **99.55%**. On the 440-record test set,
this represents **438 correct predictions and 2 incorrect predictions**.

### 2. Inspect the saved model bundle

``` bash
python -c "import joblib; b=joblib.load('models/crop_recommendation_model.joblib'); m=b['model']; print('Model:',type(m).__name__); print('Features:',b['feature_names']); print('Target:',b['target_name']); print('Model type:',b['model_type']); print('Classes:',len(m.classes_))"
```

Recorded output:

``` text
Model: RandomForestClassifier
Features: ['N', 'P', 'K', 'temperature', 'humidity', 'ph', 'rainfall']
Target: label_encoded
Model type: RandomForestClassifier
Classes: 22
```

This confirms that the saved artifact loads and has the expected seven
input features and 22 classes.

### 3. Inspect the misclassified test records

The evaluation used the same stratified split as training:
`test_size=0.2`, `random_state=42`. The two recorded misclassifications
were:

``` text
 N   P   K  temperature  humidity       ph   rainfall  Actual  Predicted
60  59  22    31.868473 66.742175 7.191523  74.222386       2         11
67  43  39    26.043720 84.969072 5.999969 186.753677      20          8
```

Class-ID mapping:

``` text
Class 2  -> blackgram
Class 11 -> maize
Class 20 -> rice
Class 8  -> jute
```

Thus, the errors were **blackgram predicted as maize** and **rice
predicted as jute**.

These examples show which test records were misclassified; they do not,
by themselves, prove why the model confused those crops.

### 4. Review per-class metrics

  Crop          Precision    Recall   F1-score
  ----------- ----------- --------- ----------
  blackgram       100.00%    95.00%     97.44%
  jute             95.24%   100.00%     97.56%
  maize            95.24%   100.00%     97.56%
  rice            100.00%    95.00%     97.44%

-   **Precision:** among predictions for a crop, how many were correct.
-   **Recall:** among actual records for a crop, how many were
    identified.
-   **F1-score:** a combined measure of precision and recall.

**Outcome:** Evaluation and errors were analyzed. No source-code change
was required for this analysis day.

------------------------------------------------------------------------

## --- Review dataset quality and training configuration

### Objective

Check for obvious dataset-quality issues and compare 200 trees with a
larger 300-tree Random Forest configuration.

### 1. Check missing values and duplicate rows

Reproducible pandas command:

``` bash
python -c "import pandas as pd; d=pd.read_csv('data/Crop_recommendation_encoded.csv'); print('Total rows:',len(d)); print('Exact duplicate rows:',int(d.duplicated().sum())); print('Duplicate feature rows:',int(d.duplicated(subset=['N','P','K','temperature','humidity','ph','rainfall']).sum())); print('Missing values:',int(d.isna().sum().sum()))"
```

Recorded output:

``` text
Total rows: 2200
Exact duplicate rows: 0
Duplicate feature rows: 0
Missing values: 0
```

These checks found no missing values, exact duplicate rows, or duplicate
feature combinations. They do not prove that every dataset value is
correct.

### 2. Compare 200 and 300 trees

Recorded comparison using the same stratified train/test split:

``` text
200 trees: 99.5455%
300 trees: 99.3182%
```

Reproducible equivalent:

``` bash
python -c "import pandas as pd; from sklearn.model_selection import train_test_split; from sklearn.ensemble import RandomForestClassifier; d=pd.read_csv('data/Crop_recommendation_encoded.csv'); X=d[['N','P','K','temperature','humidity','ph','rainfall']]; y=d['label_encoded']; Xtr,Xte,ytr,yte=train_test_split(X,y,test_size=0.2,random_state=42,stratify=y); exec(\"for n in (200,300):\\n m=RandomForestClassifier(n_estimators=n,random_state=42,n_jobs=-1)\\n m.fit(Xtr,ytr)\\n print(f'{n} trees: {m.score(Xte,yte)*100:.4f}%')\")"
```

Expected recorded comparison:

``` text
200 trees: 99.5455%
300 trees: 99.3182%
```

Results can differ if the dataset, library versions, split, or settings
differ.

### Decision

Keep **200 trees**. The 300-tree model did not improve accuracy in this
comparison and used more trees without a demonstrated benefit on this
test split.

**Outcome:** Data checks and the configuration comparison were
completed. The existing training configuration was retained; no training
configuration change was made on this day.

------------------------------------------------------------------------

##  --- Retrain and compare the model

### Objective

Retrain with the selected configuration and refresh the saved model and
evaluation metrics.

### Command

``` bash
python -m src.ml.train_model
```

Recorded output:

``` text
Dataset rows: 2200
Training features: (1760, 7)
Testing features: (440, 7)
Model: RandomForestClassifier (200 trees)
Test accuracy: 0.9955 (99.55%)
Saved model: C:\Users\cheta\Desktop\smart soil\backend\models\crop_recommendation_model.joblib
Saved metrics: C:\Users\cheta\Desktop\smart soil\backend\models\evaluation_metrics.json
```

### What the command does

1.  Loads the encoded crop dataset.
2.  Selects the seven input features.
3.  Splits data into 80% training and 20% test records using
    stratification and `random_state=42`.
4.  Trains
    `RandomForestClassifier(n_estimators=200, random_state=42, n_jobs=-1)`.
5.  Evaluates the trained model on the test set.
6.  Saves the model bundle to `models/crop_recommendation_model.joblib`.
7.  Saves evaluation results to `models/evaluation_metrics.json`.

The classification report remained consistent with the previous
evaluation, with 20 test records per crop class.

**Result:** Test accuracy remained **99.55%**. This indicates
consistency on the same split, not a guarantee of the same performance
on new real-world farm data.

**Outcome:** The model was retrained and both saved artifacts were
refreshed.

------------------------------------------------------------------------

## 20 October --- Verify the finalized model artifact

### Objective

Confirm that the saved model can be loaded and that its configuration
matches expectations.

### Command

``` bash
python -c "import joblib, json; b=joblib.load('models/crop_recommendation_model.joblib'); m=b['model']; e=json.load(open('models/evaluation_metrics.json')); print('Model loaded:',type(m).__name__); print('Trees:',m.n_estimators); print('Features:',len(b['feature_names'])); print('Classes:',len(m.classes_)); print(f\"Accuracy: {e['accuracy']*100:.2f}%\")"
```

Recorded output:

``` text
Model loaded: RandomForestClassifier
Trees: 200
Features: 7
Classes: 22
Accuracy: 99.55%
```

### Explanation

-   **Model loaded:** the saved joblib artifact could be read.
-   **Trees: 200:** the artifact uses the selected Random Forest
    configuration.
-   **Features: 7:** seven input values are expected.
-   **Classes: 22:** the classifier supports 22 crop classes.
-   **Accuracy: 99.55%:** this is the value in the saved evaluation
    file.

**Outcome:** The artifact and metrics file were verified. This was a
load/configuration check, not a fresh evaluation on new data.

------------------------------------------------------------------------

## --- Implement top-three crop prediction logic

### Objective

Return exactly three ranked crop classes even when fewer than three
classes have a positive predicted probability.

### 1. Check the original behavior

The prediction function originally skipped zero-probability classes:

``` python
if score <= 0:
    continue
```

Sample input:

``` python
{
    "N": 90,
    "P": 42,
    "K": 43,
    "temperature": 20.9,
    "humidity": 82.0,
    "ph": 6.5,
    "rainfall": 202.9
}
```

Original output:

``` text
Number of predictions: 2
1. rice — 93.50%
2. jute — 6.50%
Unique crops: 2
```

The model returned 22 class probabilities, but only two were positive:

``` text
Total classes: 22
Positive probabilities: 2
Zero probabilities: 20
Top 5 probabilities: [0.935, 0.065, 0.0, 0.0, 0.0]
```

Because zero-probability classes were skipped, only two predictions were
returned.

### 2. Change `src/ml/predict_crop.py`

Remove the condition that skips zero-probability classes:

``` python
if score <= 0:
    continue
```

Keep the code that appends the crop and confidence and stops after three
results:

``` python
results.append({
    "crop": mapping[crop_id],
    "confidence": round(float(score) * 100, 2)
})
if len(results) == 3:
    break
```

**Why it works:** The class probabilities are ranked from highest to
lowest. Allowing zero-probability classes into the result list means the
function can return the third-ranked class even when its probability is
zero.

### 3. Verify the changed output

Recorded output:

``` text
Number of predictions: 3
1. rice — 93.50%
2. jute — 6.50%
3. apple — 0.00%
```

The output contains three unique crop names.

### Important limitation

**Apple at 0.00% is a fallback ranking, not a positive-confidence crop
recommendation.** The current implementation returns three ranked class
entries; it does not guarantee that all three have meaningful or
positive probabilities. Do not interpret a zero-confidence crop as
suitable.

**Outcome:** The zero-probability skip was removed and the sample
returned exactly three class entries.

------------------------------------------------------------------------

### Test top-three prediction behavior

### Objective

Update tests to reflect the requirement for exactly three returned
classes, then run the focused prediction tests and the full backend test
suite.

### 1. First focused test run

Command:

``` bash
python -m pytest tests/test_predict_crop.py -v
```

First-run result:

``` text
13 passed, 1 failed
```

The failing assertion in `test_valid_prediction` required confidence to
be strictly greater than zero. That assumption no longer matched the
updated top-three behavior, because the third-ranked class can have a
zero score.

### 2. Update test assertions

In `tests/test_predict_crop.py`, the result-count assertion changed
from:

``` python
assert 1 <= len(results) <= 3
```

to:

``` python
assert len(results) == 3
```

The confidence assertion changed from:

``` python
assert 0 < item["confidence"] <= 100
```

to:

``` python
assert 0 <= item["confidence"] <= 100
```

The updated tests now check that exactly three predictions are returned
and that confidence is between 0 and 100 inclusive.

### 3. Rerun focused tests

Command:

``` bash
python -m pytest tests/test_predict_crop.py -v
```

Recorded result:

``` text
14 passed, 11 warnings in 2.12s
```

All 14 tests in the prediction test file passed.

### 4. Run the complete backend test suite

Command:

``` bash
python -m pytest tests/ -v
```

Recorded result:

``` text
38 passed, 11 warnings in 8.28s
```

All **38 tests passed**.

The 11 warnings were joblib-related deprecation/compatibility warnings,
including:

``` text
ast.Num is deprecated
Attribute n is deprecated
```

They were warnings rather than test failures and were not addressed as
part of this day's work.

**Outcome:** Focused tests passed (14/14) and the complete backend test
suite passed (38/38).

------------------------------------------------------------------------

## Sprint 5 summary

  -----------------------------------------------------------------------
  Date                    Work                    Result
  ----------------------- ----------------------- -----------------------
  17 Oct                  Analyze evaluation and  99.55% accuracy; 2
                          misclassified records   errors identified

  18 Oct                  Check data quality and  No missing/duplicate
                          compare tree counts     records found by
                                                  checks; retained 200
                                                  trees

  19 Oct                  Retrain model           99.55% test accuracy;
                                                  model and metrics saved

  20 Oct                  Verify model artifact   200 trees, 7 features,
                                                  22 classes

  21 Oct                  Implement top-three     3 classes returned;
                          prediction output       third sample result was
                                                  0.00%

  22 Oct                  Update tests and run    14 focused tests and 38
                          suite                   total tests passed
  -----------------------------------------------------------------------

## Important files

  -------------------------------------------------------------------------------
  File                                        Purpose
  ------------------------------------------- -----------------------------------
  `src/ml/train_model.py`                     Trains and evaluates the crop
                                              classifier

  `src/ml/predict_crop.py`                    Validates inputs and returns ranked
                                              predictions

  `src/ml/label_mapping.py`                   Maps encoded class IDs to crop
                                              names

  `models/crop_recommendation_model.joblib`   Saved trained model bundle

  `models/evaluation_metrics.json`            Saved metrics and classification
                                              report

  `tests/test_predict_crop.py`                Tests prediction behavior and input
                                              validation
  -------------------------------------------------------------------------------

