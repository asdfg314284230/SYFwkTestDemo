// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "zzplayer/YUVTexture"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_YuvYTex("_YuvYTex", 2D) = "white" {}
		_YuvUTex("_YuvUTex", 2D) = "white" {}
		_YuvVTex("_YuvVTex", 2D) = "white" {}

	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always
		Tags
		{ 
			"Queue"="Transparent" 
			//"IgnoreProjector"="True" 
			//"RenderType"="Transparent" 
			//"PreviewType"="Plane"
			//"CanUseSpriteAtlas"="True"
		}
		
		//Stencil
		//{
		//	Ref [_Stencil]
		//	Comp [_StencilComp]
		//	Pass [_StencilOp] 
		//	ReadMask [_StencilReadMask]
		//	WriteMask [_StencilWriteMask]
		//}

		//Cull Off
		//Lighting Off
		//ZWrite Off
		//ZTest [unity_GUIZTestMode]
		//////Blend SrcAlpha OneMinusSrcAlpha
		////ColorMask [_ColorMask]
		//ColorMask RGB

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				//o.vertex = UnityObjectToClipPos(v.vertex);
				o.vertex = UnityObjectToClipPos(v.vertex);
				//o.uv = float2(v.uv.x, 1 - v.uv.y); //v.uv;
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _MainTex;
			sampler2D _YuvYTex;
			sampler2D _YuvUTex;
			sampler2D _YuvVTex;
			fixed4 frag (v2f i) : SV_Target
			{
				//	fixed4 col = tex2D(_YuvYTex, i.uv);
					//fixed4 col = tex2D(_YuvYTex, float2(1, 1));
					//col.r = col.a;
				//col.r = 0;
				//col.g = 0;
				//col.b = 0;
					// just invert the colors
					//col = 1 - col;
					//col = fixed4(0, 1, 1, 1);
					fixed3 yuv;
					fixed3 rgb;

					yuv.x = tex2D(_YuvYTex, i.uv).r;
					yuv.y = tex2D(_YuvUTex, i.uv).r - 0.5;
					yuv.z = tex2D(_YuvVTex, i.uv).r - 0.5;

					rgb = mul(float3x3(
						1, 0, 1.13983,
						1, -0.39465, -0.58060,
						1, 2.03211, 0), yuv);

					//rgb = mul(float3x3(1, 0, 1.57481,
					//	1, -0.18732, -0.46813,
					//	1, 1.8556, 0), yuv);

					return fixed4(rgb, 1);
					//return fixed4(1, 1, 1, 1)
			}

			//"  vec3 yuv;										 \n"
			//	"  vec3 rgb;										 \n"
			//	"  yuv.x = texture2D(s_texture_y, v_texCoord).r;	\n"
			//	"  yuv.y = texture2D(s_texture_u, v_texCoord).r - 0.5;	\n"
			//	"  yuv.z = texture2D(s_texture_v, v_texCoord).r - 0.5;	\n"
			//	"  rgb = mat3(1, 1, 1,								\n"
			//	"	0, -0.39465, 2.03211,							\n"
			//	"	1.13983, -0.58060, 0) * yuv;					\n"
			//	"  gl_FragColor = vec4(rgb, 1);						\n"
			//	"}  
			//	return col;
			//}
			ENDCG
		}
	}
}
