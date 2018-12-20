Shader "Custom/Disslove" {
	Properties {
	    [Header(Glow)]
        [HDR]_GlowColor("Color", Color) = (1, 1, 1, 1)
        _GlowRange("Range", Range(0, 1)) = 0.1
        _GlowFalloff("Falloff", Range(0, 1)) = 0.1
        
	
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_DissolveTex ("Dissolve Texture", 2D) = "black" {}
		_DissolveAmount ("Dissolve Amount", Range(0, 1)) = 0.5
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;
        sampler2D _DissolveTex;
        float _DissolveAmount;
        
        float3 _GlowColor;
        float _GlowRange;
        float _GlowFalloff;
        
		struct Input {
			float2 uv_MainTex;
			float2 uv_DissolveTex;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;
		
		half3 _Emission;

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_BUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)

		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
			float dissolve = tex2D(_DissolveTex, IN.uv_DissolveTex).r;
			dissolve=dissolve*0.999;
			float isVisible=dissolve-_DissolveAmount;
			clip(isVisible);//不渲染负数 黑色为0首先被减成负数
			
			float isGlowing=smoothstep(_GlowRange + _GlowFalloff, _GlowRange,isVisible);//clip 区域isVisible为负数
			//0	x < a < b 或 x > a > b
			//1	x < b < a 或 x > b > a
			float3 glow=isGlowing*_GlowColor;
			
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			c= lerp(dissolve,c,1);
			o.Albedo = c;
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
		    o.Emission =  glow;
		}
		ENDCG
	}
	FallBack "Standard"
}
