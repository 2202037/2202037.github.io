import math
def f(x):
    return x*x*x+x*x-1
def g(x):
    return 1/math.sqrt(x+1)

def fixedpointiterative(x0,e,N):
    print("\nFixedpointiterative Method\n")

    step=1
    while True:
        x1=g(x0)
        print("iteration-%d, x0=%0.6f,x1=%0.6f,f(x1)=%0.6f"%(step,x0,x1,f(x1)))
        if abs(f(x1))<=e:
            break
        if step>=N:
            print("The solution is not convergant")
            return
        x0=x1
        step+=1
    print("\n The required Solution is: %0.6f",x1)
x0=float(input("Enter initial guess"))
e=float(input("Maximum tolerance"))
N=int(input("Maximum iteration"))
fixedpointiterative(x0,e,N)