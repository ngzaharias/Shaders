Shader "Custom/Ascii" 
{
	Properties 
	{
		[HideInInspector]_MainTex ("", 2D) = "white" {}
		_CharTex ("Character Texture", 2D) = "white" {}
		_CharLayout ("Character Layout in Texture", Vector) = (1, 1, 0, 0)
		_CharScreen ("Screen Size in Characters", Vector) = (16, 9, 0, 0)
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

			float2 _CharLayout;
			float2 _CharScreen;
			sampler2D _MainTex;
			sampler2D _CharTex;
			
			v2f vert (appdata_img IN)
			{
				v2f OUT;
				OUT.worldPos = mul (UNITY_MATRIX_MVP, IN.vertex);
				OUT.screenPos = ComputeScreenPos(IN.vertex);
				OUT.uv = MultiplyUV (UNITY_MATRIX_TEXTURE0, IN.texcoord.xy);
				return OUT; 
			}

			//	truncate floating point numbers
			half2 pixelise(half2 size, half2 uv)
			{
				size.x = 1.0f/size.x;
				size.y = 1.0f/size.y;
				return half2((int)(uv.x / size.x) * size.x, (int)(uv.y / size.y) * size.y);
			}

			fixed3 frag (v2f IN) : COLOR
			{
				half textureCount = _CharLayout.x * _CharLayout.y - 1;
				half2 charUVSpacing = 1.0f / _CharLayout;

				// adjust the uv and sample the main texture
				half2 mainUV = pixelise(_CharScreen, IN.uv);
				fixed3 mainColour =  tex2D(_MainTex, mainUV);

				// brightness of the pixel
				half brightness = (mainColour.r + mainColour.g + mainColour.b) / 3.0f;
				brightness = floor(brightness * textureCount);

				// determine which character to use
				half2 charUV = IN.uv * _CharScreen / _CharLayout;
				charUV = (charUV % charUVSpacing) + (charUVSpacing * brightness);

				// sample the charTex and multiply the our colour against it
				// if we sampled something in the charTex then it will output colour
				fixed3 charColour = tex2D(_CharTex, charUV);
				return mainColour * charColour.r;
			}
			ENDCG
		}
	} 
	FallBack "Diffuse"
}
