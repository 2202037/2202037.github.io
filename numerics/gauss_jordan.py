import numpy as np

# 1. Define the system
A = np.array([[ 1.0,  1.0,  1.0],
              [ 2.0,  5.0,  1.0],
              [-3.0,  1.0,  5.0]])

b = np.array([6.0, 15.0, 14.0])

# 2. Define the Gauss-Jordan Algorithm
def gauss_jordan(A, b):
    n = len(b)
    
    # Create the augmented matrix [A | b]
    # We force it to be float so Python doesn't truncate decimals
    M = np.hstack((A, b.reshape(-1, 1))).astype(float)
    
    print("Initial Augmented Matrix:")
    print(np.round(M, 2), "\n")
    
    # Loop through every column (and therefore every pivot diagonal)
    for i in range(n):
        
        # Isolate the pivot element on the main diagonal
        pivot = M[i, i]
        
        # Safety Check to prevent dividing by zero
        if abs(pivot) < 1e-9:
            raise ValueError("Zero pivot encountered! This basic script requires row swapping (partial pivoting) to proceed.")
            
        # Step A: Divide the entire pivot row by the pivot to make the diagonal exactly 1
        M[i] = M[i] / pivot
        
        # Step B: Eliminate all other entries in the current column (both above and below!)
        for j in range(n):
            if i != j: # Skip the pivot row itself
                factor = M[j, i]
                M[j] = M[j] - factor * M[i]
                
        print(f"Matrix after pivoting column {i+1}:")
        print(np.round(M, 2), "\n")
                
    # The left side is now an identity matrix. 
    # The rightmost column contains the final answers.
    x = M[:, -1]
    
    return x

# 3. Execute the function
final_solution = gauss_jordan(A, b)

print("-" * 40)
print(f"Final Solution Vector: x = {np.round(final_solution, 4)}")