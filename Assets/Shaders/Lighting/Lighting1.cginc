#if !defined(LIGHTING1_INCLUDED)

    #define LIGHTING1_INCLUDED
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

    UnityLight CreateLight(v2f i)
    {
        UnityLight light;
        
        #if defined(POINT) || defined(POINT_COOKIE) || defined(SPOT)
            light.dir = normalize(_WorldSpaceLightPos0.xyz - i.worldPosition);
        #else
            light.dir = _WorldSpaceLightPos0.xyz;
        #endif

        UNITY_LIGHT_ATTENUATION(attenuation, 0, i.worldPosition);
        light.color = _LightColor0.rgb * attenuation;
        light.ndotl = DotClamped(i.normal, light.dir);
        return light;
    }

    float4 frag (v2f i) : SV_Target
    {
        i.normal = normalize(i.normal);
        
        const float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPosition);

        float3 albedo = tex2D(_MainTex, i.uv) * _Color.rgb;
        
        float3 specularColor;
        float oneMinusReflectivity;
        albedo = DiffuseAndSpecularFromMetallic(albedo, _Metallic, specularColor, oneMinusReflectivity);

        UnityIndirect indirectLight;
        indirectLight.diffuse = 0;
        indirectLight.specular = 0;
        
        return UNITY_BRDF_PBS(
            albedo, specularColor,
            oneMinusReflectivity, _Smoothness,
            i.normal, viewDir,
            CreateLight(i), indirectLight);
    }
#endif
