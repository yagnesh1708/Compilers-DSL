#include <bits/stdc++.h>

using namespace std;

struct symbol_table_entry
{
    string id;
    string type;
    int dim;
    int size;
    int size2;
    int scope;
};

typedef struct symbol_table_entry smt;

vector<smt> table;

vector<smt> gtable;

struct fsymbol_table_entry
{
    string id;
    string rtype;
    int narg;
    vector<string> argtypes;
};
typedef struct fsymbol_table_entry fst;

vector<fst> ftable;

vector<string> args;

string func_type;

void set1(string type){
    func_type = type;
    }

int nofarg = 0;

void add_func(string type, string id)
{
    fst temp;
    temp.id = id;
    temp.rtype = func_type;
    temp.narg = nofarg;
    temp.argtypes = args;
    ftable.push_back(temp);
    args.clear();
    nofarg = 0;
}

string get_ret(string var)
{
    for (auto i : ftable)
    {
        if (i.id == var)
        {
            return i.rtype;
        }
    }
}

void addarg(string type)
{
    args.push_back(type);
    nofarg += 1;
}
vector<string> d_types;

void foo(string s)
{
    cout << s << endl;
}
void init()
{
    d_types.push_back("int");
    d_types.push_back("char");
    d_types.push_back("float");
    d_types.push_back("double");
    d_types.push_back("string");
    d_types.push_back("bool");
    d_types.push_back("ifstream");
    d_types.push_back("ofstream");
}

void add_type(string s)
{
    d_types.push_back(s);
}

bool check_dtype(string s)
{
    for (auto i : d_types)
    {
        if (i == s)
            return 1;
    }
    return 0;
}
bool check(string var, int s)
{
    for (auto i : table)
    {
        if (i.id == var && i.scope == s)
            return false;
    }
    return true;
}
bool check_func(string var)
{
    for (auto i : ftable)
    {
        if (i.id == var)
            return false;
    }
    return true;
}

smt get_entry(string var)
{
    for (int i = 0; i < table.size(); i++)
    {
        if (table[i].id == var)
            return table[i];
    }
}

fst get_entryfunc(string var)
{
    for (int i = 0; i < ftable.size(); i++)
    {
        if (ftable[i].id == var)
            return ftable[i];
    }
}

string get_id(string var)
{
    return get_entry(var).id;
}

int get_dim(string var)
{
    return get_entry(var).dim;
}

int get_size(string var)
{
    return get_entry(var).size;
}

int get_size2(string var)
{
    return get_entry(var).size2;
}

char *get_type(string var)
{
    string temp = get_entry(var).type;
    char *s;
    int n = temp.length();
    s = (char *)malloc(sizeof(char) * (n+1));
    for (int i = 0; i <= n; i++)
    {
        if(i==n)
        {
            s[i] = 0;
            break;
        }
        s[i] = temp[i];
    }
    return s;
}

char *get_typefunc(string var)
{
    string temp = get_entryfunc(var).rtype;
    char *s;
    int n = temp.length();
    s = (char *)malloc(sizeof(char) * (n+1));
    for (int i = 0; i < n; i++)
        {
        if(i==n)
        {
            s[i] = 0;
            break;
        }
        s[i] = temp[i];
    }
    return s;
}

void insert(string var, string type, int dim, string sz, int scope)
{
    int b = 0;

    for (auto i : d_types)
    {
        if (i == type)
        {
            b = 1;
            break;
        }
    }

    if (!b)
    {
        cout << "Data type " << type << " is not declared\n";
    }
    smt temp;
    temp.type = type;
    temp.id = var;
    temp.dim = dim;
    temp.scope = scope;
    temp.size = 1;
    if (dim == 1)
    {
        // temp.type = type + "*";
        if (sz[0] >= '0' && sz[0] <= '9')
            temp.size = stoi(sz);
        else
            temp.size = -1;
    }
    if (dim == 2)
    {
        // temp.type = type + "**";
        string m, n;
        int i;
        for (i = 0; i < sz.length(); i++)
        {
            if (sz[i] == ',')
                break;
        }
        m = sz.substr(0, i);
        n = sz.substr(i + 1, sz.length() - i);
        if (m[0] >= '0' && m[0] <= '9')
            temp.size = stoi(m);
        else
            temp.size = -1;
        if (n[0] >= '0' && n[0] <= '9')
            temp.size2 = stoi(n);
        else
            temp.size2 = -1;
    }

    table.push_back(temp);
}

void print_table()
{
    for (int i = 0; i < table.size(); i++)
    {
        cout << "ID : " << table[i].id << " Data Type : " << table[i].type << "size : " << table[i].size <<" " <<table[i].dim <<endl;
    }
}

void print_ftable()
{
    cout << "Function table " << endl;
    for (int i = 0; i < ftable.size(); i++)
    {
        cout << "ID : " << ftable[i].id << " Return Type : " << ftable[i].rtype << endl;
        for (int j = 0; j < ftable[i].argtypes.size(); j++)
        {
            cout << "type " << j << " is " << ftable[i].argtypes[j] << endl;
        }
    }
}

string init_type;

void type_init(string data)
{
    init_type = data;
}

string ret()
{
    return init_type;
}

vector<string> params;

void append(string type)
{
    string temp;
    temp = type;
    // cout << type << endl;
    params.push_back(temp);
}

bool checks(vector<string> args)
{
    vector<string> temp;
    temp = params;
    params.clear();
    // cout << args.size() << " " << temp.size();
    if (args.size() != temp.size())
        return 0;
    for (int i = 0; i < args.size(); i++)
    {
        if(args[i] != temp[i]){
            // cout << args[i] << " " << temp[i];
            return false;
        }
        // cout << args[i] << " " << temp[i] << endl;
    }
    return true;
}

bool func_seman(string var)
{
    for (auto i : ftable)
    {
        if (i.id == var)
        {
            if (checks(i.argtypes))
                return true;
            else
                return false;
        }
    }
}

int outofbounds(char *x,int sz){
    int s = atoi(x);
    if(s >= sz || s < 0) return 1;
    return 0;
}

void delete_scope(int scope)
{
    vector<smt> temp;
    for(int i=0;i<table.size();i++)
    {
        if(table[i].scope < scope) temp.push_back(table[i]);
    }
    table = temp;
}

void dimx(string var){
    for(auto i : table){
        if(i.id == var){
            i.dim = -1;
            return;
        }
        print_table();
    }
}