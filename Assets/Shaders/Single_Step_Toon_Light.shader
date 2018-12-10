Shader "Unlit/Single_Step_Toon_Light"
{
Properties {
        _Color ("Tint", Color) = (0, 0, 0, 1)
        _MainTex ("Texture", 2D) = "white" {}
        [HDR] _Emission ("Emission", color) = (0 ,0 ,0 , 1)

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
        
		struct Input {
			 float2 uv_MainTex;
		};
	
	    float4 LightingStepped(SurfaceOutput s, float3 lightDir, half3 viewDir, float shadowAttenuation){
            //how much surface normal points towards the light
            float towardsLight = dot(s.Normal,lightDir);
            float towardsLightChange=fwidth(towardsLight);
            //如果第三个值小于第一个值，则函数返回0，如果它大于第二个返回1，其他值返回0到1之间的值
            //smoothstep(edge0, edge1, x): threshod  smooth transition时使用。 x<=edge0时为0.0， x>=edge1时为1.0
            float lightIntensity = smoothstep(0, towardsLightChange,towardsLight);//towardsLight>=0?1:0
            
            float attenuationChange = fwidth(shadowAttenuation) * 0.5;
            float shadow = smoothstep(0.5 - attenuationChange, 0.5 + attenuationChange, shadowAttenuation);
            lightIntensity = lightIntensity * shadow;
            return lightIntensity;
        }
        
		void surf (Input i, inout SurfaceOutput o) {
			fixed4 col = tex2D(_MainTex, i.uv_MainTex);
            col *= _Color;
            o.Albedo = col.rgb;
        
            o.Emission = _Emission;
		}
		ENDCG
	}
	FallBack "Standard"
}
