Shader "Toon/Toon Water Shader"
{
    Properties
    {
        _DepthShallowColor("Depth Shallow Color", Color) = (0, 0.5, 1, 1)
        _DepthDeepColor("Depth Deep Color", Color) = (0, 0, 1, 1)
        _DepthMaxDistance("Depth Max Distance", Float) = 1.15
        
        _SurfaceNoise("Surface Noise", 2D) = "white" {}
        _SurfaceNoiseCutoff("Surface Noise Cutoff", Range(0, 1)) = 0.7
        _SurfaceNoiseScroll("Surface Noise Scroll", Vector) = (0, 0, 0, 0)
        _SurfaceDistortion("Surface Distortion", 2D) = "white" {}
        _SurfaceDistortionAmount("Surface Distortion Amount", Range(0, 1)) = 0.15
        
        _FoamColor("Foam Color", Color) = (1, 1, 1, 1)
        _FoamMinDistance("Foam Minimum Distance", Range(0, 2)) = 0.2
        _FoamMaxDistance("Foam Maximum Distance", Range(0, 2)) = 0.4
        
        [HideInInspector] _Mode ("__mode", Float) = 0.0
        [HideInInspector] _SrcBlend ("__src", Float) = 1.0
        [HideInInspector] _DstBlend ("__dst", Float) = 0.0
        [HideInInspector] _ZWrite ("__zw", Float) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        
        Blend [_SrcBlend] [_DstBlend]
        ZWrite [_ZWrite]
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 noiseUV : TEXCOORD0;
                float2 distortUV : TEXCOORD1;
                float4 screenPos : TEXCOORD2;
                float3 viewNormal : TEXCOORD3;
            };
            
            float4 _DepthShallowColor, _DepthDeepColor;
            float _DepthMaxDistance;

            sampler2D _SurfaceNoise, _SurfaceDistortion;
            float4 _SurfaceNoise_ST, _SurfaceDistortion_ST;
            float _SurfaceNoiseCutoff, _SurfaceDistortionAmount;
            float2 _SurfaceNoiseScroll;

            float4 _FoamColor;
            float _FoamMinDistance, _FoamMaxDistance;
            
            sampler2D _CameraDepthTexture, _CameraNormalsTexture;
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.screenPos = ComputeScreenPos(o.vertex);
                o.noiseUV = TRANSFORM_TEX(v.uv, _SurfaceNoise);
                o.distortUV = TRANSFORM_TEX(v.uv, _SurfaceDistortion);
                o.viewNormal = COMPUTE_VIEW_NORMAL;
                return o;
            }
            
            float4 frag (v2f i) : SV_Target
            {
                const float existingDepth = tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPos)).r;
                const float existingDepthLinear = LinearEyeDepth(existingDepth);
                
                const float depthDifference = existingDepthLinear - i.screenPos.w;

                const float3 existingNormal = tex2Dproj(_CameraNormalsTexture, UNITY_PROJ_COORD(i.screenPos));
                const float3 normalDot = saturate(dot(existingNormal, i.viewNormal));
                
                const float waterDepthDifference = saturate(depthDifference / _DepthMaxDistance);
                const float foamDistance = lerp(_FoamMaxDistance, _FoamMinDistance, normalDot);
                const float foamDepthDifference = saturate(depthDifference / foamDistance);
                
                const float4 waterColor = lerp(_DepthShallowColor, _DepthDeepColor, waterDepthDifference);

                const float2 distortSample = (tex2D(_SurfaceDistortion, i.distortUV).xy * 2 - 1) * _SurfaceDistortionAmount;
                const float2 noiseUV = float2(
                    i.noiseUV.x + _Time.y * _SurfaceNoiseScroll.x + distortSample.x,
                    i.noiseUV.y + _Time.y * _SurfaceNoiseScroll.y + distortSample.y);
                
                const float surfaceNoiseTex = tex2D(_SurfaceNoise, noiseUV).r;
                const float surfaceNoiseCutoff = foamDepthDifference * _SurfaceNoiseCutoff;
                const float surfaceNoise = smoothstep(surfaceNoiseCutoff - 0.01, surfaceNoiseCutoff + 0.01, surfaceNoiseTex); // можно просто surfaceNoiseTex > surfaceNoiseCutoff

                const float4 o = lerp(waterColor, _FoamColor, surfaceNoise);
                
                return o;
            }
            
            ENDCG
        }
    }
    
    CustomEditor "ToonWaterShaderGUI"
}
