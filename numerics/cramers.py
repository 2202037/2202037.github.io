# import numpy as np

# # 1. Define the coefficient matrix A and the right-hand side b
# A = np.array([[ 1.0,  1.0,  1.0],
#               [ 2.0,  5.0,  1.0],
#               [-3.0,  1.0,  5.0]])

# b = np.array([6.0, 15.0, 14.0])

# # 2. Define Cramer's Rule Algorithm
# def cramers_rule(A, b):
#     # Get the number of variables
#     n = len(b)
    
#     # Calculate the determinant of the main matrix
#     det_A = np.linalg.det(A)
    
#     # Safety Check: Can we actually solve this?
#     if abs(det_A) < 1e-9:
#         raise ValueError("Determinant is zero. The system has no unique solution.")
        
#     print(f"Main Determinant |A| = {det_A:.4f}\n")
    
#     # Array to hold our final answers
#     x = np.zeros(n)
    
#     # Loop through each variable
#     for i in range(n):
#         # Create a fresh copy of A so we don't destroy the original
#         A_i = A.copy()
        
#         # Overwrite the i-th column with vector b
#         A_i[:, i] = b
        
#         # Calculate the determinant of the modified matrix
#         det_Ai = np.linalg.det(A_i)
        
#         # Calculate the final variable value
#         x[i] = det_Ai / det_A
        
#         print(f"Determinant |A_{i+1}| = {det_Ai:.4f}")
#         print(f"x_{i+1} = {det_Ai:.4f} / {det_A:.4f} = {x[i]:.4f}\n")
        
#     return x

# # 3. Execute the function
# final_x = cramers_rule(A, b)

# print("-" * 35)
# print(f"Final Solution Vector: x = {np.round(final_x, 4)}")






# Input taking feature added

import numpy as np

# --- 1. Define Cramer's Rule Algorithm (Unchanged Logic) ---
def cramers_rule(A, b):
    n = len(b)
    det_A = np.linalg.det(A)
    
    # Safety Check: Can we actually solve this?
    if abs(det_A) < 1e-9:
        raise ValueError("Determinant is zero. The system has no unique solution.")
        
    print(f"\nMain Determinant |A| = {det_A:.4f}\n")
    
    x = np.zeros(n)
    
    for i in range(n):
        A_i = A.copy()
        A_i[:, i] = b  # Overwrite the i-th column with vector b
        det_Ai = np.linalg.det(A_i)
        x[i] = det_Ai / det_A
        
        print(f"Determinant |A_{i+1}| = {det_Ai:.4f}")
        print(f"x_{i+1} = {det_Ai:.4f} / {det_A:.4f} = {x[i]:.4f}\n")
        
    return x

# --- 2. Dynamic User Input Section ---
try:
    # Get matrix size
    n = int(input("Enter the number of variables (e.g., 3 for a 3x3 matrix): "))
    
    print("\n--- Enter Coefficient Matrix A row by row ---")
    print("Separate numbers in the same row with spaces (e.g., 1 2 3)")
    
    rows = []
    for i in range(n):
        row_input = input(f"Enter elements for Row {i+1}: ")
        # Split the string by spaces and convert each piece into a float
        row_data = [float(val) for val in row_input.split()]
        
        # Validation check
        if len(row_data) != n:
            raise ValueError(f"Expected exactly {n} elements, but got {len(row_data)}.")
        rows.append(row_data)
        
    # Convert list of lists into a NumPy array
    A = np.array(rows)
    
    print("\n--- Enter Constants Vector b ---")
    b_input = input(f"Enter the {n} elements of vector b (separated by spaces): ")
    b = np.array([float(val) for val in b_input.split()])
    
    if len(b) != n:
        raise ValueError(f"Expected exactly {n} elements for vector b.")

    # --- 3. Execute the function ---
    final_x = cramers_rule(A, b)

    print("-" * 35)
    print(f"Final Solution Vector: x = {np.round(final_x, 4)}")

except ValueError as e:
    print(f"\n[Input Error]: {e}")
    print("Please make sure you only enter numbers and match the required counts.")