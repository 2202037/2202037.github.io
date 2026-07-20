import numpy as np

# 1. Inputs
X = np.array([1.0, 2.0, 3.0, 4.0])
y = np.array([3.0, 5.0, 7.0, 9.0])

def linear_gradient_descent(X, y, lr=0.05, epochs=500):
    # Initialize random parameters
    w, b = 0.0, 0.0
    n = len(X)
    
    for epoch in range(epochs):
        # Calculate current predictions
        y_pred = w * X + b
        
        # Calculate partial derivatives (gradients)
        dw = (-2/n) * sum(X * (y - y_pred))
        db = (-2/n) * sum(y - y_pred)
        
        # Update weights matching our learning rate
        w -= lr * dw
        b -= lr * db
        
    return w, b

# Execute optimization loop
weight, bias = linear_gradient_descent(X, y)
print("--- Linear Regression via Gradient Descent ---")
print(f"Trained Slope (w): {weight:.4f}")
print(f"Trained Intercept (b): {bias:.4f}")
print(f"Derived Model Equation: y = {weight:.4f}x + {bias:.4f}")