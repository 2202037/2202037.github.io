import random
import math

# ---------------- optional reproducibility ----------------
# comment this out if you want different results each run
random.seed(None)

# ---------------- activation functions ----------------
def relu(x):
    return [max(0, i) for i in x]

def relu_deriv(x):
    return [1 if i > 0 else 0 for i in x]

def softmax(x):
    exps = [math.exp(i - max(x)) for i in x]
    s = sum(exps)
    return [i / s for i in exps]

def loss_fn(p, y):
    return -math.log(p[y] + 1e-9)


# ---------------- dataset ----------------
def gen_data(n=100, f=10):
    X, Y = [], []
    for _ in range(n):
        x = [random.uniform(-1, 1) for _ in range(f)]
        y = 1 if sum(x) > 0 else 0
        X.append(x)
        Y.append(y)
    return X, Y

X, Y = gen_data()

# ---------------- shuffle helper ----------------
def shuffle_data(X, Y):
    combined = list(zip(X, Y))
    random.shuffle(combined)
    X, Y = zip(*combined)
    return list(X), list(Y)

# ---------------- weight init (better than uniform) ----------------
def rand_mat(r, c):
    return [[random.gauss(0, 0.1) for _ in range(c)] for _ in range(r)]

W1 = rand_mat(10, 5)
W2 = rand_mat(5, 2)

lr = 0.01
epochs = 100

# ---------------- training ----------------
for epoch in range(epochs):

    # shuffle every epoch (IMPORTANT)
    X, Y = shuffle_data(X, Y)

    total_loss = 0
    correct = 0

    for x, y in zip(X, Y):

        # ---------- forward ----------
        h = [sum(x[i] * W1[i][j] for i in range(10)) for j in range(5)]
        h_relu = relu(h)

        o = [sum(h_relu[i] * W2[i][j] for i in range(5)) for j in range(2)]
        p = softmax(o)

        loss = loss_fn(p, y)
        total_loss += loss

        pred = p.index(max(p))
        if pred == y:
            correct += 1

        # ---------- backward ----------
        grad_o = p[:]
        grad_o[y] -= 1

        # update W2
        for i in range(5):
            for j in range(2):
                W2[i][j] -= lr * grad_o[j] * h_relu[i]

        # backprop hidden
        grad_h = [0] * 5
        for i in range(5):
            for j in range(2):
                grad_h[i] += grad_o[j] * W2[i][j]

        grad_h = [grad_h[i] * relu_deriv(h)[i] for i in range(5)]

        # update W1
        for i in range(10):
            for j in range(5):
                W1[i][j] -= lr * grad_h[j] * x[i]

    # ---------------- output ----------------
    if (epoch + 1) % 10 == 0:
        avg_loss = total_loss / len(X)
        acc = (correct / len(X)) * 100

        print(
            f"Epoch {epoch+1}/{epochs} "
            f"- Loss: {avg_loss:.4f} "
            f"- Accuracy: {acc:.2f}%"
        )

print("\nTraining complete.")