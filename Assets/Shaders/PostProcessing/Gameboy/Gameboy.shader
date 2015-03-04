Shader "Custom/Gameboy" 
{
	Properties 
	{
		[HideInInspector]_MainTex ("", 2D) = "white" {}
		_SampleTex ("Sample Texture", 2D) = "white" {}
		_PixelSize ("PixelSize", Vector) = (16, 16, 0, 0)
	}

	SubShader 
	{
		ZTest Always Cull Off ZWrite Off Fog { Mode Off }
 
		Pass
		{
			CGPROGRAM
			#include "UnityCG.cginc" 

			#pragma vertex vert
			#pragma fragment frag
    
			struct v2f 
			{
				float4 worldPos : POSITION;
				float4 screenPos : TEXCOORD1;

				half2 uv : TEXCOORD0;
			};

			float2 _PixelSize;
			sampler2D _MainTex;
			sampler2D _SampleTex;
			
			inline fixed lightness(fixed3 col)
			{
 				return (max(col.r, max(col.g, col.b)) + min(col.r, min(col.g, col.b))) * 0.5f;
			}

			inline fixed average(fixed3 col)
			{
				return (col.r + col. g + col.b) * 0.3333333333f;
			}

			inline fixed luminosity(fixed3 col)
			{
				return (col.r * 0.21f) + (col.g * 0.72f) + (col.b * 0.07f);
			}

			inline fixed2 downscaledUV(fixed2 fragCoord, fixed2 pixelSize)
			{
				return floor(fragCoord / pixelSize) * pixelSize / _ScreenParams;
			}

			v2f vert (appdata_img IN)
			{
				v2f OUT;
				OUT.worldPos = mul (UNITY_MATRIX_MVP, IN.vertex);
				OUT.screenPos = ComputeScreenPos(IN.vertex);
				OUT.uv = MultiplyUV (UNITY_MATRIX_TEXTURE0, IN.texcoord.xy);
				return OUT; 
			}

			fixed3 frag (v2f IN) : COLOR
			{
				fixed2 fragCoord = IN.uv * _ScreenParams.xy;

				// adjust the uv and sample the main texture
				fixed2 mainUV = downscaledUV(fragCoord, _PixelSize);
				fixed3 colour =  tex2D(_MainTex, mainUV);

				fixed gray = lightness(colour);
				return tex2D(_SampleTex, fixed2(gray, 0.5f));
			}
			ENDCG
		}
	} 
	FallBack "Diffuse"
}
