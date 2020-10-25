// map::find
#include <iostream>
#include <map>

int main ()
{
  std::map<char,int> mymap;
  std::map<char,int>::iterator it;

  mymap['a']=50;
  mymap['b']=100;
  mymap['c']=150;
  mymap['d']=200;

  it = mymap.find('e');
  if(it == mymap.end())
      std::cout << "E not in map";

  it = mymap.find('a');
  if(it == mymap.end())
      std::cout << "A not in map";

  return 0;
}