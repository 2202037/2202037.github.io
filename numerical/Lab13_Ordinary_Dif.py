def euler_method(f, t0, y0, t_end, h):
    """
    Approximates the solution of y' = f(t, y) using Euler's method.
    
    Parameters:
    f     : function - The derivative function f(t, y)
    t0    : float    - Initial time
    y0    : float    - Initial value of y at t0
    t_end : float    - End time of the simulation
    h     : float    - Step size
    
    Returns:
    t_values : list - The time steps
    y_values : list - The approximated y values at each step
    """
    t_values = [t0]
    y_values = [y0]
    
    t = t0
    y = y0
    
    # Loop until we reach the end time
    while t < t_end:
        # Correct potential floating-point overshoot at the final step
        if t + h > t_end:
            h = t_end - t
            
        y = y + h * f(t, y)
        t = t + h
        
        t_values.append(t)
        y_values.append(y)
        
    return t_values, y_values

# --- Example Usage ---
if __name__ == "__main__":
    # Define the ODE: dy/dt = y - t
    # Analytical solution with y(0)=1 is y(t) = t + 1 + e^t
    def my_ode(t, y):
        return y - t

    # Initial conditions
    t_start = 0.0
    y_start = 2.0  
    end_time = 2.0
    step = 0.5     

    times, estimates = euler_method(my_ode, t_start, y_start, end_time, step)

    
    print(f"{'t':>6} | {'Estimated y':>12}")
    print("-" * 23)
    for t, y in zip(times, estimates):
        print(f"{t:6.2f} | {y:12.4f}")