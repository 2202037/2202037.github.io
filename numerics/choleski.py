import numpy as np

# 1. Define your stable, non-singular inputs
A = np.array([
    [2.0, 1.0, 1.0],
    [4.0, 3.0, 3.0],
    [8.0, 7.0, 9.0]
])

b = np.array([4.0, 10.0, 24.0])

# 2. Solve the entire system in exactly ONE line
x = np.linalg.solve(A, b)

print("--- The Ultimate Simple Solution ---")
print("Solution Vector (x):", x)