/**
 * Return the smallest argument.
 */
min(a, b)
{
    return a < b ? a : b
}

/**
 * Return the largest argument.
 */
max(a, b)
{
    return a > b ? a : b
}

/**
 * Convert distance into direction.
 *
 * @param {Int} distance
 * @return {Str} direction
 */
getDirection(distance)
{
    return distance > 0 ? "right" : "left"
}
