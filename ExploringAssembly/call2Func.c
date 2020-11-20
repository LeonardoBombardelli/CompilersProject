int func()
{
    int x = 5;
    return(x);   
}

int func2()
{
    int x = 7;
    return(x);   
}


int main()
{
    return(func() + func2());
}