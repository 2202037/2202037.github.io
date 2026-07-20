import matplotlib.pyplot as plt
import numpy as np

def f(x):
    return (x**2)-3
def falseposition(x0,x1,e):
    print("\n FALSE POSITION METHOD\n")
    step=1
    iterations=[]
    print("\nIterations","\t" ,"x0","\t","\t","\t","x1","\t","\t","\t","f(x0)","\t","\t","\t","f(x1)","\t","\t","\t","x2","\t","\t","\t","f(x2)")
    while True:
        x2=x2 = x1 - ((x0-x1)*f(x1))/(f(x0)-f(x1))

    
        print(step, "\t","\t","%0.6f"% x0, "\t","\t", "%0.6f"%x1, "\t","\t", "%0.6f"%f(x0), "\t","\t", "%0.6f"%f(x1), "\t","\t", "%0.6f"%x2, "\t","\t","%0.6f"% f(x2))
        iterations.append((x0,x1,x2))

        if abs(f(x2))<=e:
            break
        if f(x0)*f(x2)<0:
            x1=x2
        else:
            x0=x2

        step+=1

    print("\n Required solution : %0.8f" % x2)
    return x2,iterations

#------------input Section----------#
x0=float(input("\nEnter First Guess:  "))
x1=float(input("\nEnter Second Guess:  "))
e=float(input("\nEnter Tolerance :  "))

if f(x0)*f(x1)>0:
    print("\n The root Is not brackated in this Range ")
    print("\n Please try with another value")

else:
    root,iterations=falseposition(x0,x1,e)

#------------------------------Graph------------------------#

x=np.linspace(0,4,100)
plt.plot(x,f(x),label='f(x)')
plt.axhline(0,color='black',linewidth=0.7)
plt.scatter(root,f(root),color='red',label='root')

plt.xlabel('x')
plt.ylabel('f(x)')
for a,b,c in iterations:
    plt.plot([a,b],[f(a),f(b)],'b--')

plt.title("Falseposition")
plt.grid()
plt.legend()
plt.show()