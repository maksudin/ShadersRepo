Shader "Unlit/FGSkyBox"
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
                float3 viewDir : TEXCOORD0;
            };

            struct Interpolators
            {
                float3 viewDir : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            #define TAU 6.283185307179586

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.viewDir = v.viewDir;
                return o;
            }

            float2 DirToRectilinear( float3 dir ) 
            {
                float x = atan2(dir.z, dir.x) / TAU + 0.5; // 0-1
                float y = dir.y * 0.5 + 0.5; // 0-1
                return float2(x,y);
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float3 col = tex2Dlod(_MainTex, float4(DirToRectilinear(i.viewDir), 0, 0));
                return float4(col, 1);
            }
            ENDCG
        }
    }
}