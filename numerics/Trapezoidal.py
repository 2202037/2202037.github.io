import numpy as np

# 1. Define the function to integrate
def f(x):
    return x**2

# 2. Define the Composite Trapezoidal Algorithm
def trapezoidal_rule(f, a, b, n):
    # Calculate the width of each trapezoid (h)
    h = (b - a) / n
    
    # Generate the x-coordinates for all the trapezoid walls
    # np.linspace creates an array of 'n+1' evenly spaced points between 'a' and 'b'
    x = np.linspace(a, b, n + 1)
    
    # Calculate all the corresponding y-values
    y = f(x)
    
    # Apply the formula: (h/2) * [y_first + 2*(sum of y_middles) + y_last]
    # y[1:-1] slices the array to grab everything EXCEPT the first and last items
    integral = (h / 2) * (y[0] + 2 * sum(y[1:-1]) + y[-1])
    
    return integral

# 3. Execute the function
a = 0.0  # Lower bound
b = 2.0  # Upper bound
n = 10   # Number of trapezoids (higher = more accurate)

estimated_area = trapezoidal_rule(f, a, b, n)
exact_area = 2.66666667

print(f"Integration Limits: [{a}, {b}] using {n} trapezoids")
print("-" * 45)
print(f"Estimated Area: {estimated_area:.6f}")
print(f"Exact Area:     {exact_area:.6f}")
print(f"Error:          {abs(exact_area - estimated_area):.6f}")