#include <stdio.h>
#include <stdlib.h>

#ifdef WIN32
#  ifdef _MSC_VER
#    define popen _popen
#    define pclose _pclose
#  else /*_MSC_VER*/
#    include <unistd.h>				// non-MS win32 compilers (untested)
#  endif /*_MSC_VER*/
#else
#  include <unistd.h>
#endif

FILE* popenShim(const char* command, const char* mode);
int filenoShim(FILE* fd);
int pcloseShim(FILE* fd);
