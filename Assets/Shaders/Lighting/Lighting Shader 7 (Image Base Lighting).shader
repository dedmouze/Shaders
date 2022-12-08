Shader "Lighting/Lighting Shader 7 (Image Based Lighting)"
{
    Properties
    {
        _MainTex ("Albedo", 2D) = "white" {}
        [NoScaleOffset] _NormalMap ("Normal Map", 2D) = "bump" {}
        [NoScaleOffset] _HeightMap ("Height Map", 2D) = "gray" {}
        [NoScaleOffset] _DiffuseIBL ("Diffuse IBL", 2D) = "black" {}
        [NoScaleOffset] _SpecularIBL ("Specular IBL", 2D) = "black" {}
        _Color ("Color", Color) = (1, 1, 1, 1)
        _Smoothness ("Smoothness", Range(0, 1)) = 0.1
        _NormalIntensity ("Normal Intensity", Range(0, 1)) = 0.5
        _HeightStrength ("Height Strength", Range(0, 0.2)) = 0
        _DiffIBLIntensity ("Diff IBL Intensity",  Range(0, 1)) = 0.5
        _SpecIBLIntensity ("Spec IBL Intensity", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            Tags { "LightMode"="ForwardBase" }
            CGPROGRAM
            
            #pragma target 3.5
            #pragma vertex vert
            #pragma fragment frag

            #define BASE_PASS
            
            #include "ImageBasedLighting.cginc"
            
            ENDCG
        }

        Pass
        {
            Tags { "LightMode"="ForwardAdd" }
            
            Blend One One
            ZWrite Off
            
            CGPROGRAM
            
            #pragma target 3.5
            #pragma multi_compile_fwdadd
            
            #pragma vertex vert
            #pragma fragment frag
            
            #include "ImageBasedLighting.cginc"
            
            ENDCG
        }
    }
    
    CustomEditor "LightingShaderGUI"
}
