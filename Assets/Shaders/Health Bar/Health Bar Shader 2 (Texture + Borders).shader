Shader "Health Bar/Health Bar Shader 2 (Texture + Borders)"
{
    Properties
    {
        [NoScaleOffset] _MainTexture("Health Bar Texture", 2D) = "white" {}
        
        _BorderColor("Border Color", Color) = (1, 1, 1, 1)
        _BorderWidth("Border Width", Range(0, 0.5)) = 0.1
        
        _ObjectScaleY("Object Scale Y", Range(0.1, 1)) = 0.125
        
        _CriticalFlashVelocity("Critical Flash Velocity", Range(1, 10)) = 4
        _CriticalFlashPower("Critical Flash Power", Range(0, 1)) = 0.1
        _CriticalHealthThreshold ("Critical Health Threshold", Range(0, 1)) = 0.2
        
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
            float _CriticalHealthThreshold, _CriticalFlashVelocity, _CriticalFlashPower;
            float _ObjectScaleY;

            float _BorderWidth;
            float4 _BorderColor;
            
            sampler2D _MainTexture;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }
            
            float4 frag (v2f i) : SV_Target
            {
                //Закругление углов текстуры
                float2 coords = i.uv;
                coords.x /= _ObjectScaleY;
                
                const float2 pointOnLineSeg = float2(clamp(coords.x, 0.5,  1 / _ObjectScaleY - 0.5), 0.5);
                const float sdf = distance(coords, pointOnLineSeg) * 2 - 1;
                clip(-sdf);
                
                const float borderSdf = sdf + _BorderWidth;
                const float borderMask = step(0, -borderSdf);
                
                const float healthBarMask = i.uv.x < _Health;
                float4 currentHealthColor = tex2D(_MainTexture, float2(_Health, i.uv.y));

                if(_Health < _CriticalHealthThreshold)
                {
                    const float flash = cos(_Time.y * _CriticalFlashVelocity) * _CriticalFlashPower + 1;
                    currentHealthColor *= flash;
                }

                float4 output = lerp(_BorderColor, currentHealthColor * healthBarMask, borderMask);
                
                return output;
            }
            ENDCG
        }
    }
}
