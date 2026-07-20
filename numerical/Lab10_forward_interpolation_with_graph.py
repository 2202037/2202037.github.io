import math
import numpy as np
import matplotlib.pyplot as plt


def calculate_difference_table(x, y):

    n = len(y)

    diff_table = [[0.0] * n for _ in range(n)]

    for i in range(n):
        diff_table[i][0] = y[i]

    for j in range(1, n):
        for i in range(n - j):
            diff_table[i][j] = diff_table[i + 1][j - 1] - diff_table[i][j - 1]

    return diff_table


def print_difference_table(x, diff_table):

    n = len(x)

    print("\nDifference Table\n")

    print("x\tY", end="")

    for i in range(1, n):
        print(f"\tΔ^{i}Y", end="")

    print()

    for i in range(n):
        print(f"{x[i]:.2f}\t{diff_table[i][0]:.4f}", end="")

        for j in range(1, n - i):
            print(f"\t{diff_table[i][j]:.4f}", end="")

        print()


def u_cal_forward(u, n):

    temp = u

    for i in range(1, n):
        temp *= (u - i)

    return temp


def newton_forward(x, y, target):

    diff_table = calculate_difference_table(x, y)

    print_difference_table(x, diff_table)

    h = x[1] - x[0]

    u = (target - x[0]) / h

    result = diff_table[0][0]

    for i in range(1, len(x)):
        result += (u_cal_forward(u, i) * diff_table[0][i]) / math.factorial(i)

    return result


# ---------------- Main ----------------

x = [0, 10, 20, 30, 40]
y = [20.0, 22.5, 27.0, 33.5, 41.0]

target = 15

answer = newton_forward(x, y, target)

print("\nInterpolated Value =", answer)

# ---------------- Graph ----------------

plt.figure(figsize=(8,5))

plt.plot(x, y, marker='o', linewidth=2, label="Given Data")

plt.scatter(target, answer, s=120, color='red', label="Interpolated Point")

plt.text(target, answer, f"({target},{answer:.2f})")

plt.title("Newton Forward Interpolation")

plt.xlabel("X")

plt.ylabel("Y")

plt.grid(True)

plt.legend()

plt.show()