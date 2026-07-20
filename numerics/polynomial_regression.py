import numpy as np

x_data = np.array([0.0, 1.0, 2.0, 3.0])
y_data = np.array([1.0, 2.1, 5.0, 10.2])

def polynomial_regression(x, y, degree):
    n = len(x)
    
    # Initialize our design matrix with a column of 1s (x^0)
    X = np.ones((n, 1))
    
    # Dynamically expand columns for each exponential level requested
    for p in range(1, degree + 1):
        column_xp = np.reshape(x**p, (n, 1))
        X = np.hstack((X, column_xp))
        
    # Solve using the Normal Equation: (X^T * X)^-1 * X^T * y
    coefficients = np.dot(np.linalg.inv(np.dot(X.T, X)), np.dot(X.T, y))
    return coefficients

# Compute a 2nd-degree quadratic curve fit
coeffs = polynomial_regression(x_data, y_data, degree=2)

print("--- Polynomial Regression Results (Degree 2) ---")
equation_parts = [f"{coeffs[i]:.4f}*x^{i}" if i > 0 else f"{coeffs[i]:.4f}" for i in range(len(coeffs))]
print("Model Formula: y =", " + ".join(equation_parts))