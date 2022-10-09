#include "./Random.cginc"
// Upgrade NOTE: excluded shader from DX11, OpenGL ES 2.0 because it uses unsized arrays
#pragma exclude_renderers d3d11 gles
#include "./PerlinNoiseDebug.cginc"

// S shaped curve for fading values given t between 0 and 1
float fade(float t)
{
    return (6 * pow(t, 5)) - (15 * pow(t, 4)) + (10 * pow(t, 3));
}

// interpolates the two values given a weight
// uses the fade function to transform the weight
float interpolate(float a, float b, float w)
{
    return lerp(a, b, w);
}

// pseudo random gradients
float2 gradient(int seed)
{
    int m = seed & 4;

    if(m == 0){
        return float2(1.0,1.0);
    } else if(m == 1){
        return float2(-1.0,1.0);
    } else if(m == 2){
        return float2(-1.0,-1.0);
    } else {
        return float2(1.0,-1.0);
    }
}


// perlin noise 0 to 1
// https://adrianb.io/2014/08/09/perlinnoise.html
fixed4 perlin(
    float2 uv,
    int columns,
    int rows,
    bool debugSquares,
    bool debugGradients
)
{
    // square dimensions
    float squareWidth = 1 / float(columns);
    float squareHeight = 1 / float(rows);

    // current square
    int column = floor(uv.x / squareWidth);
    int row = floor(uv.y / squareHeight);

    // corners
    float2 topLeft = float2(0.0,1.0);
    float2 topRight = float2(1.0,1.0);
    float2 bottomLeft = float2(0.0,0.0);
    float2 bottomRight = float2(1.0,0.0);

    // get index for the lookup table
    int X = column % 8;
    int Y = row % 8;

    int P[16] = {0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7};

    // return fixed4(T[X]/1000.0, T[Y]/1000.0, 0,1);

    // gradients
    float2 gradientTopLeft = gradient(P[P[X] + Y+1]);
    float2 gradientTopRight = gradient(P[P[X+1] + Y+1]);
    float2 gradientBottomLeft = gradient(P[P[X] + Y]);
    float2 gradientBottomRight = gradient(P[P[X+1] + Y]);

    // translate point to local square coordinates
    float2 localPoint = float2(
        (uv.x % squareWidth) / squareWidth,
        (uv.y % squareHeight) / squareHeight
    );

    // distances
    float2 distanceTopLeft = localPoint - topLeft;
    float2 distanceTopRight = localPoint - topRight;
    float2 distanceBottomLeft = localPoint - bottomLeft;
    float2 distanceBottomRight = localPoint - bottomRight;

    // dot
    float dotTopLeft = dot(distanceTopLeft, gradientTopLeft);
    float dotTopRight = dot(distanceTopRight, gradientTopRight);
    float dotBottomLeft = dot(distanceBottomLeft, gradientBottomLeft);
    float dotBottomRight = dot(distanceBottomRight, gradientBottomRight);

    // interpolate
    float interpolatedDot = interpolate(
        interpolate(dotTopLeft, dotTopRight, localPoint.x),
        interpolate(dotBottomLeft, dotBottomRight, localPoint.x),
        localPoint.y
    );

    float noise = (interpolatedDot * 0.5) + 0.5; // from 0 to 1
    fixed4 color = fixed4(1,1,1,1) * noise;

    // debug gradients
    if(debugGradients && isGradientDebugLine(localPoint, topLeft, topRight, bottomLeft, bottomRight, gradientTopLeft, gradientTopRight, gradientBottomLeft, gradientBottomRight))
    {
        return fixed4(1,0,0,1);
    }

    // debug squares
    if(debugSquares && isSquareDebugLine(localPoint))
    {
        return fixed4(0,0,1,1);
    }

    return color;
}
