Shader "Unlit/LightTestMulti"
{
    Properties
    {
        _RockAlbedo ("Rock Albedo", 2D) = "white" {}
        [NoScaleOffset] _RockNormals ("Rock Normals", 2D) = "bump" {}       // bump - flat normal
        [NoScaleOffset] _RockHeight ("Rock Height", 2D) = "gray" {}       // 0.5
        _DiffuseIBL ("Diffuse IBL", 2D) = "black" {}
        _SpecularIBL ("Specular IBL", 2D) = "black" {}
        _Gloss ("Gloss", Range(0, 1)) = 1
        _Color ("Color", Color) = (1,1,1,1)
        _AmbientLight ("Ambient Light", Color) = (0,0,0,0)
        _SpecIBLIntensity ("Specular IBL Intensity", Range(0,1)) = 1
        _NormalIntensity ("Normal Intensity", Range(0,1)) = 1
        _DispStrength ("Displacement Intensity", Range(0,2)) = 0
        
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry"}

        // Base pass.
        Pass
        {
            Tags {"LightMode" = "ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "FGLightning.cginc"
            #define IS_IN_BASE_PASS

            ENDCG
        }

        // Add pass.
        Pass
        {
            Tags {"LightMode" = "ForwardAdd"}

            Blend One One // src*1 + dst*1
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdadd

            #include "FGLightning.cginc"
            ENDCG
        }
    }
}