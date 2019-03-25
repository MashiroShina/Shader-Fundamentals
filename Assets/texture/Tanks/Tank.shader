Shader "Custom/Tank" {
	Properties
	{
		_Color ("Tint", Color) = (0, 0, 0, 1)
		_MainTex ("Texture", 2D) = "white" {}
		_BackGround ("BackGround", 2D) = "white" {}
		[KeywordEnum(OFF,ON,NULL)] _CLIPPING ("Alpha BlackGround", Float) = 0
		[KeywordEnum(OFF,ON)] _HaveColor ("HaveColor", Float) = 0
	}
	SubShader
	{
		Tags{ "RenderType"="Transparent" "Queue"="Transparent"}
		
		Blend SrcAlpha OneMinusSrcAlpha
		ZWrite off

		Pass
		{
			CGPROGRAM
			#include "UnityCustomRenderTexture.cginc"
			#pragma vertex InitCustomRenderTextureVertexShader
			#pragma fragment frag
			#pragma shader_feature _CLIPPING_ON
			#pragma shader_feature _CLIPPING_OFF
			
			#pragma shader_feature _HaveColor_ON
			#pragma shader_feature _HaveColor_OFF
            sampler2D _MainTex;
            sampler2D _BackGround;
			float4 _MainTex_ST;
			float4 _BackGround_ST;
			
			fixed4 _Color;

			struct v2f
			{
				float4 position : SV_POSITION;
				float2 uv : TEXCOORD0;
			};
			
			fixed4 frag(v2f_customrendertexture i) : COLOR
			{
				// sample the texture
			    float2 uv = i.globalTexcoord;
				fixed4 color = tex2D(_MainTex, i.localTexcoord.xy);
				fixed4 color1 = tex2D(_BackGround,i.localTexcoord.xy);
				color.rgb = dot(color.rgb, fixed3(.222,.707,.071));
				fixed4 Mixcolors；
				#if defined(_HaveColor_OFF)
				color1.rgb = dot(color1.rgb, fixed3(.222, .707, .071)) * 0.3;
				fixed alpha = 1 - color.r + color1.r;
                fixed rb = color1.r / alpha;
                Mixcolors = fixed4(rb, rb, rb, alpha);
                #endif
                 #if defined(_HaveColor_ON)
                fixed scale = 0.2;
				fixed alpha = dot(color1.rgb, fixed3(.222, .707, .071)) * scale;
                color1 = color1 * scale;
                fixed maxc = max(max(color1.r, color1.g), color1.b);
                alpha = max(1 - color.r + alpha, maxc);
                fixed r = color1.r / alpha;
                fixed g = color1.g / alpha;
                fixed b = color1.b / alpha;
                Mixcolors = fixed4(r, g, b, alpha);
                #endif
				//======================================
				fixed a = color.a;
				#if defined(_CLIPPING_ON)
				fixed r = color.r * a;
                fixed g = color.g * a;
                fixed b = color.b * a;
                return  fixed4(r, g, b, 1);
                #endif
                #if defined(_CLIPPING_OFF)
				fixed r = color.r * a + (1 - a);
				fixed g = color.g * a + (1 - a);
				fixed b = color.b * a + (1 - a);
				color = fixed4(r, g, b, 1);
				return color;
                #endif
                //======================================
			    return Mixcolors;
			}
			ENDCG
		}
	}
}
