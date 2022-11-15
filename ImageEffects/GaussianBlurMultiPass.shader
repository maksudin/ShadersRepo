Shader "Unlit/GaussianBlurMultiPass"
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
            Name "HorizontalPass"

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag_horizontal
            #include "UnityCG.cginc"
            #include "GaussianBlurBase.cginc"

            float4 frag_horizontal (Interpolators i) : SV_Target
            {
                float3 col = float3(0, 0, 0);
                float kernelSum = 0.0;


                int upper = ((_kSize - 1) / 2);
                int lower = -upper;

                for (int x = lower; x <= upper; ++x)
                {
                    float gauss = gaussian(x);
                    kernelSum += gauss;
                    col += gauss * tex2D(_MainTex, i.uv + fixed2(_MainTex_TexelSize.x * x, 0.0));
                }

                col /= kernelSum;

                return float4(col, 1);
            }
            ENDCG
        }

        Pass
        {
            Name "VerticalPass"

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag_vertical
            #include "UnityCG.cginc"
            #include "GaussianBlurBase.cginc"

            float4 frag_vertical (Interpolators i) : SV_Target
            {
                float3 col = float3(0, 0, 0);
                float kernelSum = 0.0;

                int upper = ((_kSize - 1) / 2);
                int lower = -upper;

                for (int y = lower; y <= upper; ++y)
                {
                    float gauss = gaussian(y);
                    kernelSum += gauss;
                    col += gauss * tex2D(_MainTex, i.uv + fixed2(0.0, _MainTex_TexelSize.y * y));
                }

                col /= kernelSum;

                return float4(col, 1);
            }
            ENDCG
        }
    }
}