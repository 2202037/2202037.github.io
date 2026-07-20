from numpy import array,zeros

a=array([
    [4,3,-5],
    [-2,-4,5],
    [8,8,0]
],float)
b=array([2,5,-3],float)
n=len(b)
x=zeros(n,float)


for k in range(n-1):
    for i in range(k+1,n):
        if a[i,k]==0:
            continue
        factor=a[i,k]/a[k,k]
        for j in range(k,n):
            a[i,j]=a[i,j]-factor*a[k,j]
        b[i]=b[i]-factor*b[k]

print("\nMOdified  matrix A: \t")
print(a)

print("\nMOdified  matrix B: \t")
print(b)

x[n-1]=b[n-1]/a[n-1,n-1]

for i in range(n-2,-1,-1):
    sum_ax=0
    for j in range(i+1,n):
        sum_ax=sum_ax+a[i,j]*x[j]

    x[i]=(b[i]-sum_ax)/a[i,i]


print("\nRequired_Solution\n:")
print(x)

