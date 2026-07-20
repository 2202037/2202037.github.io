# Lagrange Interpolation

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

# Value at which interpolation is needed
xp = float(input("Enter the value of x to interpolate: "))

# Lagrange Interpolation
yp = 0

for i in range(n):
    term = y[i]

    for j in range(n):
        if i != j:
            term *= (xp - x[j]) / (x[i] - x[j])

    yp += term

print(f"\nInterpolated value at x = {xp} is {yp:.6f}")