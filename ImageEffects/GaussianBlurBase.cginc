#include "UnityCG.cginc"

const static float E = 2.71828;

sampler2D _MainTex;
float4 _MainTex_ST;
float2 _MainTex_TexelSize;
int _kSize;
float _Spread;

// One-dimensional Gaussian curve function.
float gaussian(int x)
{
    float sigmaSqu = _Spread * _Spread;
    return ( 1 / sqrt( UNITY_TWO_PI) * _Spread ) * pow( E, -(x * x) / (2 * sigmaSqu) );
}

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

Interpolators vert (MeshData v)
{
    Interpolators o;
    o.vertex = UnityObjectToClipPos(v.vertex);
    o.uv = v.uv;
    return o;
}