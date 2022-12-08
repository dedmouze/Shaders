#if !defined(NORMAL_HEIGHT_MAP_LIGHTING_INCLUDED)

    #define NORMAL_HEIGHT_MAP_LIGHTING_INCLUDED
    #define UNITY_PBS_USE_BRDF1;

    #include "UnityPBSLighting.cginc"
    #include "AutoLight.cginc"

    struct appdata
    {
        float4 vertex : POSITION;
        float3 normal : NORMAL;
        float4 tangent : TANGENT;
        float2 uv : TEXCOORD0;
        
    };

    struct v2f
    {
        float4 vertex : SV_POSITION;
        float2 uv : TEXCOORD0;
        float3 worldPosition : TEXCOORD1;
        float3 normal : TEXCOORD2;
        float3 tangent : TEXCOORD3;
        float3 binormal : TEXCOORD4;
        LIGHTING_COORDS(5, 6)
    };

    float _Smoothness, _Metallic;
    float4 _Color;

    sampler2D _MainTex, _NormalMap, _HeightMap;
    float4 _MainTex_ST;

    float _NormalIntensity, _HeightStrength;

    v2f vert (appdata v)
    {
        v2f o;

        o.uv = TRANSFORM_TEX(v.uv, _MainTex);
        const float height = tex2Dlod(_HeightMap, float4(o.uv, 0, 0)).x * 2 - 1;
        v.vertex.xyz += v.normal * height * _HeightStrength;
        
        o.vertex = UnityObjectToClipPos(v.vertex);
        o.normal = UnityObjectToWorldNormal(v.normal);
        o.tangent = UnityObjectToWorldDir(v.tangent.xyz);
        o.binormal = cross(o.normal, o.tangent) * v.tangent.w * unity_WorldTransformParams.w;
        o.worldPosition = mul(unity_ObjectToWorld, v.vertex);
        TRANSFER_VERTEX_TO_FRAGMENT(o);
        return o;
    }

    float4 frag (v2f i) : SV_Target
    {
        float3 tangentSpaceNormal = UnpackNormal(tex2D(_NormalMap, i.uv));
        tangentSpaceNormal = lerp(float3(0, 0, 1), tangentSpaceNormal, _NormalIntensity); // Тоже самого можно достичь с помощью UnpackScaleNormal
        
        const float3x3 tangToWorld = 
        {
            i.tangent.x, i.binormal.x, i.normal.x,
            i.tangent.y, i.binormal.y, i.normal.y,
            i.tangent.z, i.binormal.z, i.normal.z,
        };

        const float3 normal = mul(tangToWorld, tangentSpaceNormal);
        
        const float3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPosition));
        const float3 lightColor = _LightColor0.rgb;

        const float attenuation = LIGHT_ATTENUATION(i);
        
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
            albedo * attenuation, specularColor * attenuation,
            oneMinusReflectivity, _Smoothness,
            normal, viewDir,
            light, indirectLight);
    }
#endif
