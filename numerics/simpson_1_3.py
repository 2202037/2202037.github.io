import numpy as np

# 1. Define the function to integrate
def f(x):
    return x**2

# 2. Define the Simpson's 1/3 Algorithm
def simpsons_one_third(f, a, b, n):
    # Strict rule: n must be an even number
    if n % 2 != 0:
        raise ValueError("Simpson's 1/3 Rule requires an even number of intervals (n).")
        
    h = (b - a) / n
    x = np.linspace(a, b, n + 1)
    y = f(x)
    
    # Grab the first and last y-values
    y_first = y[0]
    y_last = y[-1]
    
    # Sum the y-values at odd indices: y[1], y[3], y[5]...
    # Array slicing syntax: array[start:stop:step]
    sum_odds = np.sum(y[1:-1:2])
    
    # Sum the y-values at even indices: y[2], y[4], y[6]...
    sum_evens = np.sum(y[2:-1:2])
    
    # Apply the 1/3 formula
    integral = (h / 3) * (y_first + 4 * sum_odds + 2 * sum_evens + y_last)
    
    return integral

# 3. Execute the function
a = 0.0
b = 2.0
# We only need n=2 (a single parabola) to nail this!
n = 2   

estimated_area = simpsons_one_third(f, a, b, n)
exact_area = 2.66666667

print(f"Integration Limits: [{a}, {b}] using {n} intervals")
print("-" * 45)
print(f"Estimated Area: {estimated_area:.6f}")
print(f"Exact Area:     {exact_area:.6f}")
print(f"Error:          {abs(exact_area - estimated_area):.6f}")