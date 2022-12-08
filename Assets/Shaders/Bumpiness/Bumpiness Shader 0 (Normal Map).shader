Shader "Bumpiness/Bumpiness Shader 0 (Normal Map)"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [NoScaleOffset] _NormalMap ("Normal Map", 2D) = "bump" {}
        _Color ("Color", Color) = (1, 1, 1, 1)
        [Gamma] _Metallic ("Metallic", Range(0, 1)) = 0
        _Smoothness ("Smoothness", Range(0, 1)) = 0.1
        _NormalIntensity ("Normal Intensity", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            Tags { "LightMode"="ForwardBase" }
            CGPROGRAM
            
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag

            #include "NormalMapLighting.cginc"
            
            ENDCG
        }

        Pass
        {
            Tags { "LightMode"="ForwardAdd" }
            
            Blend One One
            ZWrite Off
            
            CGPROGRAM
            
            #pragma target 3.0
            #pragma multi_compile_fwdadd
            
            #pragma vertex vert
            #pragma fragment frag
            
            #include "NormalMapLighting.cginc"
            
            ENDCG
        }
    }
}
