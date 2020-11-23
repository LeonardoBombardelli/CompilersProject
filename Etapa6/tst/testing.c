int foo()
{
  return 4;
}

int main()
{
  int a;
  int b;
  b = 4;
  a = 5+12*b;

  if (a == 53 || (1 == 2 && a < 4))
  {
    a = 90;
  };

  a = a + 1;

  // for (a = 0 : a < 10 : a = a+1)
  // {
  //   b = a;
  // };

  // a = foo();

  return a;
}