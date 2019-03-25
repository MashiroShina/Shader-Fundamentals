Shader "Custom/Tank" {
	Properties
	{
		_Color ("Tint", Color) = (0, 0, 0, 1)
		_MainTex ("Texture", 2D) = "white" {}
		_BackGround ("BackGround", 2D) = "white" {}
		[KeywordEnum(OFF,ON,NULL)] _CLIPPING ("_CLIPPING", Float) = 0
		[KeywordEnum(OFF,ON,NULL)] _HAVECOLOR ("_HAVECOLOR", Float) = 0
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
			#pragma shader_feature _CLIPPING_NULL
			
			#pragma shader_feature _HAVECOLOR_ON
			#pragma shader_feature _HAVECOLOR_OFF
			#pragma shader_feature _HAVECOLOR_NULL
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
				fixed4 Mixcolors;
				#if defined(_CLIPPING_NULL)
				#if defined(_HAVECOLOR_OFF)
				color1.rgb = dot(color1.rgb, fixed3(.222, .707, .071)) * 0.3;
				color.rgb = dot(color.rgb, fixed3(.222,.707,.071));
				fixed alpha = 1 - color.r + color1.r;
                fixed rb = color1.r / alpha;
                Mixcolors = fixed4(rb, rb, rb, alpha);
                return Mixcolors;
                #endif
                
                #if defined(_HAVECOLOR_ON)
                fixed scale = 0.2;
				fixed alpha = dot(color1.rgb, fixed3(.222, .707, .071)) * scale;
                color1 = color1 * scale;
                fixed maxc = max(max(color1.r, color1.g), color1.b);
                alpha = max(1 - color.r + alpha, maxc);
                fixed r1 = color1.r / alpha;
                fixed g1 = color1.g / alpha;
                fixed b1 = color1.b / alpha;
                Mixcolors = fixed4(r1, g1, b1, alpha);
                return Mixcolors;
                #endif
                #endif
				//======================================
				#if defined(_HAVECOLOR_NULL)
				#if defined(_CLIPPING_ON)
				fixed a2 = color.a;
				fixed r2 = color.r * a2;
                fixed g2 = color.g * a2;
                fixed b2 = color.b * a2;
                return  fixed4(r2, g2, b2, 1);
                #endif
                #if defined(_CLIPPING_OFF)
                fixed a3 = color.a;
				fixed r3 = color.r * a3 + (1 - a3);
				fixed g3 = color.g * a3 + (1 - a3);
				fixed b3 = color.b * a3 + (1 - a3);
				color = fixed4(r3, g3, b3, 1);
				return color;
                #endif
                #endif
                //======================================
			    return (1,1,1,1);
			}
			ENDCG
		}
	}
}
