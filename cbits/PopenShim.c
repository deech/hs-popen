#include "PopenShim.H"
#include <stdlib.h>

FILE* popenShim(const char* command, const char* mode) {
  FILE* fd = NULL;
  if ( ( fd = popen(command, mode) ) == NULL ) {	// start the external unix command
    perror("popen failed");
  }
  return fd;
}

int filenoShim(FILE* fd) {
  return fileno(fd);
}

int pcloseShim(FILE* fd) {
  return pclose(fd);
}
