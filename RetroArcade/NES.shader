Shader "Unlit/NES"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
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
            static const float EPSILON = 1e-10;

            Interpolators vert(MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag(Interpolators i) : SV_Target
            {
                float4 col = tex2D(_MainTex, i.uv);
                int r = (col.r - EPSILON) * 4;
                int g = (col.g - EPSILON) * 4;
                int b = (col.b - EPSILON) * 4;

                return float4(r / 3.0, g / 3.0, b / 3.0, 1);
            }
            ENDCG
        }
    }
}
