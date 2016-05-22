
#include <stdint.h>
#include <stdbool.h>

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

