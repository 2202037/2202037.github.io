import numpy as np
import matplotlib.pyplot as plt

# Number of data points
n = int(input("Enter number of data points: "))

# Input x and y values
x = []
y = []

for i in range(n):
    xi = float(input(f"Enter x{i}: "))
    yi = float(input(f"Enter y{i}: "))
    x.append(xi)
    y.append(yi)

# Point to interpolate
xp = float(input("Enter the value of x to interpolate: "))

# Lagrange interpolation function
def lagrange(x, y, xp):
    yp = 0

    for i in range(len(x)):
        term = y[i]

        for j in range(len(x)):
            if i != j:
                term *= (xp - x[j]) / (x[i] - x[j])

        yp += term

    return yp

# Calculate interpolated value
yp = lagrange(x, y, xp)

print(f"\nInterpolated value at x = {xp} is {yp:.6f}")

# Generate smooth curve
x_curve = np.linspace(min(x), max(x), 300)
y_curve = [lagrange(x, y, xi) for xi in x_curve]

# Plot
plt.figure(figsize=(8,6))

# Lagrange curve
plt.plot(x_curve, y_curve, label="Lagrange Polynomial")

# Original data points
plt.scatter(x, y, color='red', s=70, label="Given Points")

# Interpolated point
plt.scatter(xp, yp, color='green', s=90, label="Interpolated Point")

plt.title("Lagrange Interpolation")
plt.xlabel("x")
plt.ylabel("y")
plt.grid(True)
plt.legend()

plt.show()