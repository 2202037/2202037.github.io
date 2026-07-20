import numpy as np

# Unequally spaced inputs
x_irregular = np.array([0.0, 1.0, 4.0, 6.0])
y_irregular = np.array([1.0, 2.0, 5.0, 10.0])

def lagrange_interpolation(x_data, y_data, target):
    n = len(x_data)
    total_sum = 0.0
    
    # Outermost loop sums up the contributions of each individual point
    for i in range(n):
        # Calculate the Lagrange basis polynomial term L_i(x)
        term = 1.0
        for j in range(n):
            if i != j:
                # Multiply product scaling fractions
                term *= (target - x_data[j]) / (x_data[i] - x_data[j])
                
        # Scale the basis weight by the actual y coordinate and accumulate
        total_sum += term * y_data[i]
        
    return total_sum

# Execution
y_interp = lagrange_interpolation(x_irregular, y_irregular, target=3.0)
print(f"Lagrange Interpolation (at x=3): y = {y_interp:.4f}")