Shader "Unlit/29_PerlinNoise_Shader_Unlit"
{
    Properties
    {
        _TilingColumns("Tiling Columns", Float) = 10
        _TilingRows("Tiling Rows", Float) = 10
        [Toggle] _DebugSquares("Debug Squares", Float) = 0
        [Toggle] _DebugGradients("Debug Gradients", Float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "./shared/SimpleV2F.cginc"
            #include "./shared/PerlinNoise.cginc"

            int _TilingColumns;
            int _TilingRows;
            bool _DebugSquares;
            bool _DebugGradients;

            fixed4 frag (v2f i) : SV_Target
            {
                float2 p = i.uv;

                fixed4 color = fixed4(1,1,1,1);
                fixed4 noise = perlin(p, _TilingColumns, _TilingRows, _DebugSquares, _DebugGradients);

                return color * noise;
            }
            ENDCG
        }
    }
}
