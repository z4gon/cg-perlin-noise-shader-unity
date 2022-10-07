Shader "Unlit/27_Noise_Shader_Unlit"
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

            #define PI 3.14159265359
            #define PI2 6.28318530718

            float random(float2 pixel, float seed)
            {
                // magical hardcoded randomness

                const float a = 12.9898;
                const float b = 78.233;
                const float c = 43758.543123;

                float d = dot(pixel, float2(a,b)) + seed;
                float s = sin(d);

                return frac(s * c);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 color = random(i.uv, _Time.x) * fixed3(1,1,1);
                return fixed4(color,1);
            }
            ENDCG
        }
    }
}
