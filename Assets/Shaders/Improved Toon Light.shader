Shader "Unlit/Improved Toon Light"
{
Properties {
        _Color ("Tint", Color) = (0, 0, 0, 1)
        _MainTex ("Texture", 2D) = "white" {}
        [HDR] _Emission ("Emission", color) = (0 ,0 ,0 , 1)

        [Header(Lighting Parameters)]
        _ShadowTint ("Shadow Color", Color) = (0.5, 0.5, 0.5, 1)
        [IntRange]_StepAmount ("Shadow Steps", Range(1, 16)) = 2
        _StepWidth ("Step Size", Range(0.05, 1)) = 0.25
        
        _SpecularSize ("Specular Size", Range(0, 1)) = 0.1
        _SpecularFalloff ("Specular Falloff", Range(0, 2)) = 1
	}
	SubShader {
		Tags{ "RenderType"="Opaque" "Queue"="Geometry"}

		CGPROGRAM

		#pragma surface surf Stepped fullforwardshadows
		#pragma target 3.0

		#include "WhiteNoise.cginc"

        sampler2D _MainTex;
        fixed4 _Color;
        half3 _Emission;
        float3 _ShadowTint;
        float _StepAmount;
        float _StepWidth;
        float _SpecularSize;
        float _SpecularFalloff;
        
		struct Input {
			 float2 uv_MainTex;
		};
	
	    float4 LightingStepped(SurfaceOutput s, float3 lightDir, half3 viewDir, float shadowAttenuation){

            float towardsLight = dot(s.Normal, lightDir);
            towardsLight = towardsLight / _StepWidth;
            float lightIntensity = floor(towardsLight);//返回小于等于x的最大整数。
            float change = fwidth(towardsLight);
           lightIntensity += smoothstep(0, change, frac(towardsLight));
            //lightIntensity = lightIntensity + smoothing;
            lightIntensity = lightIntensity / _StepAmount;
            lightIntensity = saturate(lightIntensity);
            
            //caculate Specular
            float3 reflectionDirection = reflect(lightDir, s.Normal);
            float towardsReflection=dot(viewDir,reflectionDirection);
            float specularFalloff = dot(viewDir, s.Normal);
            specularFalloff = pow(specularFalloff,_SpecularFalloff);
            towardsReflection = towardsReflection * specularFalloff;
            float specularChange=fwidth(towardsReflection);
            float specularIntensity=smoothstep(1-_SpecularSize,1-_SpecularSize+specularChange,towardsReflection);
            
            //caculate shadow color
            float3 shadowColor = s.Albedo * _ShadowTint;
            float4 color;
            color.rgb = s.Albedo * lightIntensity * _LightColor0.rgb;
            color.a = s.Alpha;
            return color+specularIntensity;
            //return lightIntensity;
        }
        
		void surf (Input i, inout SurfaceOutput o) {
			 fixed4 col = tex2D(_MainTex, i.uv_MainTex);
             col *= _Color;
             o.Albedo = col.rgb;
            
             float3 shadowColor = col.rgb * _ShadowTint;
             o.Emission = _Emission + shadowColor;
		}
		ENDCG
	}
	FallBack "Standard"
}
