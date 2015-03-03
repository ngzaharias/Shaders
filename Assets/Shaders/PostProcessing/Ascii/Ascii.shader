Shader "Custom/Ascii" 
{
	Properties 
	{
		[HideInInspector]_MainTex ("", 2D) = "white" {}
		_CharTex ("Character Texture", 2D) = "white" {}
		_CharLayout ("Character Layout in Texture", Vector) = (8, 1, 0, 0)
		_PixelSize ("Pixel Size", Vector) = (32, 32, 0, 0)
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
				half2 uv : TEXCOORD0;
			};

			fixed2 _CharLayout;
			fixed2 _PixelSize;
			sampler2D _MainTex;
			sampler2D _CharTex;
			
			float lightness(fixed3 col)
			{
 				return (max(col.r, max(col.g, col.b)) + min(col.r, min(col.g, col.b))) / 2.;
			}

			float average(fixed3 col)
			{
				return (col.r + col. g + col.b) / 3.;
			}

			float luminosity(fixed3 col)
			{
				return (col.r * 0.21f) + (col.g * 0.72f) + (col.b * 0.07f);
			}

			fixed2 downscaledUV(fixed2 fragCoord, fixed2 pixelSize)
			{
				return floor(fragCoord / pixelSize) * pixelSize / _ScreenParams;
			}

			fixed2 characterUV(fixed2 index, fixed2 fragCoord, fixed2 pixelSize, fixed2 charCount)
			{
				fixed2 charUVSpacing = 1.0f / _CharLayout;
				fixed2 uv = fmod(fragCoord / pixelSize, 1.0f) / charCount; 
				return uv + (index*charUVSpacing);
			}

			fixed2 characterIndex(float gray, fixed2 charLayout)
			{
				charLayout -= fixed2(1,1);
				return floor(gray * charLayout);
			}

			v2f vert (appdata_img IN)
			{
				v2f OUT;
				OUT.worldPos = mul (UNITY_MATRIX_MVP, IN.vertex);
				OUT.uv = MultiplyUV (UNITY_MATRIX_TEXTURE0, IN.texcoord.xy);
				return OUT; 
			}

			fixed3 frag (v2f IN) : COLOR
			{
				fixed2 fragCoord = IN.uv * _ScreenParams.xy;

				fixed2 mainUV = downscaledUV(fragCoord, _PixelSize);
				fixed3 colour = tex2D(_MainTex, mainUV);

				float gray = average(colour);
				fixed2 index = characterIndex(gray, _CharLayout);

				half2 charUV = characterUV(index, fragCoord, _PixelSize, _CharLayout);

				return tex2D(_CharTex, charUV) * colour;
			}
			ENDCG
		}
	} 
	FallBack "Diffuse"
}
