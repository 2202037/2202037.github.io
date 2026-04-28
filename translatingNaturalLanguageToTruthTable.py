import itertools

def print_truth_table(statement, vars_list, logic_func):
    """Helper function to cleanly print truth tables for specific logic functions."""
    print(f"{statement}")
    header = " | ".join(vars_list) + " | Result"
    print("-" * len(header))
    print(header)
    print("-" * len(header))
    
    # Generate True/False combinations based on number of variables
    combinations = list(itertools.product([True, False], repeat=len(vars_list)))
    
    for combo in combinations:
        # Pass the combination directly into our lambda logic functions
        result = logic_func(*combo)
        
        row_str = " | ".join(['T' if val else 'F' for val in combo])
        res_str = 'T' if result else 'F'
        print(f"{row_str} |   {res_str}")
        
    print("-" * len(header) + "\n")


# -----------------------------------------------------------------
# 2. Code the following propositions using PL with Python
# -----------------------------------------------------------------

# a. It is raining outside if and only if it is a cloudy day.
# Logical Form: p <-> q  (Biconditional)
print_truth_table(
    "a. It is raining (p) iff it is cloudy (q) [p <-> q]", 
    ['p', 'q'], 
    lambda p, q: p == q
)

# b. If you get a 100 on the final exam, then you earn an A in the class.
# Logical Form: p -> q (Implication)
print_truth_table(
    "b. If 100 on final (p), then earn an A (q) [p -> q]", 
    ['p', 'q'], 
    lambda p, q: p <= q
)

# c. Take either 2 Advil or 3 Tylenol.
# Logical Form: p v q (Logical OR)
# Note: Natural language "either...or" can sometimes mean XOR (Exclusive OR, meaning you shouldn't take both). 
# However, standard Propositional Logic assumes Inclusive OR unless explicitly stated.
print_truth_table(
    "c. Take 2 Advil (p) or 3 Tylenol (q) [p v q]", 
    ['p', 'q'], 
    lambda p, q: p or q
)

# d. She studied hard or she is extremely bright.
# Logical Form: p v q (Logical OR)
print_truth_table(
    "d. Studied hard (p) or extremely bright (q) [p v q]", 
    ['p', 'q'], 
    lambda p, q: p or q
)

# e. I am a rock and I am an island.
# Logical Form: p ^ q (Logical AND)
print_truth_table(
    "e. I am a rock (p) and an island (q) [p ^ q]", 
    ['p', 'q'], 
    lambda p, q: p and q
)