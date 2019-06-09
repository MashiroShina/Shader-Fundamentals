Shader "Unlit/ParticleBatch"
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
			#pragma target 5.0
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
				uint id : SV_VertexID;
                float2 uv : TEXCOORD0;
            };

			struct Particle
			{
				float3 pos;
				float3 vel;
				float3 acc;
			};

			#ifdef SHADER_API_D3D11
			uniform StructuredBuffer<Particle> _Buffer;
			#endif

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
				v2f o;
				uint index= v.id/24;
				uint vid=v.id%24;
				
				float3 wpos=0;
				float2 uv=0;

				wpos=_Buffer[index].pos;
				float3 ofs=0;
				if(vid==0||vid==8||vid==21)
					ofs=float3(-0.5,-0.5,0.5);
				else	if(vid==1||vid==12||vid==20)
					ofs=float3(0.5,-0.5,0.5);
				else	if(vid==2||vid==13||vid==16)
					ofs=float3(0.5,-0.5,-0.5);
				else	if(vid==3||vid==9||vid==17)
					ofs=float3(-0.5,-0.5,-0.5);

				else	if(vid==4||vid==11||vid==22)
					ofs=float3(-0.5,0.5,0.5);
				else	if(vid==5||vid==15||vid==23)
					ofs=float3(0.5,0.5,0.5);
				else	if(vid==6||vid==14||vid==19)
					ofs=float3(0.5,0.5,-0.5);
				else	if(vid==7||vid==10||vid==18)
					ofs=float3(-0.5,0.5,-0.5);
				
				uv=ofs.xz + float2(0.5,0.5);
				wpos+=ofs;
				

				o.vertex=UnityObjectToClipPos(float4(wpos,1));
				o.uv=TRANSFORM_TEX(uv,_MainTex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
