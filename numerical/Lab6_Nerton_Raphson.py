import math
def f(x):
    return x*x*x-5*x-9
def g(x):
    return 3*x*x-5
def NewtonRapsonMethod(x0,e,N):
    print("\nNewton Rapson Method\n")
    step=1
    while True:
        x1=x0-f(x0)/g(x0)
        print("Iterations-%d,x0=%0.6f,x1=%0.6f,f(x1)=%0.6f"%(step,x0,x1,f(x1)))

        if abs(f(x1))<=e:
            break
        if step>=N:
            print("Not convergant")
            return
        x0=x1
    print("Required Solution is: %0.6f"%x1)

x0=float(input("Enter initial guess"))
e=float(input("Enter tolerance"))
N=int(input("Enter maximum iteration"))
NewtonRapsonMethod(x0,e,N)
