import numpy as np
import pandas as pd

# 1. Define the rearranged function g(x)
def g(x):
    # Using np.cbrt for cube root to handle negatives safely if they pop up
    return np.cbrt(x + 2)

# 2. Define the Iteration Algorithm
def fixed_point_iteration(x0, tolerance=1e-5, max_iter=20):
    results = []
    x_current = x0
    
    for i in range(max_iter):
        # Plug the current guess into g(x) to get the next guess
        x_next = g(x_current)
        
        # Calculate the error (how much the value shifted)
        error = abs(x_next - x_current)
        
        results.append({
            'Iteration': i + 1,
            'x_i (old)': round(x_current, 6),
            'g(x_i) = x_next': round(x_next, 6),
            'Shift Error': error
        })
        
        # Stop if our guess has stopped moving significantly
        if error < tolerance:
            break
            
        # Update the guess for the next loop
        x_current = x_next
        
    return pd.DataFrame(results), x_next

# 3. Execute the function
initial_guess = 1.50
df_results, final_root = fixed_point_iteration(initial_guess)

print("Fixed-Point Iteration Table:")
print(df_results.to_string(index=False))
print("-" * 55)
print(f"Final Estimated Root: x = {final_root:.6f}")