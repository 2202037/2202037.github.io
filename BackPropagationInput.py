import math

# --- 1. Define the Activation Function ---
def sigmoid(x):
    return 1 / (1 + math.exp(-x))

def sigmoid_derivative(out):
    # The derivative of sigmoid is simply: output * (1 - output)
    return out * (1 - out)

# --- 2. Initialize the Given Values from the Diagram ---
# Inputs
i1 = 0.05
i2 = 0.10

# Target Outputs
t1 = 0.01
t2 = 0.99

# Initial Hidden Layer Weights
w1 = 0.15
w2 = 0.20
w3 = 0.25
w4 = 0.30

# Initial Output Layer Weights
w5 = 0.40
w6 = 0.45
w7 = 0.50
w8 = 0.55

# Biases
b1 = 0.35
b2 = 0.60

# Learning Rate (Standard default for this problem)
lr = 0.5

print("--- STARTING ONE PASS OF TRAINING ---\n")

# --- 3. FORWARD PROPAGATION ---
# Hidden Layer
net_h1 = (w1 * i1) + (w3 * i2) + b1
out_h1 = sigmoid(net_h1)

net_h2 = (w2 * i1) + (w4 * i2) + b1
out_h2 = sigmoid(net_h2)

# Output Layer
net_o1 = (w5 * out_h1) + (w7 * out_h2) + b2
out_o1 = sigmoid(net_o1)

net_o2 = (w6 * out_h1) + (w8 * out_h2) + b2
out_o2 = sigmoid(net_o2)

# Calculate Total Error (Mean Squared Error)
error_o1 = 0.5 * (t1 - out_o1) ** 2
error_o2 = 0.5 * (t2 - out_o2) ** 2
total_error = error_o1 + error_o2

print(f"Total Error after Forward Pass: {total_error:.6f}\n")

# --- 4. BACKWARD PROPAGATION (Output Layer) ---
# Calculate Output Node Deltas (Error gradient * Activation derivative)
delta_o1 = -(t1 - out_o1) * sigmoid_derivative(out_o1)
delta_o2 = -(t2 - out_o2) * sigmoid_derivative(out_o2)

# Store new output weights in temporary variables
# Formula: W_new = W_old - (LearningRate * Delta * SourceOutput)
new_w5 = w5 - (lr * delta_o1 * out_h1)
new_w6 = w6 - (lr * delta_o2 * out_h1)
new_w7 = w7 - (lr * delta_o1 * out_h2)
new_w8 = w8 - (lr * delta_o2 * out_h2)

# --- 5. BACKWARD PROPAGATION (Hidden Layer) ---
# Calculate Hidden Node Deltas
# Formula: (Sum of Output Deltas * Connected Weights) * Activation derivative
error_h1 = (delta_o1 * w5) + (delta_o2 * w6)
delta_h1 = error_h1 * sigmoid_derivative(out_h1)

error_h2 = (delta_o1 * w7) + (delta_o2 * w8)
delta_h2 = error_h2 * sigmoid_derivative(out_h2)

# Store new hidden weights in temporary variables
new_w1 = w1 - (lr * delta_h1 * i1)
new_w2 = w2 - (lr * delta_h2 * i1)
new_w3 = w3 - (lr * delta_h1 * i2)
new_w4 = w4 - (lr * delta_h2 * i2)

# --- 6. PRINT RESULTS ---
print("--- NEW ESTIMATED WEIGHTS ---")
print(f"w1: {new_w1:.6f}")
print(f"w2: {new_w2:.6f}")
print(f"w3: {new_w3:.6f}")
print(f"w4: {new_w4:.6f}")
print(f"w5: {new_w5:.6f}")
print(f"w6: {new_w6:.6f}")
print(f"w7: {new_w7:.6f}")
print(f"w8: {new_w8:.6f}")