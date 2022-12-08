Shader "Lighting/Lighting Shader 2 (Blinn-Phong)"
{
    Properties
    {
        _Smoothness ("Smoothness", Range(0, 1)) = 1
    }
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
                float3 worldPosition : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            float _Smoothness;
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.worldPosition = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                const float3 normal = normalize(i.normal);
                const float3 lightDir = _WorldSpaceLightPos0.xyz;
                
                const float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPosition);
                const float3 halfVector = normalize(lightDir + viewDir);

                const float4 lambert = DotClamped(normal, lightDir);
                float3 specularLight = DotClamped(normal, halfVector) * (lambert > 0);

                const float specularExponent = exp2(_Smoothness * 11) + 2;
                specularLight = pow(specularLight, _Smoothness * specularExponent) * _LightColor0.rgb;
                
                return float4(specularLight, 1);
            }
            ENDCG
        }
    }
}
