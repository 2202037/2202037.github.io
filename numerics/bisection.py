import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

# 1. Define the function
def f(x):
    return 2*x**3 - x - 2

# 2. Define the Bisection Algorithm
def bisection_method(a, b, tolerance=1e-5, max_iter=20):
    # Safety Check: Do a and b actually bracket a root?
    if f(a) * f(b) >= 0:
        raise ValueError("The initial points do not bracket the root (they have the same sign).")
        
    results = []
    
    for i in range(max_iter):
        # Calculate the midpoint
        c = (a + b) / 2.0
        fc = f(c)
        
        # Calculate the maximum possible error (half the current interval)
        error = (b - a) / 2.0
        
        results.append({
            'Iteration': i + 1,
            'a (left)': round(a, 6),
            'b (right)': round(b, 6),
            'c (mid)': round(c, 6),
            'f(c)': round(fc, 6),
            'Max Error': error
        })
        
        # Stop if we hit the exact root OR if our bracket is smaller than the tolerance
        if abs(fc) == 0.0 or error < tolerance:
            break
            
        # The core logic: which boundary do we replace?
        # If f(a) and f(c) have opposite signs, multiplying them gives a negative number.
        if f(a) * fc < 0:
            b = c  # The root is in the left half
        else:
            a = c  # The root is in the right half
            
    return pd.DataFrame(results), c

# 3. Execute the function
bracket_left = 1.0
bracket_right = 2.0
df_results, final_root = bisection_method(bracket_left, bracket_right)

print("Bisection Method Iteration Table:")
print(df_results.to_string(index=False))
print("-" * 65)
print(f"Final Estimated Root: x = {final_root:.6f}")

# 4. Plotting the solution
x_vals = np.linspace(0.5, 2.5, 100)
y_vals = f(x_vals)

plt.figure(figsize=(8, 5))
plt.plot(x_vals, y_vals, color='blue', label='f(x) = x³ - x - 2', linewidth=2)
plt.axhline(0, color='black', linewidth=1) # x-axis

# Highlight the initial bracket and final root
plt.axvline(bracket_left, color='red', linestyle='--', label='Initial Bracket [a, b]')
plt.axvline(bracket_right, color='red', linestyle='--')
plt.scatter(final_root, 0, color='green', marker='x', s=150, zorder=5, label=f'Root (x={final_root:.3f})')

plt.title("Bisection Method Root Finding")
plt.xlabel('x')
plt.ylabel('f(x)')
plt.grid(True, alpha=0.3)
plt.legend()
plt.show()