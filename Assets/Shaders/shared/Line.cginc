float onLine(float x, float y, float lineWidth, float2 origin)
{
    float halfLineWidth = lineWidth * 0.5;

    // returns 1 when (x,y) is in the line: x = y
    return step(
        x - halfLineWidth - origin.x,
        y - origin.y
    ) - step(
        x + halfLineWidth - origin.x,
        y - origin.y
    );
}
