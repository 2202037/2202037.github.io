import numpy as np

x = np.array([10, 20, 30, 40], dtype=float)
y = np.array([11, 23, 39, 61], dtype=float)

def newton_forward(x_data, y_data, target):
    n = len(x_data)
    h = x_data[1] - x_data[0] # Step size
    u = (target - x_data[0]) / h
    
    # Generate difference matrix
    diff = np.zeros((n, n))
    diff[:, 0] = y_data
    for j in range(1, n):
        for i in range(n - j):
            diff[i, j] = diff[i + 1, j - 1] - diff[i, j - 1]
            
    # Evaluate forward formula
    result = diff[0, 0]
    u_term = 1.0
    fact = 1.0
    for i in range(1, n):
        u_term *= (u - (i - 1))
        fact *= i
        result += (u_term * diff[0, i]) / fact
    return result

def newton_backward(x_data, y_data, target):
    n = len(x_data)
    h = x_data[1] - x_data[0]
    u = (target - x_data[-1]) / h # Uses the last x element
    
    # Generate difference matrix
    diff = np.zeros((n, n))
    diff[:, 0] = y_data
    for j in range(1, n):
        for i in range(n - j):
            diff[i, j] = diff[i + 1, j - 1] - diff[i, j - 1]
            
    # Evaluate backward formula (moving up from the bottom boundary)
    result = diff[n - 1, 0]
    u_term = 1.0
    fact = 1.0
    for i in range(1, n):
        u_term *= (u + (i - 1))
        fact *= i
        result += (u_term * diff[n - 1 - i, i]) / fact
    return result

# Execution
y_forward = newton_forward(x, y, 15)
y_backward = newton_backward(x, y, 35)

print(f"Newton Forward (at x=15):  y = {y_forward:.4f}")
print(f"Newton Backward (at x=35): y = {y_backward:.4f}")