Shader "Unlit/SilhouetteShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NearColor ("Near Clip Colour", Color) = (0.75, 0.35, 0, 1)
        _FarColor  ("Far Clip Colour", Color)  = (1, 1, 1, 1)
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
            sampler2D _CameraDepthTexture;
            float4 _MainTex_ST;
            float4 _NearColor;
            float4 _FarColor;

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                // float4 col = tex2D(_MainTex, i.uv);
                // float depth = SAMPLE_DEPTH_TEXTURE(_MainTex, i.uv);
                float depth = UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.uv));
                depth = Linear01Depth(depth);
                depth = pow(Linear01Depth(depth), 0.75);



                return lerp(_NearColor, _FarColor, depth);
            }
            ENDCG
        }
    }
}