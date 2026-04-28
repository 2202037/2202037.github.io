

def logic_AND(a, b):
    if a == 1 and b == 1:
        return 1
    else:
        return 0

def logic_OR(a, b):
    if a == 1 or b == 1:
        return 1
    else:
        return 0

def logic_NOT(a):
    if a == 1:
        return 0
    else:
        return 1

def logic_XOR(a, b):
    if a != b:
        return 1
    else:
        return 0

def logic_NAND(a, b):
    if a == 1 and b == 1:
        return 0
    else:
        return 1

def logic_NOR(a, b):
    if a == 0 and b == 0:
        return 1
    else:
        return 0




inputs_2_vars = [(0, 0), (0, 1), (1, 0), (1, 1)]
inputs_1_var = [0, 1]

print("=== LOGIC GATES TRUTH TABLES ===\n")

print("AND Gate:")
print("A | B | Output")
print("-" * 14)
for a, b in inputs_2_vars:
    print(f"{a} | {b} |   {logic_AND(a, b)}")
print()

print("OR Gate:")
print("A | B | Output")
print("-" * 14)
for a, b in inputs_2_vars:
    print(f"{a} | {b} |   {logic_OR(a, b)}")
print()

print("XOR Gate:")
print("A | B | Output")
print("-" * 14)
for a, b in inputs_2_vars:
    print(f"{a} | {b} |   {logic_XOR(a, b)}")
print()

print("NAND Gate:")
print("A | B | Output")
print("-" * 14)
for a, b in inputs_2_vars:
    print(f"{a} | {b} |   {logic_NAND(a, b)}")
print()

print("NOR Gate:")
print("A | B | Output")
print("-" * 14)
for a, b in inputs_2_vars:
    print(f"{a} | {b} |   {logic_NOR(a, b)}")
print()

print("NOT Gate:")
print("A | Output")
print("-" * 10)
for a in inputs_1_var:
    print(f"{a} |   {logic_NOT(a)}")
print()