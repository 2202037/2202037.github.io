import numpy as np

# 1. Define the function to integrate (a cubic function)
def f(x):
    return x**3

# 2. Define the Simpson's 3/8 Algorithm
def simpsons_three_eighths(f, a, b, n):
    # Strict rule: n must be a multiple of 3
    if n % 3 != 0:
        raise ValueError("Simpson's 3/8 Rule requires 'n' to be a multiple of 3.")
        
    h = (b - a) / n
    x = np.linspace(a, b, n + 1)
    y = f(x)
    
    # Initialize the sum with the first and very last y-values
    total = y[0] + y[-1]
    
    # Loop through all the inner terms and apply the 3, 3, 2 pattern
    for i in range(1, n):
        if i % 3 == 0:
            total += 2 * y[i]  # Multiples of 3 get multiplied by 2
        else:
            total += 3 * y[i]  # Everything else gets multiplied by 3
            
    # Apply the 3/8 formula at the very end
    integral = (3 * h / 8) * total
    
    return integral

# 3. Execute the function
a = 0.0
b = 3.0
n = 3   # A single cubic segment requires 3 intervals

estimated_area = simpsons_three_eighths(f, a, b, n)
exact_area = 20.25

print(f"Integration Limits: [{a}, {b}] using {n} intervals")
print("-" * 45)
print(f"Estimated Area: {estimated_area:.6f}")
print(f"Exact Area:     {exact_area:.6f}")
print(f"Error:          {abs(exact_area - estimated_area):.6f}")