Shader "Unlit/white_noise"
{
Properties {
	}
	SubShader {
		Tags{ "RenderType"="Opaque" "Queue"="Geometry"}

		CGPROGRAM

		#pragma surface surf Standard fullforwardshadows
		#pragma target 3.0

		#include "WhiteNoise.cginc"

		struct Input {
			float3 worldPos;
		};
	    float rand(float3 vec){
	        float3 smallValue = sin(vec);
            float random = dot(smallValue, float3(12.9898, 78.233, 37.719));
            random = frac(sin(random) * 143758.5453);
            return random;
        }
		void surf (Input i, inout SurfaceOutputStandard o) {
			float3 value = i.worldPos;
			o.Albedo = rand3dTo3d(i.worldPos);//rand(value);
		}
		ENDCG
	}
	FallBack "Standard"
}
