Shader "Lighting/Lighting Shader 4 (Metallic + Texture)"
{
    Properties
    {
        [NoScaleOffset] _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1, 1, 1, 1)
        [Gamma] _Metallic ("Metallic", Range(0, 1)) = 0
        _Smoothness ("Smoothness", Range(0, 1)) = 0.1
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
            #include "UnityStandardUtils.cginc"
            
            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float3 normal : TEXCOORD1;
                float3 worldPosition : TEXCOORD2;
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD3;
            };

            float _Smoothness, _Metallic;
            float4 _Color;

            sampler2D _MainTex;
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.worldPosition = mul(unity_ObjectToWorld, v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                const float3 normal = normalize(i.normal);
                const float3 lightDir = _WorldSpaceLightPos0.xyz;
                const float3 lightColor = _LightColor0.rgb;
                
                const float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPosition);
                const float3 halfVector = normalize(lightDir + viewDir);

                float3 albedo = tex2D(_MainTex, i.uv) * _Color.rgb;
                
                float3 specularColor;
                float oneMinusReflectivity;
                albedo = DiffuseAndSpecularFromMetallic(albedo, _Metallic, specularColor, oneMinusReflectivity);
                
                const float4 lambert = DotClamped(normal, lightDir);
                const float3 diffuseLight = lambert * albedo * lightColor;
                
                float3 specularLight = DotClamped(normal, halfVector);

                const float specularExponent = exp2(_Smoothness * 11) + 2;
                specularLight = pow(specularLight, specularExponent * _Smoothness) * specularColor * lightColor;
                
                return float4(diffuseLight + specularLight, 1);
            }
            ENDCG
        }
    }
}
