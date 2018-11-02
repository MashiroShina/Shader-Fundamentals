// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/My First Shader"
{
	Properties {
	_Tint ("Tint", Color) = (1, 1, 1, 1)
	}
	SubShader{
		Pass{
		CGPROGRAM
		#pragma vertex MyVertexProgram
		#pragma fragment MyFragmentProgram
		#include "UnityCG.cginc"
		float4 _Tint;

		struct Interpolators {
		float4 position:SV_POSITION;
		float2 uv : TEXCOORD0;
		};
		struct VertexData {
		float4 position : POSITION;
		float2 uv : TEXCOORD0;
		};
		Interpolators MyVertexProgram(VertexData v)
		{
		Interpolators i;
		i.position = UnityObjectToClipPos(v.position);
		i.uv=v.uv;
		return i;
		}
		float4 MyFragmentProgram(Interpolators i):SV_TARGET
		{
		return float4(i.uv,1,1);
		//return float4(i.localPosition+0.5,1);////Because negative colors get clamped to zero, our sphere ends up rather dark. As the default sphere has an object-space radius of ½, the color channels end up somewhere between −½ and ½. We want to move them into the 0–1 range, which we can do by adding ½ to all channels.
		}
		
		ENDCG
		}
	
	}
}
