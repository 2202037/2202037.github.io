import numpy as np
A=np.array([
    [3,-0.1,-0.2],
    [0.1,7,-0.3],
    [0.3,-0.2,10]
],float)

B=np.array([7.85,-19.3,71.4],float)
t=len(B)
a=A[0][0]
b=A[0][1]
c=A[0][2]
d=A[1][0]
e=A[1][1]
f=A[1][2]
g=A[2][0]
h=A[2][1]
i=A[2][2]
D=a*(e*i-h*f)-b*(d*i-g*f)+c*(d*h-e*g)
x=[]
i=0
for i in range (t):
    Ai=A.copy()
    Ai[:,i]=B

    j=Ai[0][0]
    k=Ai[0][1]
    l=Ai[0][2]
    m=Ai[1][0]
    n=Ai[1][1]
    o=Ai[1][2]
    p=Ai[2][0]
    q=Ai[2][1]
    r=Ai[2][2]

    Di=j*(n*r-q*o)-k*(m*r-p*o)+l*(m*q-p*n)
    xi=Di/D
    x.append(xi)

    print(f"D{i+1}={Di:.6f}       X{i+1}={xi:6f}")

print("\nSo the required solution:\n")
for i in range(t):
    print(f"X{i+1}={x[i]:6f}") 