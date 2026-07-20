import matplotlib.pyplot as plt
import numpy as np
def f(x):
    return x**2-3
def bisection(x0,x1,e):
    

    print('\nBisection Method\n')
    step=1
    iterations=[]
    print("Iterations","\t","x0","\t","\t","\t","x1","\t","\t","\t","f(x0)","\t","\t","\t","f(x1)","\t","\t","\t","x2","\t","\t","\t","f(x2)")
    while True:
        x2=(x0+x1)/2

        print(step,"\t","\t","%0.6f"%x0,"\t","\t","%0.6f"%x1,"\t","\t","%0.6f"%f(x0),"\t","\t","%0.6f"%f(x1),"\t","\t","%0.6f"%x2,"\t","\t","%0.6f"%f(x2))
        iterations.append((x0,x1,x2))
        if abs(f(x2))<=e:
            break
        elif f(x0)*f(x2)<0:
            x1=x2
        else:
            x0=x2

    print("\nRequired Solution is:  ")
    return x2,iterations

#----------------Input---------#
x0=float(input("enter First guess:   "))
x1=float(input("Enter Second Guess:   "))
e=float(input("Enter tolerance:   "))

if f(x0)*f(x1)>0:
    print("Root is not brackated between this range")
    print("Please Enter another value")

else:
    root,iterations=bisection(x0,x1,e)

#----------------------Graph-------------------#
x=np.linspace(0,4,100)
plt.plot(x,f(x),label='f(x)')
plt.axhline(0,color='black',linewidth=0.7)
plt.scatter(root,f(root),color='red',label='root')
for a,b,c in iterations:
    plt.plot([a,b],[f(a),f(b)],'b--')

plt.xlabel('x')
plt.ylabel('f(x)')
plt.grid()
plt.legend()
plt.show()

