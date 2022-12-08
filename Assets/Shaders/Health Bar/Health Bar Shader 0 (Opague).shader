Shader "Health Bar/Health Bar Shader 0 (Opaque)"
{
    Properties
    {
        _StartColor ("Start Color", Color) = (1, 0, 0, 1)
        _EndColor ("End Color", Color) = (0, 1, 0, 1)
        
        _EmptyColor ("Empty Bar Color", Color) = (0, 0, 0, 1)
        
        _MinHealthThreshold ("Min Health Threshold", Range(0, 1)) = 0.2
        _MaxHealthThreshold ("Max Health Threshold", Range(0, 1)) = 0.8
        
        _Health ("Health", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            float _Health;
            float _MinHealthThreshold, _MaxHealthThreshold;
            float4 _StartColor, _EndColor;
            float4 _EmptyColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float InverseLerp(float a, float b, float v)
            {
                return (v - a) / (b - a);
            }
            
            float4 frag (v2f i) : SV_Target
            {
                const float t = saturate(InverseLerp(_MinHealthThreshold, _MaxHealthThreshold, _Health));
                const float healthBarMask = i.uv.x < _Health;
                const float4 currentHealthColor = lerp(_StartColor, _EndColor, t);
                const float4 outColor = lerp(_EmptyColor, currentHealthColor, healthBarMask);
                
                return outColor;
            }
            ENDCG
        }
    }
}
