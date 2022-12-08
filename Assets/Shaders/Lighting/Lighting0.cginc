#if !defined(LIGHTING0_INCLUDED)

    #define LIGHTING0_INCLUDED
    #define UNITY_PBS_USE_BRDF1;

    #include "UnityPBSLighting.cginc"
    #include "AutoLight.cginc"

    struct appdata
    {
        float4 vertex : POSITION;
        float3 normal : NORMAL;
        float2 uv : TEXCOORD0;
        
    };

    struct v2f
    {
        float4 vertex : SV_POSITION;
        float3 normal : TEXCOORD0;
        float3 worldPosition : TEXCOORD1;
        float2 uv : TEXCOORD2;
        LIGHTING_COORDS(3, 4)
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
        TRANSFER_VERTEX_TO_FRAGMENT(o);
        return o;
    }

    float4 frag (v2f i) : SV_Target
    {
        const float3 normal = normalize(i.normal);
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
