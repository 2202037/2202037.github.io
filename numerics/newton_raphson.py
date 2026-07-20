# def newton_raphson(f, df, x0, tolerance=1e-6, max_iterations=100):
#     """
#     Solves f(x) = 0 using the Newton-Raphson method.
    
#     Parameters:
#     f  : The original target function
#     df : The analytical derivative of the function f'(x)
#     x0 : The initial guess to start the algorithm
#     tolerance: Stop iterating if the step size falls below this value
#     max_iterations: Safety limit to prevent infinite loops
#     """
#     print(f"{'Iteration':<10}{'x_n':<12}{'f(x_n)':<14}{'f\'(x_n)':<12}{'Step Size':<12}")
#     print("-" * 62)
    
#     x_current = x0
    
#     for i in range(1, max_iterations + 1):
#         fx = f(x_current)
#         dfx = df(x_current)
        
#         # Safety Check: Prevent division by zero if we hit a flat plateau (local extrema)
#         if dfx == 0:
#             print("Mathematical Failure: Derivative hit zero. Tangent line is flat.")
#             return None
            
#         # Apply the Newton-Raphson formula: x_next = x_n - f(x_n)/f'(x_n)
#         x_next = x_current - (fx / dfx)
        
#         # Calculate how much our guess changed this step
#         step_size = abs(x_next - x_current)
        
#         print(f"{i:<10}{x_current:<12.6f}{fx:<14.6f}{dfx:<12.6f}{step_size:<12.6f}")
        
#         # Check if our answer has converged within our acceptable error bounds
#         if step_size < tolerance:
#             print("-" * 62)
#             print(f"Success! Root found at x = {x_next:.6f} after {i} iterations.")
#             return x_next
            
#         # Update our position for the next iteration round
#         x_current = x_next
        
#     print("Warning: Max iterations reached without perfect convergence.")
#     return x_current

# # Define our sample problem mathematical functions
# def f(x):
#     return x**3 - 2*x - 5

# def df(x):
#     return 3*x**2 - 2

# # Execute the solver with an initial guess of x0 = 2.0
# root = newton_raphson(f, df, x0=2.0)




import numpy as np
import pandas as pd

# 1. Define our target functions using NumPy
def f(x):
    return x**3 - 2*x - 5

def df(x):
    return 3*x**2 - 2

# 2. Vectorized Newton-Raphson with Pandas Logging
def quick_newton_raphson(f, df, x0, tol=1e-6, max_iter=20):
    # Setup empty lists to collect our historical data rows
    history = []
    x_n = float(x0)
    
    for i in range(1, max_iter + 1):
        fx = f(x_n)
        dfx = df(x_n)
        
        if dfx == 0:
            print("Slope is exactly zero! Algorithm halted.")
            return None
            
        # Standard Newton-Raphson formula step
        x_next = x_n - (fx / dfx)
        step_size = abs(x_next - x_n)
        
        # Log this iteration step as a clean dictionary entry
        history.append({
            "Iteration": i,
            "x_n": x_n,
            "f(x_n)": fx,
            "f'(x_n)": dfx,
            "Step Size": step_size
        })
        
        if step_size < tol:
            break
            
        x_n = x_next
        
    # Magic step: Convert our list of dictionaries into a polished Pandas DataFrame
    df_history = pd.DataFrame(history).set_index("Iteration")
    return x_next, df_history

# 3. Execute and Display
root, report_card = quick_newton_raphson(f, df, x0=2.0)

print("-" * 65)
print(f"Calculated Root: {root:.6f}")
print("-" * 65)
print(report_card)