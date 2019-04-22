Shader "Custom/VolumeShadow" {
	Properties {
		_Color("Color", Color) = (1,1,1,0.002)
		_MainTex ("Base texture", 2D) = "white" {}
		_ExtrusionFactor("Extrusion", Range(0, 2)) = 0.1
		_Intensity("Intensity", Range(0, 10)) = 1
		_WorldLightPos("LightPos", Vector) = (0,0,0,0)
	}
	SubShader {
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent + 1" }
		Blend SrcAlpha OneMinusSrcAlpha
		Cull Off 
		ZWrite Off
		Fog { Color (0,0,0,0) }

        CGINCLUDE
        #include "UnityCG.cginc"
        
        float4 _Color;
		float4 _WorldLightPos;
		sampler2D _MainTex;
		float _ExtrusionFactor;
		float _Intensity;
		
		struct v2f {
			float4	pos		: SV_POSITION;
			float2	uv		: TEXCOORD0;
			float distance : TEXCOORD1;
		};
		v2f vert (appdata_base v){
		    v2f o;
		    float3 objectLightPos = mul(unity_WorldToObject,_WorldLightPos.xyz).xyz;
		    float3 objectLightDir = objectLightPos-v.vertex.xyz;
		    float dotValue = dot(objectLightPos,v.normal);
		    float controlValue = sign(dotValue) * 0.5 + 0.5;
		    float4 vpos = v.vertex;
		    //挤出
		    vpos.xyz -= objectLightDir * _ExtrusionFactor * controlValue;
		    o.uv = v.texcoord.xy;
		    o.pos = UnityObjectToClipPos(vpos);
		    o.distance = length(objectLightDir);
		    
		    return o;
		}
		fixed4 frag(v2f i):COLOR{
		    fixed4 tex = tex2D(_MainTex,i.uv);
		    float att=i.distance/_WorldLightPos.w;
		    return _Color * tex * att * _Intensity;
		}
		ENDCG
    Pass{
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#pragma fragmentoption ARB_precision_hint_fastest
		ENDCG
		}
	}
}
