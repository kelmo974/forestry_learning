try:

    import pandas as pd
    from sklearn.ensemble import RandomForestClassifier

    data = {
        'canopy_height': [15, 2, 20, 5],
        'leaf_density': [0.8, 0.2, 0.9, 0.3],
        'is_healthy': [1, 0, 1, 0] # 1 = Healthy, 0 = Unhealthy
        }

    df = pd.DataFrame(data)

    test_model = RandomForestClassifier()

    X = df[['canopy_height', 'leaf_density']]
    y = df[['is_healthy']]

    test_model.fit(X, y)

    print("successfully trained this model")

except ImportError as e: 
    print(f"dang, something is missing, probably a library {e}")
except Exception as e:
    print(f"an unexpected error has occurred: {e}")