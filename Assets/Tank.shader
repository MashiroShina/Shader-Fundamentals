Shader "Custom/Tank" {
	Properties
	{
		_Color ("Tint", Color) = (0, 0, 0, 1)
		_MainTex ("Texture", 2D) = "white" {}
		_BackGround ("BackGround", 2D) = "white" {}
		_Alpha ("_Alpha", Range(0,1) ) = 0
		[KeywordEnum(OFF,ON,NULL)] _CLIPPING ("Alpha BlackGround", Float) = 0
	}
	SubShader
	{
		Tags{ "RenderType"="Transparent" "Queue"="Transparent"}
		
		Blend SrcAlpha OneMinusSrcAlpha
		ZWrite off

		Pass
		{
			CGPROGRAM
			#include "UnityCG.cginc"
			#pragma vertex vert
			#pragma fragment frag
			
			#pragma shader_feature _CLIPPING_ON
			#pragma shader_feature _CLIPPING_OFF
            sampler2D _MainTex;
            sampler2D _BackGround;
			float4 _MainTex_ST;
			float4 _BackGround_ST;
            half _Alpha;
			fixed4 _Color;
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 position : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.position = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : COLOR
			{
				// sample the texture
				fixed4 color = tex2D(_MainTex, i.uv);
				fixed4 color1 = tex2D(_BackGround, i.uv);
				color.rgb = dot(color.rgb, fixed3(.222,.707,.071));
				color1.rgb = dot(color1.rgb, fixed3(.222, .707, .071)) * 0.3;
				
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
                
			    fixed alpha = 1 - color.r + color1.r;
                fixed r = color1.r / alpha;
                fixed4 Mixcolors = fixed4(r, r, r, alpha);
			    return Mixcolors;
			}
			ENDCG
		}
	}
}
