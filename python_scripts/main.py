# libraries for ingestion and ML
import os
import pandas as pd
from sqlalchemy import create_engine
from xgboost import XGBClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import confusion_matrix, classification_report, ConfusionMatrixDisplay
import matplotlib.pyplot as plt
import seaborn as sns

# same engine code as the raw_data export 
db_endpoint = 'postgresql://kellen@localhost:5432/forestry_research'

# similar engine code as raw_data export
engine = create_engine(db_endpoint)

# get all data from the ml_training_data_dominant table in Postres
query = 'SELECT * FROM ml_ready.ml_training_data_dominant'

# using pandas to write query output into dataframe
df = pd.read_sql(query, engine)

# english recognition of import w/ record count
print(f"{len(df)} records have been successfully imported from Postgres.")


# # which species get hit the hardest?
# plt.figure(figsize=(12,6))
# sns.barplot(data=df, x='common_name', y='is_disturbed', estimator=sum)
# plt.xticks(rotation=90)
# plt.title("Total Disturbance Counts by Species")
# plt.show()

# # how much will survey year impact model decisions?
# plt.figure(figsize=(10,5))
# sns.boxplot(data=df, x='is_disturbed', y='years_from_raster')
# plt.title("Temporal Gap vs. Disturbance Label")
# plt.show()

# calculating risk before splitting to ensure all species are captured
species_map = df.groupby('common_name')['is_disturbed'].mean()
df['species_risk'] = df['common_name'].map(species_map)


# dropping id values and columns that wold confused the model
# pointing y at 'is_disturbed'
X = df.drop(columns=['plot_id', 'is_disturbed', 'survey_year', 'common_name'])
y = df['is_disturbed']

# stratify=y ensures the 12% disturbance is equal in both sets
# prevents model from taking random 20% of records and having uneven distribution of cases
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42, stratify=y
)


# setting scale_pos_weight based on count_disturbed/count_stable = 7.3
model = XGBClassifier(
    n_estimators=200,      # how many trees total in the model
    max_depth=5,           # how many decisions each tree is allowed
    learning_rate=0.05,
    scale_pos_weight=7.3,  # weights the disturbed records heavier than stable
    random_state=42,
    eval_metric='logloss'
)

print("Training model on 10,000 plots...")
model.fit(X_train, y_train)

# finding out what the model actually predicts
y_pred = model.predict(X_test)

# creating paths for file saves
base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
data_dir = os.path.join(base_dir, 'data')
if not os.path.exists(data_dir):
    os.makedirs(data_dir)

# key on plot_id index to refer to pre-model df 
results = X_test.copy()
results['plot_id'] = df.loc[X_test.index, 'plot_id'] 
results['actual'] = y_test
results['predicted'] = y_pred 

# backup of ml_training_data_dominant from postgres
df.to_csv(os.path.join(data_dir, 'ml_training_data_dominant_backup.csv'), index=False)

print(f"Postgres ingestion .csv saved to {data_dir}")

# false positive records into .csv
false_positives = results[(results['actual'] == 0) & (results['predicted'] == 1)]
cols = ['plot_id', 'actual', 'predicted'] + [c for c in results.columns if c not in ['plot_id', 'actual', 'predicted']]
false_positives[cols].to_csv(os.path.join(data_dir, 'false_positives_audit.csv'), index=False)

print(f"Audit files exported to {data_dir}")


# obtaining a report on how well the model's prediction stacks up
# to the known disturbed or stable records
print("\n--- Model Performance ---")
print(classification_report(y_test, y_pred))

# vizing the confusion matrix
fig, ax = plt.subplots(1, 2, figsize=(15, 6))

cm_display = ConfusionMatrixDisplay.from_estimator(
    model, X_test, y_test, display_labels=['Stable', 'Disturbed'], 
    cmap='Greens', ax=ax[0]
)
ax[0].set_title("Confusion Matrix")

# determining which features were the most important
importances = pd.Series(model.feature_importances_, index=X.columns).sort_values()
importances.plot(kind='barh', ax=ax[1], color='skyblue')
ax[1].set_title("What Predicted the Disturbance?")

plt.tight_layout()
plt.savefig('project_screenshots/model_results.png')
plt.show()
