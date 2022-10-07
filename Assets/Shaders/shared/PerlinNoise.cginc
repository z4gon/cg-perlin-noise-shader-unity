#include "./Random.cginc"

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

// perlin noise
// https://adrianb.io/2014/08/09/perlinnoise.html
float perlin(
    float2 p,
    float2 gradientA,
    float2 gradientB,
    float2 gradientC,
    float2 gradientD
)
{
    // corners
    float2 a = float2(0,1);
    float2 b = float2(1,1);
    float2 c = float2(0,0);
    float2 d = float2(1,0);

    // dot
    float2 ap = p - a;
    float dotA = dot(ap, gradientA);
    float2 bp = p - b;
    float dotB = dot(bp, gradientB);
    float2 cp = p - c;
    float dotC = dot(cp, gradientC);
    float2 dp = p - d;
    float dotD = dot(dp, gradientD);

    // interpolate
    float2 x1 = project(p, a, b);
    float w1 = weight(x1, a, b);
    float dot1 = interpolate(dotA, dotB, w1);

    float2 x2 = project(p, c, d);
    float w2 = weight(x2, c, d);
    float dot2 = interpolate(dotC, dotD, w2);

    float2 x3 = project(p, x1, x2);
    float w3 = weight(x3, x1, x2);
    float dot3 = interpolate(dot1, dot2, w3); // from -1 to 1

    return (dot3 * 0.5) + 0.5; // from 0 to 1
}
