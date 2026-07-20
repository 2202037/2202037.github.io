import numpy as np

# 1. Prepare the Example Dataset from the slides
x = np.array([1, 2, 3])
y = np.array([2, 4, 6])

# 2. Mathematical calculation for Ordinary Least Squares (OLS)
n = len(x)
m_numerator = n * np.sum(x * y) - np.sum(x) * np.sum(y)
m_denominator = n * np.sum(x**2) - (np.sum(x))**2

# Calculate final slope (m) and intercept (b) directly
m_optimal = m_numerator / m_denominator
b_optimal = np.mean(y) - m_optimal * np.mean(x)

# 3. Calculate Final Predictions and Loss (MSE)
y_pred = m_optimal * x + b_optimal
mse_loss = np.mean((y - y_pred) ** 2)

print("--- LEAST SQUARES REGRESSION (OLS) RESULTS ---")
print(f"Optimal Slope (m): {m_optimal:.4f}")
print(f"Optimal Intercept (b): {b_optimal:.4f}")
print(f"Final Mean Squared Error (Loss): {mse_loss:.4f}")
print(f"Predictions: {y_pred}")
