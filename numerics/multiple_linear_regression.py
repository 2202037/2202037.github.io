import numpy as np

# 1. Row elements: [Size, Bedrooms]
X_raw = np.array([
    [1500.0, 3.0],
    [2000.0, 4.0],
    [1200.0, 2.0]
])
y = np.array([300000.0, 400000.0, 250000.0])

def multiple_linear_regression(X_data, y_vector):
    n = len(y_vector)
    
    # Prepend a column of 1s to match our base bias intercept offset coefficient
    X = np.hstack((np.ones((n, 1)), X_data))
    
    # Implement the Normal Equation matrix math: W = (X^T * X)^-1 * X^T * y
    XT_X_inverse = np.linalg.inv(np.dot(X.T, X))
    XT_y = np.dot(X.T, y_vector)
    
    weights = np.dot(XT_X_inverse, XT_y)
    return weights

W = multiple_linear_regression(X_raw, y)
print("--- Multiple Linear Regression Results ---")
print(f"Intercept (w0): {W[0]:.2f}")
print(f"Size Coefficient (w1): {W[1]:.2f}")
print(f"Bedroom Coefficient (w2): {W[2]:.2f}")