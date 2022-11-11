Shader "Unlit/shader1"
{
    Properties
    {
        _ColorA ("Color A", Color) = (1, 1, 1, 1)
        _ColorB ("Color B", Color) = (1, 1, 1, 1)
        _ColorStart ("Color Start", Range(0,1)) = 1
        _ColorEnd( "Color End", Range(0,1)) = 0
    }
    SubShader
    {
        Tags { 
                "RenderType"="Transparent"
                "Queue"="Transparent"
             }

        Pass
        {

            Cull Off
            Blend One One       // additive
            // Blend DstColor Zero // multiply
            ZWrite Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            #define TAU 6.283185307179586

            float4 _ColorA;
            float4 _ColorB;
            float _ColorStart;
            float _ColorEnd;


            //float _Scale;
            //float _Offset;
            
            struct MeshData // per-vertex mesh data
            {
                float4 vertex : POSITION;   // local space vertex position
                float3 normals : NORMAL;    // local space normal direction
                // float4 tangent: TANGENT; // tangent direction (xyz) tangent sign (w)
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


            float4 frag (Interpolators i) : SV_Target
            {
                // saturate just clamps values
                // float t = saturate(InverseLerp(_ColorStart, _ColorEnd, i.uv.x));
                // frac = v - floor(v)
                // t = frac(t);

                float xOffset = cos(i.uv.x * TAU * 8 ) * 0.01;

                // return xOffset;
                float t = cos((i.uv.y + xOffset - _Time.y * 0.1) * TAU * 5) * 0.5 + 0.5;
                t *= 1 - i.uv.y;
                
                float topBottomRemover = (abs(i.normal.y) < 0.999);
                float waves = t * topBottomRemover;

                float4 gradient = lerp(_ColorA, _ColorB, i.uv.y);

                return gradient * waves;
                // return outColor;
            }

            ENDCG
        }
    }
}
