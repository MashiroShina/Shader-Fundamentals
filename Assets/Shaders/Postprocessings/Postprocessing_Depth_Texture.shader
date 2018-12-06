Shader "Custom/Postprocessing_Depth_Texture" {
	Properties {
		[HideInInspector]_MainTex ("Texture", 2D) = "white" {}
    [Header(Wave)]
    _WaveDistance ("Distance from player", float) = 10
    _WaveTrail ("Length of the trail", Range(0,5)) = 1
    _WaveColor ("Color", Color) = (1,0,0,1)
//		_CameraDepthTexture ("CameraDepthTexture", 2D) = "white" {}
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
        sampler2D _CameraDepthTexture;
        
        //variables to control the wave
        float _WaveDistance;
        float _WaveTrail;
        float4 _WaveColor;
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

            //depth=0是黑色.1是白色
            fixed4 frag(v2f i) : SV_TARGET{
                //get source color from texture
                float depth = tex2D(_CameraDepthTexture, i.uv).r;//
                
                depth = Linear01Depth(depth);
                depth = depth * _ProjectionParams.z;//z是远裁y是近裁，x=1
                 
                 //get source color
                fixed4 source = tex2D(_MainTex, i.uv);//clip空间屏幕uv采样
                //skip wave and return source color if we're at the skybox
                if(depth>_ProjectionParams.z){
                return source;
                }
                 
                float waveFront=step(depth,_WaveDistance);//_WaveDistance>depth?1:0//这里相当于颜色取反
                float waveTrail = smoothstep(_WaveDistance - _WaveTrail, _WaveDistance, depth);//smoothstep平滑操作
                 //假设这里 参数为5，10，每个物体的Depth。 这样子则表示物体深度在5之前的完全显示值为0，然后在>5&&<10的部分差值 0.1,0.2,0.3这样。到了大于
                 //10的部分则返回1然后就不显示了.
                 //如果第三个值小于第一个值，则函数返回0，如果它大于第二个返回1，其他值返回0到1之间的值
                 //  smoothstep(edge0, edge1, x): threshod  smooth transition时使用。 x<=edge0时为0.0， x>=edge1时为1.0
                //return waveTrail;
                float wave = waveFront * waveTrail;//假设深度在9.5的时候waveFront=1，而waveTrail=0.5//所以只会有中间一部分拖尾的地方是白色
                 
                fixed4 col = lerp(source, _WaveColor, wave);
                //source*(1-wave)+_WaveColor*wave
                //source*(1-wave)=把wave混合到source上部分,_WaveColor*wave让wave混合颜色，然后在两者混合一起
                //lerp说白了，也就是一个混合公式，他们俗称插值， 只不过w相当于以第二个参数为源，第一个参数为目标。 直白点，就是把b向a上混合
                
                return col;
                //return wave;
                
            }
		ENDCG
		}
	}
}
