#include<bits/stdc++.h>
using namespace std;
#pragma GCC optimize("unroll-loops")
#pragma GCC optimize("O3,unroll-loops")
#pragma GCC target("avx2,bmi,bmi2,lzcnt,popcnt")
#include <ext/pb_ds/assoc_container.hpp>
#include<ext/pb_ds/tree_policy.hpp>
using namespace __gnu_pbds;
template < typename T>
using ordered_set = tree<T, null_type, less<T>, rb_tree_tag, tree_order_statistics_node_update>;
#define int long long
#define ull unsigned long long
#define MOD 1000000007
#define MOD1 998244353
#define PI 3.141592653589793238462
#define set_bits __builtin_popcountll
#define INF 1e18
#define endl "\n"
#define ff first
#define ss second
typedef long double lld;
#define optimize() ios_base ::sync_with_stdio(false); cin.tie(0); cout.tie(0);
void InputOutput()
{
#ifndef ONLINE_JUDGE
    freopen("E:/Programming File/input.txt", "r", stdin);
    freopen("E:/Programming File/output.txt", "w", stdout);
#endif
}
#define db(x) cerr << #x <<" "; _print(x); cerr << endl;
void _print(int t) {cerr << t;}
void _print(string t) {cerr << t;}
void _print(char t) {cerr << t;}
void _print(lld t) {cerr << t;}
void _print(double t) {cerr << t;}
void _print(ull t) {cerr << t;}
template <class T, class V> void _print(pair <T, V> p);
template <class T> void _print(vector <T> v);
template <class T> void _print(set <T> v);
template <class T, class V> void _print(map <T, V> v);
template <class T> void _print(multiset <T> v);
template <class T, class V> void _print(pair <T, V> p) {cerr <<" "; _print(p.ff); cerr << " "; _print(p.ss); cerr << "\n";}
template <class T> void _print(vector <T> v) {cerr << " \n "; for (T i : v) {_print(i); cerr << " ";} cerr << "";}
template <class T> void _print(set <T> v) {cerr << "\n"; for (T i : v) {cerr <<" "; _print(i); cerr << " \n";} cerr << " ";}
template <class T> void _print(multiset <T> v) {cerr << "\n"; for (T i : v) {cerr <<" "; _print(i); cerr << " \n";} cerr << " ";}
template <class T, class V> void _print(map <T, V> v) {cerr << " \n"; for (auto i : v) {_print(i); cerr << "";} cerr << "";}


void solve(){
    
        int x;cin>>x;
        map<int,int>m;

        int cnt=0;

        for(int n=2;n<=x;n++){
            int vl=cnt;

            cout<<"b :  "<<n<<endl;
            cout<<"......"<<endl;

        for(int i=1;i<n;i++){
            if((n*i)%(n-i)==0 ){
                cout<<"a  "<<i<<endl;

                cout<<"k  :   "<<(n*i)/(n-i)<<endl;
                
                cnt++;
            }
        }

        cout<<"cnt :"<<cnt-vl<<endl;
        cout<<endl;
        cout<<"!!!!!"<<endl;
    }

    cout<<cnt<<endl;

    for(auto it:m){
        cout<<it.first<<' '<<it.second<<endl;
    }
 
}

signed main() {
    optimize();

    int t;cin>>t;while(t--){

        solve();
        
    }

    return 0;

}