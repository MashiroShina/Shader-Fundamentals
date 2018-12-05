Shader "Unlit/Polygon_Clipping"
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
			uniform float2 _corners[1000];
            uniform uint _cornerCount;
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
				float4 position : SV_POSITION;
				float3 worldPos : TEXCOORD1;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.position = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				float4 worldPos=mul(unity_ObjectToWorld,v.vertex);
				o.worldPos=worldPos.xyz;
				//UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			float isLeftOfLine(float2 pos, float2 linePoint1, float2 linePoint2){
                //variables we need for our calculations
                float2 lineDirection = linePoint2 - linePoint1;
                float2 lineNormal = float2(-lineDirection.y, lineDirection.x);
                float2 toPos = pos - linePoint1;
            
                //which side the tested position is on
                float side = dot(toPos, lineNormal);
                side = step(0, side);//side>0?1:0
                return side;
            }

			fixed4 frag (v2f i) : SV_Target
			{
				float2 linePoint1 = float2(-1, 0);
                float2 linePoint2 = float2(1, 1);
                float2 linePoint3 = float2(1, -1);
                   float outsideTriangle = isLeftOfLine(i.worldPos.xy, linePoint1, linePoint2);
                outsideTriangle = outsideTriangle + isLeftOfLine(i.worldPos.xy, linePoint2, linePoint3);
                outsideTriangle = outsideTriangle + isLeftOfLine(i.worldPos.xy, linePoint3, linePoint1);
                return outsideTriangle;
			}
			ENDCG
		}
	}
}
