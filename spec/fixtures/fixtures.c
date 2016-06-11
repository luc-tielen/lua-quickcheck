
#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>
#include <string.h>


/**
 * Adds 2 bytes together and returns the result.
 */
uint8_t add(uint8_t a, uint8_t b)
{
    return a + b;
}

/**
 * Adds 2 doubles together and returns the result.
 */
double dbl_add(double a, double b)
{
  return a + b;
}

/**
 * Adds 2 floats together and returns the result.'
 */
float flt_add(float a, float b)
{
  return a + b;
}

/**
 * Adds 2 64 bit integers together and returns the result.
 */
uint64_t u64_add(uint64_t a, uint64_t b)
{
  return a + b;
}

/**
 * Checks if the number is less than zero.
 * return: true = x less than zero; false = x greater or equal than zero.
 */
bool less_than_zero(int x)
{
    return x < 0;
}

/**
 * Inverts a number x (in binary) and returns the result.
 */
uint64_t u64_invert(uint64_t x)
{
  return x ^ 0xFFFFFFFFFFFFFFFFULL;
}

/*
 * Struct representing a 2D point.
 */
struct point
{
    uint32_t x;
    uint32_t y;
};

/**
 * Adds 2 points a and b and stores the result in c_out.
 * a, b and c_out must point to a pre-allocated part of memory.
 * Returns true if add operation was successful, false otherwise.
 */
bool point_add(struct point* a, struct point* b, struct point* c_out)
{
    if (!a || !b || !c_out) { return false; }
    c_out->x = a->x + b->x; 
    c_out->y = a->y + b->y;
    return true;
}

/**
 * Adds 2 NULL-terminated strings together.
 * returns a new string (which has to be freed afterwards!)
 * returns NULL if a or b are NULL
 */
const char* str_add(const char* const a, const char* const b)
{
  if (!a || !b) { return NULL; }
  
  size_t len_a = strlen(a);
  size_t len_b = strlen(b);
  char* result = (char*) malloc(sizeof(char) * (len_a + len_b + 1));
  
  if (!result) { return NULL; }

  memcpy(result, a, len_a);
  memcpy(result + len_a, b, len_b + 1);
  return result;
}


