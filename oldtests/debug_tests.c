#include "dbg.h"
#include <stdlib.h>
#include <stdio.h>

void test_debug()
{
  debug("test debug: I have brown hair");

  debug("test debug VA args: I am %d + %d = %d years old", 12, 16, 12 + 16);
}

void test_log_err()
{
  log_err("test log err");
  log_err("test log err va args: %d is the year, %d was last year", 2018, 2018-1);
}

void test_log_warn()
{
  log_err("test log warn");
  log_err("test log warn va args: %d is the year, %d was last year", 2018, 2018-1);
}

void test_log_info()
{
  log_err("test log info");
  log_err("test log info va args: %d is the year, %d was last year", 2018, 2018-1);
}

int test_check(char *file_name)
{
  FILE *input = NULL;
  char *block = NULL;
  block = malloc(100);
  check_mem(block);

  input = fopen(file_name, "r");
  check(input, "Failed to open %s.", file_name);

  free(block);
  fclose(input);
  return 0;

 error:
  if (block) free(block);
  if (input) fclose(input);
  return -1;
  
}

int test_sentinel(int code)
{
  char *temp = malloc(100);
  check_mem(temp);

  switch (code) {
  case 1:
    log_info("it worked.");
    break;
  default:
    sentinel("i shouldn't run");
    
  }
  free(temp);
  return 0;

 error:
  if (temp) free(temp);
  return -1;
}

int test_check_mem()
{
  char *test = NULL;
  check_mem(test);
  free(test);
  return 1;

 error:
  return -1;
}

int test_check_debug()
{
  int i = 0;
  check_debug(i != 0, "oops, i was 0");

  return 0;
 error:
  return -1;
}

int main(int argc, char *argv[])
{
  check(argc == 2, "Need an argument");

  test_debug();
  test_log_err();
  test_log_warn();
  test_log_info();

  check(test_check("README") == 0, "failed with README");
  check(test_check(argv[1]) == -1, "failed with argv");
  check(test_sentinel(1) == 0, "test_sentinel failed");
  check(test_sentinel(100) == -1, "test_sentinel failed");
  check(test_check_mem() == -1, "test_check_mem failed");
  check(test_check_debug() == -1, "test_check_debug failed");
  
  return 0;

 error:
  return 1;
}
