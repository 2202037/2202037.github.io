import numpy as np

# 1. Define the Symmetric Positive-Definite system
A = np.array([[ 4.0,  6.0,  2.0],
              [ 6.0, 10.0,  5.0],
              [ 2.0,  5.0, 14.0]])

b = np.array([22.0, 41.0, 54.0])

# 2. Define the Cholesky Algorithm
def cholesky_method(A, b):
    n = len(A)
    L = np.zeros((n, n))
    
    # Phase 1: Decompose A into L
    for i in range(n):
        for j in range(i + 1):
            # Sum up the previously calculated elements in the row
            sum_k = sum(L[i][k] * L[j][k] for k in range(j))
            
            if i == j: 
                # Formula for main diagonal (requires a square root)
                L[i][j] = np.sqrt(A[i][i] - sum_k)
            else:      
                # Formula for off-diagonal elements below the main diagonal
                L[i][j] = (A[i][j] - sum_k) / L[j][j]
                
    print("Lower Triangular Matrix (L):")
    print(np.round(L, 2), "\n")
                
    # Phase 2: Forward Substitution (Solve L * y = b)
    y = np.zeros(n)
    for i in range(n):
        sum_y = sum(L[i][k] * y[k] for k in range(i))
        y[i] = (b[i] - sum_y) / L[i][i]
        
    print(f"Intermediate Vector (y): {np.round(y, 2)}\n")
        
    # Phase 3: Backward Substitution (Solve L.T * x = y)
    x = np.zeros(n)
    # Loop backwards from the last row up to the first row
    for i in range(n - 1, -1, -1):
        # We use L[k][i] instead of L[i][k] because we are conceptually using L.T
        sum_x = sum(L[k][i] * x[k] for k in range(i + 1, n))
        x[i] = (y[i] - sum_x) / L[i][i]
        
    return x

# 3. Execute the function
final_solution = cholesky_method(A, b)

print("-" * 40)
print(f"Final Solution Vector: x = {np.round(final_solution, 4)}")