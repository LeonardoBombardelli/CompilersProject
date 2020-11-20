int func()
{
    int x = 5;
    return(x);   
}

int func2()
{
    return(3 + 5 + 7 + 9);   
}


int main()
{
    return(func() + func2());
}