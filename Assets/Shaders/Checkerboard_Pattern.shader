Shader "Unlit/Checkerboard_Pattern"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
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
				float4 vertex : SV_POSITION;
				float3 worldPos : TEXCOORD0;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				//o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				//UNITY_TRANSFER_FOG(o,o.vertex);
				o.worldPos=mul(unity_ObjectToWorld,v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				//add different dimensions 
                float chessboard = floor(i.worldPos.x)+floor(i.worldPos.y)+floor(i.worldPos.z);//get int 
                //divide it by 2 and get the fractional part, resulting in a value of 0 for even and 0.5 for odd numbers.
                chessboard = frac(chessboard * 0.5);//so now the even numbers are all 0
                //multiply it by 2 to make odd values white instead of grey
                 chessboard *= 2;
                return chessboard;
			}
			ENDCG
		}
	}
}
