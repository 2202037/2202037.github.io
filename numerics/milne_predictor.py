def milne_method(f, x_history, y_history, h):
    # Pull old values from our history arrays
    f_n   = f(x_history[3], y_history[3]) # f at x=0.3
    f_nm1 = f(x_history[2], y_history[2]) # f at x=0.2
    f_nm2 = f(x_history[1], y_history[1]) # f at x=0.1
    
    # 1. Predictor step
    y_pred = y_history[0] + (4 * h / 3.0) * (2 * f_n - f_nm1 + 2 * f_nm2)
    x_next = x_history[3] + h
    
    # Evaluate slope at our predicted position
    f_next_pred = f(x_next, y_pred)
    
    # 2. Corrector step
    y_corr = y_history[2] + (h / 3.0) * (f_next_pred + 4 * f_n + f_nm1)
    
    return y_pred, y_corr

x_hist = [0.0, 0.1, 0.2, 0.3]
y_hist = [1.0, 1.1103, 1.2428, 1.3997]

pred, corr = milne_method(f, x_hist, y_hist, h=0.1)
print(f"Milne Predicted y(0.4): {pred:.4f}")
print(f"Milne Corrected y(0.4): {corr:.4f}")