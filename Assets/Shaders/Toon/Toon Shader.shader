Shader "Toon/Toon Shader"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        [HDR] _AmbientColor ("Ambient Color", Color) = (1, 1, 1, 1)
        [HDR] _SpecularColor ("Specular Color", Color) = (1, 1, 1, 1)
        [HDR] _RimColor ("Rim Color", Color) = (1, 1, 1, 1)
        _RimAmount ("Rim Amount", Range(0, 1)) = 1
        _RimThreshold ("Rim Threshold", Range(0, 1)) = 1
        _Smoothness ("Smoothness", Range(0, 1.5)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD1;
                float3 worPos : TEXCOORD2;
            };

            float _Smoothness, _RimAmount, _RimThreshold;
            float4 _Color, _AmbientColor, _SpecularColor, _RimColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.worPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }
            
            float4 frag (v2f i) : SV_Target
            {
                const float3 normal = normalize(i.normal);
                const float3 lightDir = _WorldSpaceLightPos0;
                
                const float3 viewDir = normalize(_WorldSpaceCameraPos - i.worPos);
                const float3 halfVec = normalize(lightDir + viewDir);

                const float lambert = saturate(dot(lightDir, normal));
                const float specular = saturate(dot(normal, halfVec));
                const float rim = 1 - saturate(dot(viewDir, normal));
                
                const float lightIntensity = smoothstep(0, 0.01, lambert);
                const float specularExponent = exp2(_Smoothness * 11) + 2;
                const float specularIntensity = pow(specular * lightIntensity, specularExponent);
                const float specularIntensitySmooth = smoothstep(0.005, 0.01, specularIntensity);
                const float rimIntensity = smoothstep(_RimAmount - 0.01, _RimAmount + 0.01, rim * pow(lambert, _RimThreshold));
                
                const float4 diffuseLight = lightIntensity * _LightColor0;
                const float4 specularLight = specularIntensitySmooth * _SpecularColor;
                const float4 rimLight = rimIntensity * _RimColor;
                
                return _Color * (_AmbientColor + diffuseLight + specularLight + rimLight);
            }   
            ENDCG
        }
    }
}
