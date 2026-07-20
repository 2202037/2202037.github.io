import numpy as np

# Input Matrix
A = np.array([
    [8.00, 3.22, 0.80, 0.00, 4.10],
    [3.22, 7.76, 2.33, 1.91, -1.03],
    [0.80, 2.33, 5.25, 1.00, 3.02],
    [0.00, 1.91, 1.00, 7.50, 1.03],
    [4.10, -1.03, 3.02, 1.03, 6.44]
], dtype=float)

b = np.array([9.45, -12.20, 7.78, -8.10, 10.00])

n = len(A)

# Create L and U
L = np.eye(n)
U = np.zeros((n, n))

# -----------------------
# LU Factorization
# -----------------------
for i in range(n):

    # Find U
    for j in range(i, n):

        total = 0
        for k in range(i):
            total = total + L[i][k] * U[k][j]

        U[i][j] = A[i][j] - total

    # Find L
    for j in range(i + 1, n):

        total = 0
        for k in range(i):
            total = total + L[j][k] * U[k][i]

        L[j][i] = (A[j][i] - total) / U[i][i]

print("L Matrix")
print(L)

print("\nU Matrix")
print(U)

# -----------------------
# Forward Substitution
# Solve LY = B
# -----------------------
Y = np.zeros(n)

for i in range(n):

    total = 0

    for j in range(i):
        total = total + L[i][j] * Y[j]

    Y[i] = b[i] - total

print("\nY Vector")
print(Y)

# -----------------------
# Backward Substitution
# Solve UX = Y
# -----------------------
X = np.zeros(n)

for i in range(n-1, -1, -1):

    total = 0

    for j in range(i+1, n):
        total = total + U[i][j] * X[j]

    X[i] = (Y[i] - total) / U[i][i]

print("\nSolution")
print(X)

print("\nVerification")
print(np.linalg.solve(A, b))