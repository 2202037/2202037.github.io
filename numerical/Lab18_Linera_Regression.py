import numpy as np

# 1. Prepare the Example Dataset from the slides
x = np.array([1, 2, 3])
y = np.array([2, 4, 6])
n = len(x)

# Step 1: Initialize values
m = 0.0
b = 0.0
alpha = 0.01  # Learning rate
iterations = 2000  # Number of steps to reach convergence

print("--- LINEAR REGRESSION VIA GRADIENT DESCENT ---")

# Training loop
for i in range(1, iterations + 1):
    # Step 2: Define predictions and errors
    y_pred = m * x + b
    
    # Step 3: Compute Gradients (using partial derivatives from the slides)
    dm = (-2 / n) * np.sum(x * (y - y_pred))
    db = (-2 / n) * np.sum(y - y_pred)
    
    # Step 4: Update m and b
    m = m - alpha * dm
    b = b - alpha * db
    
    # Calculate Loss (Mean Squared Error)
    loss = (1 / n) * np.sum((y - y_pred) ** 2)
    
    # Print progress for the first 2 iterations (matching the slide hand-calculations)
    if i <= 2:
        print(f"\nIteration {i}:")
        print(f"  Predictions (y_hat): {y_pred}")
        print(f"  Gradient w.r.t m (dLoss/dm): {dm:.4f}")
        print(f"  Gradient w.r.t b (dLoss/db): {db:.4f}")
        print(f"  Updated m: {m:.4f}, Updated b: {b:.4f}")
        print(f"  Loss (MSE): {loss:.4f}")

# Final outputs after all iterations
print("\n--- FINAL CONVERGENCE RESULTS ---")
print(f"Total Iterations: {iterations}")
print(f"Final Slope (m): {m:.4f}")
print(f"Final Intercept (b): {b:.4f}")
print(f"Final Loss (MSE): {loss:.4f}")
print(f"Final Model Prediction Equation: y ≈ {m:.2f}x")