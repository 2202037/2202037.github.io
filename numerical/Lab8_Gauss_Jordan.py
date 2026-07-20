from numpy import zeros
n=int(input("Enter the number of unknowns:"))

a=zeros((n,n),float)
b=zeros(n,float)
x=zeros(n,float)

print("\nEnter elements for coefficient matrix A\n:")
for i in range (n):
    for j in range(n):
        a[i,j]=float(input(f"A[{i+1}][{j+1}]"))

print("Enter the elements of Constant Matrix B:")
for i in range (n):
    b[i]=float(input(f"B[{i}]="))

for k in range(n):
    if a[k,k]==0:
        print("\nDevided by zero detected:\n")
        break
    for i in range (n):
        if i==k:
            continue
        factor=a[i,k]/a[k,k]
        for j in range(n):
            a[i,j]=a[i,j]-factor*a[k,j]
        
        b[i]=b[i]-factor*b[k]
for i in range (n):
    x[i]=b[i]/a[i,i]

print("\nTHe Modified co Efficient matrix A\n")
print(a)
print("\nTHe Modified constant matrix B\n")
print(b)
print("\nRequired solution\n")
for i in range (n):
    print(f"X{i+1} = {x[i]:.6f}")