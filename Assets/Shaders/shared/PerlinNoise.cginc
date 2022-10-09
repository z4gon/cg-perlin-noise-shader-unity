#include "./Random.cginc"
// Upgrade NOTE: excluded shader from DX11, OpenGL ES 2.0 because it uses unsized arrays
#pragma exclude_renderers d3d11 gles
#include "./PerlinNoiseDebug.cginc"

// Hash lookup table as defined by Ken Perlin.
// This is a randomly arranged array of all numbers from 0-255 inclusive.
// Duplicated to avoid out of bounds.
static const int P[512] = {
    151,160,137,91,90,15,
    131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,
    190, 6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,
    88,237,149,56,87,174,20,125,136,171,168, 68,175,74,165,71,134,139,48,27,166,
    77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,
    102,143,54, 65,25,63,161, 1,216,80,73,209,76,132,187,208, 89,18,169,200,196,
    135,130,116,188,159,86,164,100,109,198,173,186, 3,64,52,217,226,250,124,123,
    5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,
    223,183,170,213,119,248,152, 2,44,154,163, 70,221,153,101,155,167, 43,172,9,
    129,22,39,253, 19,98,108,110,79,113,224,232,178,185, 112,104,218,246,97,228,
    251,34,242,193,238,210,144,12,191,179,162,241, 81,51,145,235,249,14,239,107,
    49,192,214, 31,181,199,106,157,184, 84,204,176,115,121,50,45,127, 4,150,254,
    138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180,

    151,160,137,91,90,15,
    131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,
    190, 6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,
    88,237,149,56,87,174,20,125,136,171,168, 68,175,74,165,71,134,139,48,27,166,
    77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,
    102,143,54, 65,25,63,161, 1,216,80,73,209,76,132,187,208, 89,18,169,200,196,
    135,130,116,188,159,86,164,100,109,198,173,186, 3,64,52,217,226,250,124,123,
    5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,
    223,183,170,213,119,248,152, 2,44,154,163, 70,221,153,101,155,167, 43,172,9,
    129,22,39,253, 19,98,108,110,79,113,224,232,178,185, 112,104,218,246,97,228,
    251,34,242,193,238,210,144,12,191,179,162,241, 81,51,145,235,249,14,239,107,
    49,192,214, 31,181,199,106,157,184, 84,204,176,115,121,50,45,127, 4,150,254,
    138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180
};

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
    int X = column % 256;
    int Y = row % 256;

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
    if(
        debugGradients &&
        isGradientDebugLine(
            localPoint,
            topLeft,
            topRight,
            bottomLeft,
            bottomRight,
            gradientTopLeft,
            gradientTopRight,
            gradientBottomLeft,
            gradientBottomRight
        )
    )
    { return fixed4(1,0,0,1); }

    // debug squares
    if(debugSquares && isSquareDebugLine(localPoint)) { return fixed4(0,0,1,1); }

    return color;
}
