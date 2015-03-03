Shader "Custom/GalaxyField" 
{
	Properties 
	{
        _PlayerDir ("PlayerDirection", Vector) = (1,1,1)
    }

	SubShader 
	{
		Pass
		{
	
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		//---- Create a new Vertex function
		#pragma vertex vert
		//---- Create a new Fragment function
		#pragma fragment frag
		 #include "UnityCG.cginc"

		
		struct v2f 
		{
			float4 pos : SV_POSITION;
			float2 uv : TEXCOORD0;
		};

		float SCurve (float value) 
		{
			if (value < 0.5)
			{
				return value * value * value * value * value * 16.0; 
			}
			value -= 1.0;
			return value * value * value * value * value * 16.0 + 1.0;
		}
		
		v2f vert (appdata_base v)
		{
			v2f o;
			o.pos = mul (UNITY_MATRIX_MVP, v.vertex); // = Multiply MVP
			o.uv = v.texcoord; // Not sure how vital this one is, Probs could do o.uv = v.texcoord; yup works fine
			return o;
		}

		 half4 frag (v2f i) : COLOR
		 {
			half4 result;
			float iterations = 15.0f;
			float formuparam = 0.53;

			float volsteps = 10.0f;
			float stepsize = 0.1f;

			float zoom = 0.8f; // may not be used as this was used for player mouse pos etc
			float tile = 0.85f;
			float speed = 0.002f;
		
			float brightness = 0.002f;
			float darkmatter = 0.300f;
			float distfading = 0.750f;
			float saturation = 0.750f;

			// extended inputs // this kind of effects the zoom aswell
			float2 iResolution = (0.25,0.25);

			//get coords and direction
			float2 uv = i.uv / iResolution.xy - 0.5f;
			uv.y *= iResolution.y / iResolution.x;
			float3 dir = float3(uv * zoom, 1.0f);
			float time = _Time * speed + .25f;

			//mouse rotation
			//float a1=.5+400/iResolution.x*2.;
			//float a2=.8+400/iResolution.y*2.;
			//float2x2 rot1=float2x2(cos(a1),sin(a1),-sin(a1),cos(a1));
			//float2x2 rot2=float2x2(cos(a2),sin(a2),-sin(a2),cos(a2));
			//dir.xz*=rot1[1];
			//dir.xy*=rot2[0];

			//float3 from=float3(1.0f, 0.5f, 0.5f);
			//from+=float3(time*2.,time, -2.f);
			//from.xz*=rot1[1];
			//from.xy*=rot2[0];

			// this will change the appereance of movement
			float3 from = float3(1.0f, 0.5f, 0.5f);
			from += float3(0, 0, -2.f);

			// gives the apperence of moving forward
			from.xz *= -time * 0.5f;
			from.xy *= time * 5;
	
			//volumetric rendering
			float s = 0.1f, fade = 1.f;
			float3 v = float3(0.0f, 0.0f, 0.0f);
			for (int r = 0; r < volsteps; ++r) 
			{
				float3 p = from + s * dir * 0.5f;
				p = abs(float3(tile, tile, tile) - fmod(p, float3(tile * 2.0f, tile * 2.0f, tile * 2.0f))); // tiling fold
				float pa = 0.f;
				float a = 0;
				for (int i = 0; i < iterations; ++i) 
				{ 
					p = abs(p) / dot(p, p) - formuparam; // the magic formula
					a += abs(length(p) - pa); // absolute sum of average change
					pa = length(p);
				}

				float dm = max(0.0f, darkmatter - a * a * 0.001f); //dark matter
				a = pow(a, 2.5f); // add contrast
				if (r > 6) fade *= 1.0f - dm; // dark matter, don't render near
				//v+=float3(dm,dm*.5,0.);
				v += fade;
				v += float3(s, s * s ,s * s * s * s) * a * brightness * fade; // coloring based on distance
				fade *= distfading; // distance fading
				s += stepsize;
			}
    
			v = lerp(float3(length(v), length(v), length(v)), v, saturation); //color adjust
    
			float4 C = float4(v * 0.01f, 1.0f);
     			C.r = pow(C.r, 0.35f); 
 	 			C.g = pow(C.g, 0.36f); 
 	 			C.b = pow(C.b, 0.4f); 
 	
			float4 L = C;   	
    			C.r = lerp(L.r, SCurve(C.r), 1.0f); 
    			C.g = lerp(L.g, SCurve(C.g), 0.9f); 
    			C.b = lerp(L.b, SCurve(C.b), 0.6f);     

			result = C;
			
			return result;
		}
		
		ENDCG
		}
	} 
	FallBack "Diffuse"
}
