Shader "Lighting/Lighting Shader 3 (Diffuse + Specular)"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _SpecularColor ("Specular Color", Color) = (1, 1, 1, 1)
        _Smoothness ("Smoothness", Range(0,1)) = 1
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
            };

            struct v2f
            {
                float3 normal : TEXCOORD1;
                float3 worldPosition : TEXCOORD2;
                float4 vertex : SV_POSITION;
            };
            
            float _Smoothness;
            float4 _Color, _SpecularColor;
            
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
                const float3 lightColor = _LightColor0.rgb;
                
                const float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPosition);
                const float3 halfVector = normalize(lightDir + viewDir);

                float3 albedo = _Color.rgb;
                float oneMinusReflectivity;
		albedo = EnergyConservationBetweenDiffuseAndSpecular(albedo, _SpecularColor.rgb, oneMinusReflectivity);
                
                const float4 lambert = DotClamped(normal, lightDir);
                const float3 diffuseLight = lambert * albedo * lightColor;
                
                float3 specularLight = DotClamped(normal, halfVector) * (lambert > 0);

                const float specularExponent = exp2(_Smoothness * 11) + 2;
                specularLight = pow(specularLight, _Smoothness * specularExponent) * _SpecularColor.rgb * lightColor;
                
                return float4(diffuseLight + specularLight, 1);
            }
            ENDCG
        }
    }
}
