Shader "Unlit/GaussianBlur"
{
    Properties
    {
        [NoScaleOffset]_MainTex ("Texture", 2D) = "white" {}
        _kSize("Intensity", Range(1, 1000)) = 65
        _Spread("St. dev. (sigma)", Float) = 10.0
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

            const static float E = 2.71828;

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
            float _Spread;


            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            // One-dimensional Gaussian curve function.
            float gaussian(int x)
            {
                float sigmaSqu = _Spread * _Spread;
                return ( 1 / sqrt( UNITY_TWO_PI) * _Spread ) * pow( E, -(x * x) / (2 * sigmaSqu) );
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float4 col = tex2D(_MainTex, i.uv);
                float kernelSum = 0.0;

                int upper = ((_kSize - 1) / 2);
                int lower = -upper;

                // First pass loop.
                for (int x = lower; x <= upper; ++x)
                {
                    float gauss = gaussian(x);
                    kernelSum += gauss;
                    col += gauss * tex2D(_MainTex, i.uv + fixed2(_MainTex_TexelSize.x * x, 0.0));
                }

                // Second pass loop.
                for (int y = lower; y <= upper; ++y)
                {
                    float gauss = gaussian(y);
                    kernelSum += gauss;
                    col += gauss * tex2D(_MainTex, i.uv + fixed2(0.0, _MainTex_TexelSize.y * y));
                }

                // After loop.
                col /= kernelSum;


                return col;
            }
            ENDCG
        }
    }
}