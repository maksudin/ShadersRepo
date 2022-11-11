Shader "Unlit/BoxBlur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Resolution("Resolution", Range(1, 4000)) = 1
        _kSize("Intensity", Range(1, 100)) = 18
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float2 _MainTex_TexelSize;
            float _kSize;
            float _Resolution;

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float3 avg = float3(0.0, 0.0, 0.0);

                int upper = ((_kSize - 1) / 2);
                int lower = -upper;

                for (int x = lower; x <= upper; ++x)
                {
                    for (int y = lower; y <= upper; ++y)
                    {
                        fixed2 offset = fixed2( _MainTex_TexelSize.x * x, _MainTex_TexelSize.y * y );
                        avg += tex2D( _MainTex, i.uv + offset );
                    }

                }

                int area = _kSize * _kSize;
                avg = avg.xyz / area;

                return float4(avg.xyz, 1);
            }
            ENDCG
        }
    }
}