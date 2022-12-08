Shader "Lighting/Lighting Shader 0 (Lambert)"
{
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityStandardBRDF.cginc"
            
            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float3 normal : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            float _Smoothness;
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                const float3 lightDir = _WorldSpaceLightPos0.xyz;
                
                const float4 lambert = DotClamped(i.normal, lightDir);
                const float3 diffuseLight = lambert * _LightColor0;
                
                return float4(diffuseLight, 1);
            }
            ENDCG
        }
    }
}
