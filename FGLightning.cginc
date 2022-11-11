#include "UnityCG.cginc"
#include "AutoLight.cginc"

#define USE_LIGHTING

uniform float4 _LightColor0;

struct MeshData
{
    float2 uv : TEXCOORD0;
    float3 normal : NORMAL;
    float4 tangent : TANGENT; // xyz = tangent direction, w = tangent sign
    float4 vertex : POSITION;
};

struct Interpolators
{
    float2 uv : TEXCOORD0;
    float3 normal: TEXCOORD1;
    float3 tangent: TEXCOORD2;
    float3 bitangent: TEXCOORD3;
    float3 wPos: TEXCOORD4;
    float4 vertex : SV_POSITION;
    LIGHTING_COORDS(5, 6)
};

sampler2D _RockAlbedo;
sampler2D _RockNormals;
sampler2D _RockHeight;
sampler2D _DiffuseIBL;
sampler2D _SpecularIBL;

float4 _RockAlbedo_ST;
float4 _Color;
float4 _AmbientLight;
float _Gloss;
float _NormalIntensity;
float _SpecIBLIntensity;
float _DispStrength;

#define TAU 6.283185307179586

float2 Rotate( float2 v, float angRad ) {
    float ca = cos( angRad );
    float sa = sin( angRad );
    return float2( ca * v.x - sa * v.y, sa * v.x + ca * v.y );
}

float2 DirToRectilinear( float3 dir ) 
{
    float x = atan2(dir.z, dir.x) / TAU + 0.5; // 0-1
    float y = dir.y * 0.5 + 0.5; // 0-1
    return float2(x,y);
}

Interpolators vert (MeshData v)
{
    Interpolators o;
    o.uv = TRANSFORM_TEX(v.uv, _RockAlbedo);

    // o.uv = Rotate(o.uv-0.5, _Time.y * 0.1)+0.5;

    float height = tex2Dlod( _RockHeight, float4( o.uv, 0 , 0 ) ).x * 2 - 1;

    v.vertex.xyz += v.normal * (height * _DispStrength);

    o.vertex = UnityObjectToClipPos(v.vertex);
    o.normal = UnityObjectToWorldNormal(v.normal);
    o.tangent = UnityObjectToWorldDir(v.tangent.xyz);
    o.bitangent = cross(o.normal, o.tangent);
    o.bitangent *= v.tangent.w * unity_WorldTransformParams.w;  // correctly handle flipping/mirroring

    o.wPos = mul(unity_ObjectToWorld, v.vertex);
    TRANSFER_VERTEX_TO_FRAGMENT(o) // lighting, actually
    return o;
}

float4 frag (Interpolators i) : SV_Target
{
    float3 rock = tex2D( _RockAlbedo, i.uv);
    float3 surfaceColor = rock * _Color.rgb;
    float3 tangentSpaceNormal = UnpackNormal(tex2D(_RockNormals, i.uv));

    tangentSpaceNormal = normalize( lerp( float3(0,0,1), tangentSpaceNormal, _NormalIntensity ) );

    float3x3 mtxTangToWorld = {
        i.tangent.x, i.bitangent.x, i.normal.x,
        i.tangent.y, i.bitangent.y, i.normal.y,
        i.tangent.z, i.bitangent.z, i.normal.z
    };

    float3 N = mul(mtxTangToWorld, tangentSpaceNormal);

    #ifdef USE_LIGHTING
        // Diffuse lighting.
        // float3 N = normalize(i.normal);
        float3 L = normalize(UnityWorldSpaceLightDir(i.wPos));
        float attenuation = LIGHT_ATTENUATION(i);
        float3 lambert = saturate(dot(N, L));
        float3 diffuseLight = (lambert * attenuation) * _LightColor0.xyz;

        #ifdef IS_IN_BASE_PASS
        #else
            float3 diffuseIBL = tex2Dlod(_DiffuseIBL, float4(DirToRectilinear(N),0,0)).xyz;
            diffuseLight += diffuseIBL; // Adds the indirect diffuse lighting.
        #endif
        
        // Specular lighting.
        float3 V = normalize(_WorldSpaceCameraPos - i.wPos);
        // float3 R = reflect(-L, N); // Uses for Phong.
        float3 H = normalize(L + V);

        float3 specularLight = saturate(dot(H, N)) * (lambert > 0) ; // Blinn-Phong
        float specularExponent = exp2(_Gloss * 11) + 2;

        specularLight = pow(specularLight, specularExponent) * _Gloss * attenuation; // specular exponent
        specularLight *= _LightColor0.xyz;

        // Fresnel.
        // return float4(saturate(1 - dot(N, V)) * _Color.xyz, 1);

        #ifdef IS_IN_BASE_PASS
        #else
            float fresnel = pow(1-saturate(dot(V, N)), 5);

            float3 viewRefl = reflect( -V, N );
            float mip = (1-_Gloss) * 6;
            float3 specularIBL = tex2Dlod(_SpecularIBL, float4(DirToRectilinear(viewRefl),mip,mip)).xyz;
            specularLight += specularIBL * _SpecIBLIntensity * fresnel;
        #endif

        return float4(diffuseLight * surfaceColor + specularLight, 1);
    #else
        #ifdef IS_IN_BASE_PASS
            return surfaceColor;
        #else
            return 0;
        #endif
        
    #endif
}