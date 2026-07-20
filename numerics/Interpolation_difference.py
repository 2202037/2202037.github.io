import numpy as np
import pandas as pd

# 1. Inputs
x = np.array([10, 20, 30, 40], dtype=float)
y = np.array([11, 23, 39, 61], dtype=float)

def generate_difference_table(x_data, y_data):
    n = len(x_data)
    # Create an empty n x n matrix to store differences
    diff_matrix = np.zeros((n, n))
    
    # The first column is just our raw y data
    diff_matrix[:, 0] = y_data
    
    # Calculate higher-order differences column by column
    for col in range(1, n):
        for row in range(n - col):
            diff_matrix[row, col] = diff_matrix[row + 1, col - 1] - diff_matrix[row, col - 1]
            
    # Convert to a Pandas DataFrame for beautifully labeled columns
    columns = ["y"] + [f"Δ^{i}y" for i in range(1, n)]
    df = pd.DataFrame(diff_matrix, columns=columns)
    df.insert(0, "x", x_data)
    
    # Replace trailing zeros with empty strings to keep the triangle clean
    return df.replace(0.0, "")

table = generate_difference_table(x, y)
print("--- Forward/Diagonal Difference Table ---")
print(table.to_string(index=False))