Shader "Unlit/Fisheye"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BarrelPower("Barrel Power", Float) = 5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            uniform float _BarrelPower;

            float2 distort(float2 pos) 
            {
                float theta = atan2(pos.y, pos.x);
                float radius = length(pos);
                radius = pow(radius, _BarrelPower);
                pos.x = radius * cos(theta);
                pos.y = radius * sin(theta);

                return 0.5 * (pos + 1.0);
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 xy = 2.0 * i.uv - 1.0;
                float d = length(xy);

                if (d >= 1.0)
                    discard;

                float uv = distort(xy);
                fixed4 col = tex2D(_MainTex, uv);
                return col;
            }
            ENDCG
        }
    }
}
