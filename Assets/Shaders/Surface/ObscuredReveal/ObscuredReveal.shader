Shader "Custom/ObscuredReveal" 
{
	Properties 
	{
		_MainTex ("Texture", 2D) = "white" {}
		_TranTex ("Transparent Overlay", 2D) = "bump" {}
	}
	SubShader 
	{
		Tags { "RenderType"="Opaque" }
		Cull Off
		
		CGPROGRAM
		#pragma surface surf Lambert 

		sampler2D _MainTex;
		sampler2D _TranTex;

		struct Input 
		{
			float2 uv_MainTex;
			float3 worldPos;
			float4 screenPos;
		};

		void surf(Input IN, inout SurfaceOutput o) 
		{
			// calculate the screenSpace UV
			float2 worldUV = IN.worldPos.xy / IN.screenPos.w;
			float2 screenUV = IN.screenPos.xy / IN.screenPos.w;
			half4 trans = tex2D(_TranTex, screenUV);
			//	* 2 - 1 adjusts it from '0 to 1' to '-1 to 1'
			half c = trans.r * trans.g * trans.b * trans.a;
			clip((c * 2) - 1);

			half4 colour = tex2D(_MainTex, IN.uv_MainTex);
			o.Albedo = colour.rgb;
			o.Alpha = colour.a;
		}
		ENDCG
	} 
	FallBack "Diffuse"
}
