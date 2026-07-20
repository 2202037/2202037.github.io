# import numpy as np
# import pandas as pd

# # 1. Define the function
# def f(x):
#     return x**3 - x - 2

# # 2. Define the False Position Algorithm
# def false_position_method(a, b, tolerance=1e-5, max_iter=20):
#     # Safety Check: Do a and b actually bracket a root?
#     if f(a) * f(b) >= 0:
#         raise ValueError("The initial points do not bracket the root.")
        
#     results = []
#     c_old = a # Variable to track our previous guess for error calculation
    
#     for i in range(max_iter):
#         fa = f(a)
#         fb = f(b)
        
#         # The core mathematical difference from Bisection:
#         c = (a * fb - b * fa) / (fb - fa)
#         fc = f(c)
        
#         # Calculate the error (how much our guess moved since last time)
#         error = abs(c - c_old)
        
#         results.append({
#             'Iteration': i + 1,
#             'a': round(a, 6),
#             'b': round(b, 6),
#             'c (guess)': round(c, 6),
#             'f(c)': round(fc, 6),
#             'Shift Error': error
#         })
        
#         # Stop if we hit the exact root OR if our guess stops shifting
#         if abs(fc) == 0.0 or error < tolerance:
#             break
            
#         # Update the bracket (Identical logic to Bisection)
#         if fa * fc < 0:
#             b = c  # Root is between a and c
#         else:
#             a = c  # Root is between c and b
            
#         c_old = c
            
#     return pd.DataFrame(results), c

# # 3. Execute the function
# df_results, final_root = false_position_method(1.0, 2.0)

# print("False Position Iteration Table:")
# print(df_results.to_string(index=False))
# print("-" * 65)
# print(f"Final Estimated Root: x = {final_root:.6f}")




import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

# --- SECTION 1. Define the function ---
def f(x):
    # The mathematical function we are analyzing
    return x**3 - x - 2

# --- SECTION 2. Define the False Position Algorithm ---
def false_position_method(a, b, tolerance=1e-5, max_iter=20):
    # Safety Check: Do a and b actually bracket a root?
    if f(a) * f(b) >= 0:
        raise ValueError("The initial points do not bracket the root.")
        
    results = []
    # c_old tracks our previous guess to calculate how much the guess shifted
    c_old = a 
    
    for i in range(max_iter):
        fa = f(a)
        fb = f(b)
        
        # --- THE CORE MATHEMATICS ---
        # Instead of a simple midpoint, we calculate the root of the
        # secant line connecting (a, f(a)) and (b, f(b)).
        c = (a * fb - b * fa) / (fb - fa)
        fc = f(c)
        
        # Calculate the error (how much our guess moved since last iteration)
        shift_error = abs(c - c_old)
        
        # Log the detailed snapshot of this iteration
        results.append({
            'Iteration': i + 1,
            'a': round(a, 6),
            'b': round(b, 6),
            'c (guess)': round(c, 6),
            'f(c)': round(fc, 6),
            'Shift Error': shift_error
        })
        
        # Stopping conditions: We hit the exact root OR the guess stopped shifting
        if abs(fc) == 0.0 or shift_error < tolerance:
            break
            
        # Update the bracket for the next step (identical logic to Bisection)
        if fa * fc < 0:
            b = c  # Root is in the left half
        else:
            a = c  # Root is in the right half
            
        # Update c_old for the next iteration's error calculation
        c_old = c
            
    return pd.DataFrame(results), c

# --- SECTION 3. Execute the function ---
# We define the starting boundaries and capture the returned data
bracket_left = 1.0
bracket_right = 2.0
df_results, final_root = false_position_method(bracket_left, bracket_right)

# Output the text results to the console
print("False Position Iteration Table:")
print(df_results.to_string(index=False))
print("-" * 65)
print(f"Final Estimated Root: x = {final_root:.6f}")

# --- SECTION 4. Plotting the solution (NEW GRAPHICAL REPRESENTATION) ---

# A. Generate smooth curve data
x_curve = np.linspace(0.8, 2.2, 100) # Define range just outside the bracket
y_curve = f(x_curve)

# B. Initialize the chart window
plt.figure(figsize=(10, 6))

# C. Draw fundamental reference lines
plt.plot(x_curve, y_curve, color='blue', label='f(x) = x³ - x - 2', linewidth=2.5) # The function curve
plt.axhline(0, color='black', linewidth=1) # The x-axis (y=0)

# D. Draw the initial vertical brackets [a, b] (Dashed Red Lines)
plt.axvline(bracket_left, color='red', linestyle='--', alpha=0.7, label='Initial Bracket [a, b]')
plt.axvline(bracket_right, color='red', linestyle='--', alpha=0.7)

# === THE CRUCIAL VISUALIZATION FOR FALSE POSITION ===
# We need to visualize the first few secant lines (Linear Interpolation)
# We draw lines connecting (a, f(a)) to (b, f(b)) for iterations 1, 2, and 3.

# Color palette for the secant lines
secant_colors = ['magenta', 'orange', 'cyan']

# Loop through the first 3 iterations stored in our DataFrame
for i in range(min(3, len(df_results))):
    # Extract the 'a' and 'b' coordinates used *during* that iteration loop
    current_a = df_results.iloc[i]['a']
    current_b = df_results.iloc[i]['b']
    
    # Define the two points of the secant line: (a, f(a)) and (b, f(b))
    point_A = [current_a, f(current_a)]
    point_B = [current_b, f(current_b)]
    
    # Extract X and Y pairs for plt.plot
    x_secant = [point_A[0], point_B[0]]
    y_secant = [point_A[1], point_B[1]]
    
    # Draw the straight secant line
    label_text = f'Secant Line {i+1} (Guess c={df_results.iloc[i]["c (guess)"]})'
    plt.plot(x_secant, y_secant, color=secant_colors[i], linestyle=':', linewidth=1.5, marker='o', markersize=4, label=label_text)

# E. Stamp the final calculated root (Large Green 'X')
plt.scatter(final_root, 0, color='green', marker='x', s=200, zorder=10, label=f'Final Root (x={final_root:.3f})')

# F. Final chart formatting and legend
plt.title("False Position (Regula Falsi) Root Finding")
plt.xlabel('x')
plt.ylabel('f(x)')
plt.grid(True, alpha=0.3)
plt.legend(loc='upper left', fontsize='small') # Place legend clearly
plt.tight_layout() # Optimize spacing

# G. Launch the graph window!
plt.show()