Shader "Unlit/Bloom"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Threshold("Bloom Threshold", Range(0, 1)) = 0.5
        _kSize("Intensity", Range(1, 1000)) = 65
        _Spread("St. dev. (sigma)", Float) = 10.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            Name "ThresholdPass"

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "ColorsUtil.cginc"

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
            float _Threshold;

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float4 col = tex2D(_MainTex, i.uv);
                float brightness = rgb2hsv(col).y;
                return (brightness > _Threshold) ? col : float4(0,0,0,1);
            }
            ENDCG
        }
        
        // UsePass "Unlit/GaussianBlurMultiPass/HORIZONTALPASS"
        // UsePass "Unlit/GaussianBlurMultiPass/VERTICALPASS"
    }
}