Shader "Unlit/Blend_Color"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color ("Color", Color) = (0, 0, 0, 1) //the base color
		_SecondaryColor ("Secondary Color", Color) = (1,1,1,1) //the color to blend to
		_Blend ("Blend Value", Range(0,1)) = 0 //0 is the first color, 1 the second
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			float _Blend;

            //the colors to blend between
            fixed4 _Color;
            fixed4 _SecondaryColor;
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				//col =_Color*(1-_Blend)+_SecondaryColor*_Blend;
				col=lerp(_Color, _SecondaryColor, _Blend);
				return col;
			}
			ENDCG
		}
	}
}
