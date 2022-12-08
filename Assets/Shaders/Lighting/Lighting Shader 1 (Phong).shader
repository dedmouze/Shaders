Shader "Lighting/Lighting Shader 1 (Phong)"
{
    Properties
    {
        _Smoothness ("Smoothness", Float) = 1
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
                float3 worldPos : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            float _Smoothness;
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                const float3 normal = normalize(i.normal);
                const float3 lightDir = _WorldSpaceLightPos0.xyz;
                
                const float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);
                const float3 reflectDir = reflect(-lightDir, normal);
                
                float3 specularLight = DotClamped(reflectDir, viewDir);
                specularLight = pow(specularLight, _Smoothness) * _LightColor0;
                
                return float4(specularLight, 1);
            }
            ENDCG
        }
    }
}
