Shader "Unlit/LightingTest" {
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
        _OutlineColor ("Outline Color", Color) = (1,0,0,1)
        _Intensity ("Intensity", Range(1, 100)) = 5
        _OutLineWidth ("Outline width", Range(0,1)) = 0.1
        _OutLineSoftness ("OutLine Softness", Range(0,1)) = 0.1
    }
    SubShader {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }

        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct MeshData 
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators 
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float3 wPos : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _OutlineColor;
            float _Intensity;
            float _OutLineWidth;
            float _OutLineSoftness;

            Interpolators vert (MeshData v) 
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = UnityObjectToWorldNormal( v.normal );
                o.wPos = mul( unity_ObjectToWorld, v.vertex );
                return o;
            }

            float4 frag (Interpolators i) : SV_Target 
            {
                float3 N = normalize( i.normal );
                float3 V = normalize( _WorldSpaceCameraPos - i.wPos );

                float fresnel = pow( 1-dot( V, N ), _Intensity);
                float edge1 = 1 - _OutLineWidth;
                float edge2 = edge1 + _OutLineSoftness;

                return lerp( 1, smoothstep(edge1, edge2, fresnel), step( 0, edge1 ) ) * _OutlineColor;
            }
            ENDCG
        }
        
        
    }
}
