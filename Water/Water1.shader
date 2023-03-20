Shader "Custom/Water1"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        [NoScaleOffset] _FlowMap ("Flow (RG, A noise)", 2D) = "black" {}
        // [NoScaleOffset] _NormalMap ("Normals", 2D) = "bump" {}
        [NoScaleOffset] _DerivHeightMap ("Deriv (AG) Height (B)", 2D) = "black" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _UJump ("U jump per phase", Range(-0.25, 0.25)) = 0.25
        _VJump ("V jump per phase", Range(-0.25, 0.25)) = 0.25
        _Tiling ("Tiling", Float) = 1
        _Speed ("Speed", Float) = 1
        _FlowStrength ("Flow Strength", Float) = 1
        _FlowOffset ("Flow Offset", Float) = 1
        _HeightScale ("Height Scale Const", Float) = 1
        _HeightScaleModulated ("Height Scale, Modulated", Float) = 0.75
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.0

        #include "FlowUV.cginc"

        sampler2D _MainTex, _FlowMap, _DerivHeightMap;
        float _UJump, _VJump, _Tiling, _Speed, _FlowStrength,
              _FlowOffset, _HeightScale, _HeightScaleModulated;

        struct Input
        {
            float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            float2 flowVector = tex2D(_FlowMap, IN.uv_MainTex).rg * 2 - 1;
            flowVector *= _FlowStrength;
            float noise = tex2D (_FlowMap, IN.uv_MainTex).a;
            float time = _Time.y * _Speed + noise;
            float2 jump = float2(_UJump, _VJump);
            float finalHeight = length(flowVector) * _HeightScale + _HeightScaleModulated;

            // flowVector = float2 (0,0);

            float3 uvwA = FlowUVW(IN.uv_MainTex, flowVector, jump,
                    _FlowOffset, _Tiling, time, false);
            float3 uvwB = FlowUVW(IN.uv_MainTex, flowVector, jump,
                    _FlowOffset, _Tiling, time, true);

            float3 dhA = UnpackDerivativeHeight(tex2D(_DerivHeightMap, uvwA.xy) * (uvwA.z * finalHeight));
            float3 dhB = UnpackDerivativeHeight(tex2D(_DerivHeightMap, uvwB.xy) * (uvwB.z * finalHeight));
            
            o.Normal = normalize(float3(-(dhA.xy + dhB.xy), 1));

            fixed4 texA = tex2D(_MainTex, uvwA.xy) * uvwA.z; 
            fixed4 texB = tex2D(_MainTex, uvwB.xy) * uvwB.z; 

            fixed4 c = (texA + texB) * _Color;
            o.Albedo = c.rgb;
            o.Albedo = pow(dhA.z + dhB.z, 2);
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
