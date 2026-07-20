import numpy as np
import matplotlib.pyplot as plt


# --------------------------------------------------
# LU Factorization
# --------------------------------------------------
def LUfactorization(A):

    A = np.array(A, dtype=float)

    row, column = A.shape

    if row != column:
        print("Matrix must be square.")
        return None, None

    L = np.eye(row)
    U = np.zeros((row, column))

    # LU Factorization
    for i in range(row):

        # Calculate U
        for j in range(i, column):

            total = 0

            for k in range(i):
                total += L[i, k] * U[k, j]

            U[i, j] = A[i, j] - total

        # Calculate L
        for j in range(i + 1, row):

            total = 0

            for k in range(i):
                total += L[j, k] * U[k, i]

            L[j, i] = (A[j, i] - total) / U[i, i]

    return L, U


# --------------------------------------------------
# Forward Substitution
# --------------------------------------------------
def ForwardSubstitution(L, b):

    row, column = L.shape

    Y = np.zeros(row)

    for i in range(row):

        total = 0

        for j in range(i):
            total += L[i, j] * Y[j]

        Y[i] = b[i] - total

    return Y


# --------------------------------------------------
# Backward Substitution
# --------------------------------------------------
def BackwardSubstitution(U, Y):

    row, column = U.shape

    X = np.zeros(row)

    for i in range(row - 1, -1, -1):

        total = 0

        for j in range(i + 1, column):
            total += U[i, j] * X[j]

        X[i] = (Y[i] - total) / U[i, i]

    return X


# --------------------------------------------------
# Input Matrix A
# --------------------------------------------------
A = [
    [8.00, 3.22, 0.80, 0.00, 4.10],
    [3.22, 7.76, 2.33, 1.91, -1.03],
    [0.80, 2.33, 5.25, 1.00, 3.02],
    [0.00, 1.91, 1.00, 7.50, 1.03],
    [4.10, -1.03, 3.02, 1.03, 6.44]
]

# Constant Vector B
b = [9.45, -12.20, 7.78, -8.10, 10.00]


# --------------------------------------------------
# Matrix Size
# --------------------------------------------------
A = np.array(A, dtype=float)

row, column = A.shape

print("\nLU FACTORIZATION METHOD\n")

print("Number of Rows    =", row)
print("Number of Columns =", column)


# --------------------------------------------------
# LU Factorization
# --------------------------------------------------
L, U = LUfactorization(A)

print("\nLower Triangular Matrix (L):")
print(L)

print("\nUpper Triangular Matrix (U):")
print(U)


# --------------------------------------------------
# Forward Substitution
# --------------------------------------------------
Y = ForwardSubstitution(L, b)

print("\nY Vector:")
print(Y)


# --------------------------------------------------
# Backward Substitution
# --------------------------------------------------
X = BackwardSubstitution(U, Y)

print("\nSolution Vector (X):")
print(X)


# --------------------------------------------------
# Verification
# --------------------------------------------------
print("\nVerification using NumPy:")
print(np.linalg.solve(A, b))


# --------------------------------------------------
# Graph
# --------------------------------------------------
variables = ['X1', 'X2', 'X3', 'X4', 'X5']

plt.figure(figsize=(8, 5))

plt.plot(variables, X, marker='o', linewidth=2, label='Solution')
plt.scatter(variables, X, color='red')

plt.title("LU Factorization Method")
plt.xlabel("Variables")
plt.ylabel("Values")

plt.grid(True)
plt.legend()

for i in range(len(X)):
    plt.text(i, X[i], f"{X[i]:.3f}", ha='center', va='bottom')

plt.show()