import sympy as sp

def picard_method_sympy():
    x, t = sp.symbols('x t')
    
    # Initialize y_0 as a flat symbolic constant
    y = 1
    
    print("--- Picard's Analytical Expressions ---")
    # Generate 3 successive approximation equations
    for approximation in range(1, 4):
        # Define f(t, y) symbolically using our previous y expression
        f_t_y = t + y
        
        # Perform symbolic integration: y_next = y0 + integral(f(t, y)) from 0 to x
        y = 1 + sp.integrate(f_t_y, (t, 0, x))
        print(f"y^({approximation}) = {sp.simplify(y)}")
        
    # Evaluate our analytical equation at x = 0.2
    numerical_val = y.subs(x, 0.2)
    print(f"\nEvaluated y(0.2) via Picard polynomial: {float(numerical_val):.4f}")

picard_method_sympy()