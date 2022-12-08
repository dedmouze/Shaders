#if !defined(IMAGE_BASED_LIGHTING_INCLUDED)

    #define IMAGE_BASED_LIGHTING_INCLUDED
    #define TAU 6.28318530718

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
        float2 noiseUV : TEXCOORD0;
        float3 worldPosition : TEXCOORD1;
        float3 normal : TEXCOORD2;
        float3 tangent : TEXCOORD3;
        float3 binormal : TEXCOORD4;
        LIGHTING_COORDS(5, 6)
    };

    float _Smoothness;
    float4 _Color;

    sampler2D _MainTex, _NormalMap, _HeightMap;
    float4 _MainTex_ST;

    sampler2D _DiffuseIBL, _SpecularIBL;

    float _NormalIntensity, _HeightStrength;
    float _DiffIBLIntensity, _SpecIBLIntensity;

    v2f vert (appdata v)
    {
        v2f o;

        o.noiseUV = TRANSFORM_TEX(v.uv, _MainTex);
        const float height = tex2Dlod(_HeightMap, float4(o.noiseUV, 0, 0)).x * 2 - 1;
        v.vertex.xyz += v.normal * (height * _HeightStrength);
            
        o.vertex = UnityObjectToClipPos(v.vertex);
        o.normal = UnityObjectToWorldNormal(v.normal);
        o.tangent = UnityObjectToWorldDir(v.tangent.xyz);
        o.binormal = cross(o.normal, o.tangent) * v.tangent.w * unity_WorldTransformParams.w;
        o.worldPosition = mul(unity_ObjectToWorld, v.vertex);
        TRANSFER_VERTEX_TO_FRAGMENT(o);
        return o;
    }

    float2 DirToRectilinear(float3 dir)
    {
        float x = atan2(dir.z, dir.x) / TAU + 0.5;
        float y = dir.y * 0.5 + 0.5;
        return float2(x, y);
    }

    float4 frag (v2f i) : SV_Target
    {
        float3 tangentSpaceNormal = UnpackNormal(tex2D(_NormalMap, i.noiseUV));
        tangentSpaceNormal = normalize(lerp(float3(0, 0, 1), tangentSpaceNormal, _NormalIntensity)); // Тоже самого можно достичь с помощью UnpackScaleNormal
            
        const float3x3 tangToWorld =
        {
            i.tangent.x, i.binormal.x, i.normal.x,
            i.tangent.y, i.binormal.y, i.normal.y,
            i.tangent.z, i.binormal.z, i.normal.z,
        };

        const float3 normal = mul(tangToWorld, tangentSpaceNormal);
            
        const float3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPosition));
        const float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPosition);
        const float3 halfDir = normalize(lightDir + viewDir);
        const float3 lightColor = _LightColor0.rgb;
            
        const float attenuation = LIGHT_ATTENUATION(i);

        const float3 albedo = tex2D(_MainTex, i.noiseUV) * _Color.rgb;
            
        const float3 lambert = DotClamped(normal, lightDir);
        float3 diffuseLight = lambert * attenuation * lightColor;
            
        float3 specularLight = DotClamped(halfDir, normal) * (lambert > 0);
        const float specularExponent = exp2( _Smoothness * 11 ) + 2;
        specularLight = pow(specularLight, specularExponent) * _Smoothness * lightColor * attenuation;
        
        #ifdef BASE_PASS
            const float3 diffuseIBL = tex2Dlod(_DiffuseIBL, float4(DirToRectilinear(normal), 0, 0)).xyz;
            diffuseLight += diffuseIBL * _DiffIBLIntensity;

            const float fresnel = pow(1 - DotClamped(normal, viewDir), 5);
            const float3 viewRefl = reflect(-viewDir, normal);
            float mip = (1 - _Smoothness) * 6;
            const float3 specularIBL = tex2Dlod(_SpecularIBL, float4(DirToRectilinear(viewRefl), mip, mip)).xyz;
            specularLight += specularIBL * fresnel * _SpecIBLIntensity; 
        #endif 
        
        return float4(diffuseLight * albedo + specularLight, 1);
    }
#endif 