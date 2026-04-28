import itertools
import re

def analyze_logic(expr):
    print(f"Original Expression: {expr}")
    
    parsed_expr = expr.replace('<->', ' == ') 
    parsed_expr = parsed_expr.replace('->', ' <= ')  
    
    vars_list = sorted(list(set(re.findall(r'\b[a-z]\b', parsed_expr))))
    
    if not vars_list:
        print("No variables found in expression.")
        return

    combinations = list(itertools.product([True, False], repeat=len(vars_list)))
    
    header = " | ".join(vars_list) + " | Result"
    print("-" * len(header))
    print(header)
    print("-" * len(header))
    
    results = []
    
    for combo in combinations:
        env = dict(zip(vars_list, combo))
        
        try:
            result = eval(parsed_expr, {}, env)
            results.append(result)
            
            row_str = " | ".join(['T' if env[v] else 'F' for v in vars_list])
            res_str = 'T' if result else 'F'
            print(f"{row_str} |   {res_str}")
            
        except Exception as e:
            print(f"Error evaluating expression: {e}")
            return

    print("-" * len(header))
    
    if all(results):
        print("Conclusion: TAUTOLOGY (Always True)")
    elif not any(results):
        print("Conclusion: CONTRADICTION (Always False)")
    else:
        print("Conclusion: CONTINGENT (Mixed Results)")
    print("\n")

example_expression = "(p -> q) and (q -> r) -> (p -> r)"
analyze_logic(example_expression)