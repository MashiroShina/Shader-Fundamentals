Shader "Custom/Postprocessing_via_Outlines" {
	Properties {
		[HideInInspector]_MainTex ("Texture", 2D) = "white" {}
        
        _OutlineColor ("Outline Color", Color) = (0,0,0,1)
        _NormalMult ("Normal Outline Multiplier", Range(0,4)) = 1
        _NormalBias ("Normal Outline Bias", Range(1,4)) = 1
        _DepthMult ("Depth Outline Multiplier", Range(0,4)) = 1
        _DepthBias ("Depth Outline Bias", Range(1,4)) = 1
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
            float4 _OutlineColor;
            float _NormalMult;
            float _NormalBias;
            float _DepthMult;
            float _DepthBias;
        float4 _CameraDepthNormalsTexture_TexelSize;//=Vector4(1 / width, 1 / height, width, height)
     
        
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
            float4x4 _viewToWorld;
            float Compare(float baseDepth, float2 uv, float2 offset){
            
                 
                float4 neighborDepthnormal = tex2D(_CameraDepthNormalsTexture, 
                uv + _CameraDepthNormalsTexture_TexelSize.xy * offset);//当前的uv+当前像素*偏移得到 当前uv上面的值也就是当前值附近的值
                
                float3 neighborNormal;
                float neighborDepth;
                DecodeDepthNormal(neighborDepthnormal, neighborDepth, neighborNormal);//得到附近值了后我们拿到他的深度信息和法线
                //我们必须通过到远裁剪平面的距离来缩放这个值，以获得实际的基于深度的视图距离。
                neighborDepth = neighborDepth * _ProjectionParams.z;
               
             //我们的outline就相当于当前的图像 - 放大后的图像= 外面一圈的值  
             float4 difference=baseDepth-neighborDepth;
             
             return difference;
            }
            void Compare2(inout float depthOutline, inout float normalOutline, 
                        float baseDepth, float3 baseNormal, float2 uv, float2 offset)
            {
                float4 neighborDepthnormal = tex2D(_CameraDepthNormalsTexture, 
                uv + _CameraDepthNormalsTexture_TexelSize.xy * offset);//当前的uv+当前像素*偏移得到 当前uv上面的值也就是当前值附近的值
                
                float3 neighborNormal;
                float neighborDepth;
                DecodeDepthNormal(neighborDepthnormal, neighborDepth, neighborNormal);//得到附近值了后我们拿到他的深度信息和法线
                //我们必须通过到远裁剪平面的距离来缩放这个值，以获得实际的基于深度的视图距离。
                neighborDepth = neighborDepth * _ProjectionParams.z;
                
                float difference=baseDepth-neighborDepth;
                depthOutline=depthOutline+difference;
                
                float3 normalDifference = baseNormal - neighborNormal;
                normalDifference = normalDifference.r + normalDifference.g + normalDifference.b;
                normalOutline = normalOutline + normalDifference;
            }
            
            //depth=0是黑色.1是白色
            fixed4 frag(v2f i) : SV_TARGET
            {
           //read depthnormal
            float4 depthnormal = tex2D(_CameraDepthNormalsTexture, i.uv);
        
            //decode depthnormal
            float3 normal;
            float depth;
            DecodeDepthNormal(depthnormal, depth, normal);
        
            //get depth as distance from camera in units 
            depth = depth * _ProjectionParams.z;//当前的深度
            
//            float depthDifference = Compare(depth, i.uv, float2(1, 0));//左下上右 得到左边
//            depthDifference = depthDifference + Compare(depth, i.uv, float2(0, 1));//左边+下边以此类推
//            depthDifference = depthDifference + Compare(depth, i.uv, float2(0, -1));
//            depthDifference = depthDifference + Compare(depth, i.uv, float2(-1, 0));
//            depthDifference = depthDifference + Compare(depth, i.uv, float2(1, 1));
//            depthDifference = depthDifference + Compare(depth, i.uv, float2(-1, -1));
//            depthDifference = depthDifference + Compare(depth, i.uv, float2(1, -1));
//            depthDifference = depthDifference + Compare(depth, i.uv, float2(-1, 1));
 
 
            float depthDifference = 0;
            float normalDifference = 0;
            
            Compare2(depthDifference, normalDifference, depth, normal, i.uv, float2(1, 0));
            Compare2(depthDifference, normalDifference, depth, normal, i.uv, float2(0, 1));
            Compare2(depthDifference, normalDifference, depth, normal, i.uv, float2(0, -1));
            Compare2(depthDifference, normalDifference, depth, normal, i.uv, float2(-1, 0));
            
                depthDifference = depthDifference * _DepthMult;
                depthDifference = saturate(depthDifference);// 把输入值限制到[0, 1]之间。
                depthDifference = pow(depthDifference, _DepthBias);//Returns xy.

                normalDifference = normalDifference * _NormalMult;
                normalDifference = saturate(normalDifference);
                normalDifference = pow(normalDifference, _NormalBias);
            
             float4 source = tex2D(_MainTex, i.uv);//uv表示这个纹理的这个部分显示在网格的这个部分
             float4 col=lerp(source,_OutlineColor,depthDifference+normalDifference);
             return col;
            return depthDifference+normalDifference;
            }
		ENDCG
		}
	}
}
