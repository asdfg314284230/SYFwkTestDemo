// This is a premultiply-alpha adaptation of the built-in Unity shader "UI/Default" in Unity 5.6.2 to allow Unity UI stencil masking.

Shader "Spine/SpineGhost"
{
	Properties
	{
		[NoScaleOffset] _MainTex ("Main Texture", 2D) = "black" {}
		_Color ("Color", Color) = (1,1,1,1)
		
		_StencilComp ("Stencil Comparison", Float) = 8
		_Stencil ("Stencil ID", Float) = 0
		_StencilOp ("Stencil Operation", Float) = 0
		_StencilWriteMask ("Stencil Write Mask", Float) = 255
		_StencilReadMask ("Stencil Read Mask", Float) = 255

		_ColorMask ("Color Mask", Float) = 15
		_Cutoff ("Shadow alpha cutoff", Range(0,1)) = 0.1

	}

	SubShader
	{
		Tags
		{ 
			"Queue"="Transparent" 
			"IgnoreProjector"="True" 
			"RenderType"="Transparent" 
			"PreviewType"="Plane"
			"CanUseSpriteAtlas"="True"
		}
		
		Stencil
		{
			Ref [_Stencil]
			Comp [_StencilComp]
			Pass [_StencilOp] 
			ReadMask [_StencilReadMask]
			WriteMask [_StencilWriteMask]
		}

		Cull Off
		Lighting Off
		ZWrite Off
		ZTest [unity_GUIZTestMode]
		Fog { Mode Off }
		Blend One OneMinusSrcAlpha
		ColorMask [_ColorMask]

		Pass
		{
		CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0

			#include "UnityCG.cginc"
			#include "UnityUI.cginc"

			#pragma multi_compile __ UNITY_UI_ALPHACLIP

			struct VertexInput {
				float4 vertex   : POSITION;
				float4 color    : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			struct VertexOutput {
				float4 vertex   : SV_POSITION;
				fixed4 color    : COLOR;
				half2 texcoord  : TEXCOORD0;
				float4 worldPosition : TEXCOORD1;
			};

			fixed4 _Color;
			float4 _ClipRect;
			fixed _Cutoff;

			VertexOutput vert (VertexInput IN) {
				VertexOutput OUT;


				OUT.worldPosition = IN.vertex;
				OUT.vertex = UnityObjectToClipPos(OUT.worldPosition);
				OUT.texcoord = IN.texcoord;


				OUT.color = _Color; // Combine a PMA version of _Color with vertexColor.
				return OUT;
			}

			sampler2D _MainTex;

			fixed4 frag (VertexOutput IN) : SV_Target
			{
				half4 color = tex2D(_MainTex, IN.texcoord) * IN.color;
				color.rgb = _Color.rgb;
				clip(color.a - _Cutoff);
				//color.a = IN.color.a;

				return color;
			}
		ENDCG
		}
	}
}