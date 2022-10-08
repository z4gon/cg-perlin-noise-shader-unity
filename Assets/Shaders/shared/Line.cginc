float onLine(float x, float y, float lineWidth)
{
    float halfLineWidth = lineWidth * 0.5;

    // returns 1 when (x,y) is in the line: x = y
    return step(
        x - halfLineWidth,
        y
    ) - step(
        x + halfLineWidth,
        y
    );
}
