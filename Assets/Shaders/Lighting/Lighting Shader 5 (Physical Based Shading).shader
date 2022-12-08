Shader "Lighting/Lighting Shader 5 (Physical Based Shading)"
{
    Properties
    {
        [NoScaleOffset]_MainTex ("Texture", 2D) = "white" {}
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
            
            #pragma target 3.0
            #define UNITY_PBS_USE_BRDF1;
            
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityPBSLighting.cginc"
            
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

                float3 albedo = tex2D(_MainTex, i.uv) * _Color.rgb;
                
                float3 specularColor;
                float oneMinusReflectivity;
                albedo = DiffuseAndSpecularFromMetallic(albedo, _Metallic, specularColor, oneMinusReflectivity);
                
                UnityLight light;
                light.color = lightColor;
                light.dir = lightDir;
                light.ndotl = DotClamped(normal, lightDir);

                UnityIndirect indirectLight;
                indirectLight.diffuse = 0;
                indirectLight.specular = 0;
                
                return UNITY_BRDF_PBS(
                    albedo, specularColor,
                    oneMinusReflectivity, _Smoothness,
                    normal, viewDir,
                    light, indirectLight);
            }
            ENDCG
        }
    }
}
