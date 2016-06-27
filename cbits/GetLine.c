#include "GetLine.H"

char* getLineShim(FILE* fd){
  char* s = malloc(1024 * sizeof(char));
  if (fgets(s, 1023, fd) == NULL)
    return NULL;
  return s;
}
