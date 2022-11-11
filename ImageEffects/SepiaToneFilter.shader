Shader "Unlit/SepiaToneFilter"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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
                half3x3 sepiaVals = half3x3
                (
                    0.393, 0.349, 0.272,    // Red
                    0.769, 0.686, 0.534,    // Green
                    0.189, 0.168, 0.131     // Blue
                );
                half3 sepiaResult = mul(col.rgb, sepiaVals);
                return half4(sepiaResult, col.a);
            }
            ENDCG
        }
    }
}