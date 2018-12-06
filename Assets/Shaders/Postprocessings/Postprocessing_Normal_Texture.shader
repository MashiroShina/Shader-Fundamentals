Shader "Custom/Postprocessing_Normal_Texture" {
	Properties {
		[HideInInspector]_MainTex ("Texture", 2D) = "white" {}
		_upCutoff ("up cutoff", Range(0,1)) = 0.7
        _topColor ("top color", Color) = (1,1,1,1)
	}
	SubShader {
		Cull Off
        ZWrite Off 
        ZTest Always
    Pass{
		CGPROGRAM
		#include "UnityCG.cginc"
		
		#pragma vertex vert
        #pragma fragment frag

		sampler2D _MainTex;
        sampler2D _CameraDepthNormalsTexture;
        float4x4 _viewToWorld;
        float4 _topColor;
        float _upCutoff;
        
		 struct appdata{
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };
        struct v2f{
                float4 position : SV_POSITION;
                float2 uv : TEXCOORD0;
            };
		 //the vertex shader
            v2f vert(appdata v){
                v2f o;
                //convert the vertex positions from object space to clip space so they can be rendered
                o.position = UnityObjectToClipPos(v.vertex);
                
                o.uv=v.uv;
                return o;
            }
            //float4 _CameraDepthNormalsTexture_TexelSize;
            //depth=0是黑色.1是白色
            fixed4 frag(v2f i) : SV_TARGET{
                //read depthnormal
             float4 depthnormal = tex2D(_CameraDepthNormalsTexture, i.uv);
             float3 normal;
             float depth;
             DecodeDepthNormal(depthnormal,depth,normal);
             depth=depth*_ProjectionParams.z;
             
             normal=mul((float3x3)_viewToWorld,normal);//原法线的坐标是相对相机储存，这里我们得到法线的世界坐标来解决.
             
             float up=dot(float3(0,1,0),normal);//得到只有0，1，-1的值
             up = step(_upCutoff, up);//只有黑白 up>0.5?1:0
             //float4 source=tex2D(_MainTex,i.uv);
             //float4 col=lerp(source,float4(1,1,1,1),up);
             //source*(1-up)+float4(1,1,1,1)*up
             //说白了，也就是一个混合公式，他们俗称插值， 只不过w相当于以第二个参数为源，第一个参数为目标。 直白点，就是把b向a上混合
              float4 source = tex2D(_MainTex, i.uv);//uv表示这个纹理的这个部分显示在网格的这个部分
              float4 col = lerp(source, _topColor, up * _topColor.a);
             return col;
                
            }
		ENDCG
		}
	}
}
