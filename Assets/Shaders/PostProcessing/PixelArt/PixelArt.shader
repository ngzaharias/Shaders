Shader "Custom/PixelArt" 
{
	Properties 
	{
		[HideInInspector]_MainTex ("", 2D) = "white" {}
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
				float4 pos : POSITION;
				half2 uv : TEXCOORD0;
			};

			sampler2D _MainTex;
   
			v2f vert (appdata_img IN)
			{
				v2f OUT;
				OUT.pos = mul (UNITY_MATRIX_MVP, IN.vertex);
				OUT.uv = MultiplyUV (UNITY_MATRIX_TEXTURE0, IN.texcoord.xy);
				return OUT; 
			}
    
			fixed4 frag (v2f IN) : COLOR
			{
				half2 uv = IN.uv - fmod(IN.uv, 0.005);
				return tex2D(_MainTex, uv);
			}
			ENDCG
		}
	} 
	FallBack "Diffuse"
}
