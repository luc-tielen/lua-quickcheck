
#include <stdint.h>
#include <stdbool.h>

/**
 * Adds 2 numbers together and returns the result.
 */
uint8_t add(uint8_t a, uint8_t b)
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

