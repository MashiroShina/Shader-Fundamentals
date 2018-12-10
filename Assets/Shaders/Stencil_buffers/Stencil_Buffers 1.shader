Shader "Custom/Stencil_Buffers1" {
	Properties{
		[IntRange] _StencilRef ("Stencil Reference Value", Range(0,255)) = 0
	}

	SubShader{
		//the material is completely non-transparent and is rendered at the same time as the other opaque geometry
		Tags{ "RenderType"="Opaque" "Queue"="Geometry-1"}//这里让他在小球绘制渲染前先绘制渲染

        //stencil operation
		Stencil{
			Ref [_StencilRef]
			Comp Always
			Pass Replace
		}

		Pass{
            //don't draw color or depth
			Blend Zero One//透明
			ZWrite OFF//这样就不会遮挡物体

			CGPROGRAM
			#include "UnityCG.cginc"

			#pragma vertex vert
			#pragma fragment frag

			struct appdata{
				float4 vertex : POSITION;
			};

			struct v2f{
				float4 position : SV_POSITION;
			};

			v2f vert(appdata v){
				v2f o;
				//calculate the position in clip space to render the object
				o.position = UnityObjectToClipPos(v.vertex);
				return o;
			}

			fixed4 frag(v2f i) : SV_TARGET{
				return fixed4(0,0,1,1);
			}

			ENDCG
		}
	}
}
