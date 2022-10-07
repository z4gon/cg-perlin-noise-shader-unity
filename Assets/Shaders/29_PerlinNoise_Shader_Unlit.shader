Shader "Unlit/29_PerlinNoise_Shader_Unlit"
{
    Properties
    {
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

            fixed4 frag (v2f i) : SV_Target
            {
                float2 p = i.uv;

                float perlinNoise = perlin(
                    p,
                    float2(0,1),
                    float2(0,1),
                    float2(-1,1),
                    float2(1,-1)
                );

                return fixed4(fixed3(1,1,1),1) * perlinNoise;
            }
            ENDCG
        }
    }
}
