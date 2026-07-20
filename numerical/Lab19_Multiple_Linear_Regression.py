import numpy as np

# 1. Prepare dummy dataset
X = np.array([
    [1, 2],
    [2, 1],
    [3, 4],
    [4, 3]
])
y = np.array([6, 5, 11, 10])

n_samples, n_features = X.shape

# Step 1: Initialize weights (one per feature) and bias to zero
W = np.zeros(n_features)
b = 0.0
alpha = 0.01  # Learning rate
iterations = 3000

print("--- MULTIPLE LINEAR REGRESSION VIA GRADIENT DESCENT ---")

# Training loop
for i in range(1, iterations + 1):
    # Step 2: Vectorized prediction calculation
    y_pred = np.dot(X, W) + b
    
    # Step 3: Compute gradients for weights and bias
    # Errors = (y_pred - y)
    error = y_pred - y
    dW = (2 / n_samples) * np.dot(X.T, error)
    db = (2 / n_samples) * np.sum(error)
    
    # Step 4: Update parameters simultaneously
    W = W - alpha * dW
    b = b - alpha * db
    
    # Track the loss (Mean Squared Error)
    loss = np.mean(error ** 2)

# Final outputs after convergence
print(f"Final Intercept (b): {b:.4f}")
print(f"Final Weights (W): {W}")
print(f"Final Loss (MSE): {loss:.6f}")
print(f"Model Equation: Y = {b:.2f} + {W[0]:.2f}*X1 + {W[1]:.2f}*X2")
