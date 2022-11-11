Shader "Unlit/Health Shader"
{
    Properties
    {
        [NoScaleOffset]_MainTex ("Texture", 2D) = "white"{}
        _HealthValue ("Health value", Range(0, 1)) = 0.5
        _RectWidth ("Rect width", Range(0, 1)) = 0.1
        _RectHeight ("Rect height", Range(0, 1)) = 0.1
        _RectRadius ("Rect radius", Range(0, 1)) = 0.5
        _BorderThickness ("Border thickness", Range(0,1)) = 0.05
        _BorderColor ("Border Color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags 
        { 
            "RenderType"="Transparent"
            "Queue"="Transparent"
        }
        Pass
        {
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            #define TAU 6.283185307179586

            sampler2D _MainTex;
            float _HealthValue;
            float _RectWidth, _RectHeight, _RectRadius;
            float _BorderThickness;
            float4 _BorderColor;

            struct MeshData // per-vertex mesh data
            {
                float4 vertex : POSITION;   // local space vertex position
                float3 normals : NORMAL;    // local space normal direction
                // float color : COLOR; // vertex color
                float2 uv0 : TEXCOORD0;     // uv0 diffuse/normal map texterus
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION; // clip space position
                float3 normal : TEXCOORD0;
                float2 uv : TEXCOORD1;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex); // local space to clip space
                o.normal = UnityObjectToWorldNormal(v.normals);
                o.uv = v.uv0;
                
                return o;
            }

            float InverseLerp (float a, float b, float v) 
            {
                return (v-a)/(b-a);
            }

            float Unity_RoundedRectangle_float(float2 UV, float Width, float Height, float Radius)
            {
                Radius = max(min(min(abs(Radius * 2), abs(Width)), abs(Height)), 1e-5);
                float2 uv = abs(UV * 2 - 1) - float2(Width, Height) + Radius;
                float d = length(max(0, uv)) / Radius;
                return saturate((1 - d) / fwidth(d));
            }

            float4 frag (Interpolators i) : SV_Target
            {
                // saturate() just clamps values in 0-1 period
                // with t = frac(t); you can check if the value goes below 0 it will show duplicates

                // Using texture instead.
                float4 texPart = tex2D(_MainTex, float2 (_HealthValue, i.uv.y));

                float alpha = 1;
                if (_HealthValue < 0.3) 
                    alpha = abs(cos((_Time.y / 2) * TAU));

                // Round Edges.
                float healthRect = Unity_RoundedRectangle_float(i.uv, _RectWidth,  _RectHeight,  _RectRadius);
                float border = 1 - Unity_RoundedRectangle_float(i.uv, _RectWidth - _BorderThickness,  _RectHeight - _BorderThickness,  _RectRadius);

                float healthBarMask = _HealthValue > i.uv.x;

                if (border > 0)
                    return border * healthRect *_BorderColor;

                return healthRect * texPart * alpha * healthBarMask;


                // Manual way.
                // float t = InverseLerp(_HealthValue, 0, i.uv.x);
                // clip(t);
                // float gradientIntensity = _HealthValue;
                // if (_HealthValue < 0.2) gradientIntensity = 0;
                // if (_HealthValue > 0.8) gradientIntensity = 1;
                // float4 gradient = lerp(_StartColor, _EndColor, gradientIntensity);
                
                // if (_HealthValue == 0) t = 0.1;
                // if (_HealthValue == 1) t = 1;

                // return t * gradient;
            }

            ENDCG
        }
    }
}
