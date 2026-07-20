from math import factorial

# Initial values
x = 0
y = 1
h = 0.1
steps = 10

for i in range(steps):
    # Known derivatives
    y1 = x + y          # y'
    y2 = 1 + x + y      # y''
    y3 = 1 + x + y      # y''' (replace with actual expression)
    y4 = 1 + x + y      # y'''' (replace with actual expression)

    # Taylor Method (up to 4th order)
    y = (y
         + h * y1
         + (h**2 / factorial(2)) * y2
         + (h**3 / factorial(3)) * y3
         + (h**4 / factorial(4)) * y4)

    x += h

    print(f"Step {i+1}: x = {x:.2f}, y = {y:.6f}")