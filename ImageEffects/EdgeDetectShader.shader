Shader "Unlit/EdgeDetectShader"
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
            float2 _MainTex_TexelSize;

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }


            /*	This function uses two Sobel filters to calculate image
                gradients in the x- and y-directions:

                    *----*----*----*				*----*----*----*
                    | -1 |  0 |  1 |				|  1 |  2 |  1 |
                    *----*----*----*				*----*----*----*
            S_x =	| -2 |  0 |  2 |		S_y =	|  0 |  0 |  0 |
                    *----*----*----*				*----*----*----*
                    | -1 |  0 |  1 |				| -1 | -2 | -1 |
                    *----*----*----*				*----*----*----*
            */

            float3 sobel(float2 uv)
			{
				float x = 0;
				float y = 0;

				float2 texelSize = _MainTex_TexelSize;

				// zeroes are missed out for efficiency.
				x += tex2D(_MainTex, uv + float2(-texelSize.x, -texelSize.y)) * -1.0;
				x += tex2D(_MainTex, uv + float2(-texelSize.x,            0)) * -2.0;
				x += tex2D(_MainTex, uv + float2(-texelSize.x,  texelSize.y)) * -1.0;

				x += tex2D(_MainTex, uv + float2( texelSize.x, -texelSize.y)) *  1.0;
				x += tex2D(_MainTex, uv + float2( texelSize.x,            0)) *  2.0;
				x += tex2D(_MainTex, uv + float2( texelSize.x,  texelSize.y)) *  1.0;

				y += tex2D(_MainTex, uv + float2(-texelSize.x, -texelSize.y)) * -1.0;
				y += tex2D(_MainTex, uv + float2(           0, -texelSize.y)) * -2.0;
				y += tex2D(_MainTex, uv + float2( texelSize.x, -texelSize.y)) * -1.0;

				y += tex2D(_MainTex, uv + float2(-texelSize.x,  texelSize.y)) *  1.0;
				y += tex2D(_MainTex, uv + float2(           0,  texelSize.y)) *  2.0;
				y += tex2D(_MainTex, uv + float2( texelSize.x,  texelSize.y)) *  1.0;

				return sqrt(x * x + y * y);
			}

            float4 frag (Interpolators i) : SV_Target
            {
                return fixed4(sobel(i.uv), 1);
            }
            ENDCG
        }
    }
}