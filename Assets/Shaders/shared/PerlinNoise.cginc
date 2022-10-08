#include "./Random.cginc"
#include "./PerlinNoiseDebug.cginc"

// S shaped curve for fading values given t between 0 and 1
float fade(float t)
{
    return 6 * pow(t, 5) - 15 * pow(t, 4) + 10 * pow(t, 3);
}

// interpolates the two values given a weight
// uses the fade function to transform the weight
float interpolate(float a, float b, float w)
{
    return lerp(a, b, fade(w));
}

// projects the point p onto the segment (a,b)
float2 project(float2 p, float2 a, float2 b)
{
    float2 ab = b - a;
    float2 ap = p - a;

    float d = dot(ap, ab);
    float2 ax = ab * (d / length(ab));

    float2 x = a + ax;

    return x;
}

// calculates interpolation weight between two points a,b
// given a point x that belongs to the segment
float weight(float2 x, float2 a, float2 b)
{
    return length(x - a) / length(b - a);
}

// pseudo random gradients
float2 gradient(float x, float y)
{
    float index = floor(random(x, y) * 10) % 4;
    // float index = floor(random(x, y) * 10) % 4;

    float2 gradients[] = {
        float2(-1,1),
        float2(1,1),
        float2(1,-1),
        float2(-1,-1),
        // float2(0, sqrt(2)),
        // float2(sqrt(2), 0),
        // float2(0, -sqrt(2)),
        // float2(-sqrt(2), 0)
    };

    return gradients[index];
}

// perlin noise 0 to 1
// https://adrianb.io/2014/08/09/perlinnoise.html
fixed4 perlin(
    float2 pixel,
    int columns,
    int rows,
    bool debugSquares,
    bool debugGradients
)
{
    // square dimensions
    float width = 1 / float(columns);
    float height = 1 / float(rows);

    // current square
    int column = floor(pixel.x / width);
    int row = floor(pixel.y / height);

    // corners
    float2 a = float2(0,1);
    float2 b = float2(1,1);
    float2 c = float2(0,0);
    float2 d = float2(1,0);

    // square origin
    float2 o = float2(row * height, column * width);

    // gradients
    float2 gA = gradient(o.x, o.y + height);
    float2 gB = gradient(o.x + width, o.y + height);
    float2 gC = gradient(o.x, o.y);
    float2 gD = gradient(o.x + width, o.y);

    // translate point to local square coordinates
    float2 p = float2(
        (pixel.x % width) / width,
        (pixel.y % height) / height
    );

    // dot
    float2 ap = p - a;
    float dotA = dot(ap, gA);
    float2 bp = p - b;
    float dotB = dot(bp, gB);
    float2 cp = p - c;
    float dotC = dot(cp, gC);
    float2 dp = p - d;
    float dotD = dot(dp, gD);

    // interpolate
    float2 x1 = project(p, a, b);
    float w1 = weight(x1, a, b);
    float dot1 = interpolate(dotA, dotB, w1);

    float2 x2 = project(p, c, d);
    float w2 = weight(x2, c, d);
    float dot2 = interpolate(dotC, dotD, w2);

    float2 x3 = project(p, x1, x2);
    float w3 = weight(p, x1, x2);
    float dot3 = interpolate(dot1, dot2, w3); // from -1 to 1

    float noise = (dot3 * 0.5) + 0.5; // from 0 to 1
    fixed4 color = fixed4(1,1,1,1) * noise;

    // debug gradients
    if(debugGradients && isGradientDebugLine(p, a, b, c, d, gA, gB, gC, gD))
    {
        return fixed4(1,0,0,1);
    }

    // debug squares
    if(debugSquares && isSquareDebugLine(p))
    {
        return fixed4(0,0,1,1);
    }

    return color;
}
