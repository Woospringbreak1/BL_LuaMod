Shader "Custom/URP/CrystalGlow"
{
    Properties
    {
        _BaseColor("Base Color", Color) = (0.4, 1.0, 1.0, 1)
        _RimColor("Rim Color", Color) = (0.2, 1.0, 0.8, 1)
        _RimPower("Rim Power", Range(1.0, 8.0)) = 4.0

        _EmissionStrength("Emission Strength", Range(0, 5)) = 1.0

        _Smoothness("Smoothness", Range(0,1)) = 0.3
        _Metallic("Metallic", Range(0,1)) = 0.0

        _MainTex("Albedo (RGB)", 2D) = "white" {}
        _NormalMap("Normal Map", 2D) = "bump" {}
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }
        LOD 200

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS   : NORMAL;
                float2 uv         : TEXCOORD0;
                float4 tangentOS  : TANGENT;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 normalWS    : TEXCOORD0;
                float3 viewDirWS   : TEXCOORD1;
                float2 uv          : TEXCOORD2;
                float3 worldPos    : TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _NormalMap;

            float4 _BaseColor;
            float4 _RimColor;
            float _RimPower;
            float _EmissionStrength;
            float _Smoothness;
            float _Metallic;

            Varyings vert(Attributes IN)
            {
                Varyings OUT;

                float3 posWS = TransformObjectToWorld(IN.positionOS);
                OUT.positionHCS = TransformWorldToHClip(float4(posWS, 1.0));
                OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);
                OUT.viewDirWS = normalize(_WorldSpaceCameraPos - posWS);
                OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);
                OUT.worldPos = posWS;

                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                float3 normalTS = UnpackNormal(tex2D(_NormalMap, IN.uv));
                float3 normalWS = normalize(IN.normalWS);

                float3 baseColor = tex2D(_MainTex, IN.uv).rgb * _BaseColor.rgb;

                float rim = pow(1.0 - saturate(dot(normalize(normalWS), IN.viewDirWS)), _RimPower);
                float3 rimGlow = _RimColor.rgb * rim;

                float3 emission = rimGlow * _EmissionStrength;

                float3 finalColor = baseColor + emission;

                return float4(finalColor, 1.0);
            }
            ENDHLSL
        }
    }

    FallBack "Hidden/Shader Graph/FallbackError"
}
