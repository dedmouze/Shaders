Shader "Lighting/Lighting Shader 6.0 (Multiple Lights)"
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
            Tags { "LightMode"="ForwardBase" }
            CGPROGRAM
            
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting0.cginc"
            
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
            
            #include "Lighting0.cginc"
            
            ENDCG
        }
    }
}
