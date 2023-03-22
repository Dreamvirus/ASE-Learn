// Made with Amplify Shader Editor v1.9.1
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Dindianpianyi"
{
	Properties
	{
		_MainTex("MainTex", 2D) = "white" {}
		[HDR]_MainColor("MainColor", Color) = (0,0,0,0)
		_SubColor("SubColor", Color) = (0,0,0,0)
		_NoiseTex("NoiseTex", 2D) = "white" {}
		_Blur("Blur", 2D) = "white" {}
		_NoiseYSpeed("NoiseYSpeed", Float) = 1
		_NoiseXSpeed("NoiseXSpeed", Float) = 1
		_Height("Height", Float) = -0.8
		_LineSpeed("LineSpeed", Vector) = (0,1,0,0)
		_Height2("Height2", Range( 0 , 3)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }
	LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend SrcAlpha OneMinusSrcAlpha
		AlphaToMask Off
		Cull Back
		ColorMask RGBA
		ZWrite On
		ZTest LEqual
		Offset 0 , 0
		
		
		
		Pass
		{
			Name "Unlit"

			CGPROGRAM

			

			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#include "UnityShaderVariables.cginc"
			#define ASE_NEEDS_VERT_COLOR


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
				#endif
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform sampler2D _NoiseTex;
			uniform float _NoiseXSpeed;
			uniform float _NoiseYSpeed;
			uniform float4 _NoiseTex_ST;
			uniform float _Height2;
			uniform sampler2D _Blur;
			uniform float2 _LineSpeed;
			uniform float4 _Blur_ST;
			uniform float _Height;
			uniform float4 _SubColor;
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform float4 _MainColor;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float2 appendResult13 = (float2(_NoiseXSpeed , _NoiseYSpeed));
				float2 uv_NoiseTex = v.ase_texcoord.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
				float2 panner10 = ( 1.0 * _Time.y * appendResult13 + uv_NoiseTex);
				float2 uv_Blur = v.ase_texcoord.xy * _Blur_ST.xy + _Blur_ST.zw;
				float2 panner17 = ( _SinTime.w * _LineSpeed + uv_Blur);
				float4 appendResult23 = (float4(0.0 , 0.0 , ( v.color.a * ( ( (0.0 + (tex2Dlod( _NoiseTex, float4( panner10, 0, 0.0) ).r - 0.0) * (_Height2 - 0.0) / (1.0 - 0.0)) * tex2Dlod( _Blur, float4( panner17, 0, 0.0) ).r ) + _Height ) ) , 0.0));
				
				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				o.ase_color = v.color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = appendResult23.xyz;
				#if ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif
				o.vertex = UnityObjectToClipPos(v.vertex);

				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				#endif
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 WorldPosition = i.worldPos;
				#endif
				float2 uv_MainTex = i.ase_texcoord1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode1 = tex2D( _MainTex, uv_MainTex );
				float4 lerpResult4 = lerp( _SubColor , ( tex2DNode1.r * _MainColor ) , tex2DNode1.r);
				float4 appendResult6 = (float4(lerpResult4.rgb , i.ase_color.a));
				
				
				finalColor = appendResult6;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	Fallback Off
}
/*ASEBEGIN
Version=19100
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;3;-9.042686,-110.1842;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;2;-381.9153,78.01105;Inherit;False;Property;_MainColor;MainColor;1;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,0;2.635294,6.02353,14.24314,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;5;-114.5728,234.5473;Inherit;False;Property;_SubColor;SubColor;2;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.02168029,0.2070099,0.2735847,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;4;202.0175,-50.38376;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;6;544.9902,25.24613;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.VertexColorNode;7;194.5375,252.5797;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;936.6368,26.47518;Float;False;True;-1;2;ASEMaterialInspector;100;5;Dindianpianyi;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;True;2;5;False;;10;False;;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;2;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.SamplerNode;1;-413.6,-166.3;Inherit;True;Property;_MainTex;MainTex;0;0;Create;True;0;0;0;False;0;False;-1;f281ef8958649144fb0c098392bbddf3;f281ef8958649144fb0c098392bbddf3;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;23;881.1865,477.8788;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;9;-252.0278,480.5727;Inherit;True;Property;_NoiseTex;NoiseTex;3;0;Create;True;0;0;0;False;0;False;-1;5f711da73a2df4f4abf6602847717665;5f711da73a2df4f4abf6602847717665;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;8;-759.1035,467.7777;Inherit;False;0;9;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;13;-638.1532,657.4611;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;10;-486.1597,479.8927;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;604.9585,519.2755;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-840.1801,622.7573;Inherit;False;Property;_NoiseXSpeed;NoiseXSpeed;6;0;Create;True;0;0;0;False;0;False;1;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;12;-880.179,731.2329;Inherit;False;Property;_NoiseYSpeed;NoiseYSpeed;5;0;Create;True;0;0;0;False;0;False;1;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;16;-763.6549,994.5757;Inherit;False;0;14;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;14;-233.6716,979.1875;Inherit;True;Property;_Blur;Blur;4;0;Create;True;0;0;0;False;0;False;-1;17833f419993b864282ef3d25d400045;17833f419993b864282ef3d25d400045;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;17;-498.532,1001.373;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SinTimeNode;19;-756.0818,1303.981;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;18;-748.358,1150.535;Inherit;False;Property;_LineSpeed;LineSpeed;8;0;Create;True;0;0;0;False;0;False;0,1;0,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;21;162.3906,973.7859;Inherit;False;Property;_Height;Height;7;0;Create;True;0;0;0;False;0;False;-0.8;-0.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;20;457.8868,806.8922;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;24;80.03443,540.2203;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;245.0556,682.5936;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-268.1823,727.6385;Inherit;False;Property;_Height2;Height2;9;0;Create;True;0;0;0;False;0;False;0;1;0;3;0;1;FLOAT;0
WireConnection;3;0;1;1
WireConnection;3;1;2;0
WireConnection;4;0;5;0
WireConnection;4;1;3;0
WireConnection;4;2;1;1
WireConnection;6;0;4;0
WireConnection;6;3;7;4
WireConnection;0;0;6;0
WireConnection;0;1;23;0
WireConnection;23;2;22;0
WireConnection;9;1;10;0
WireConnection;13;0;11;0
WireConnection;13;1;12;0
WireConnection;10;0;8;0
WireConnection;10;2;13;0
WireConnection;22;0;7;4
WireConnection;22;1;20;0
WireConnection;14;1;17;0
WireConnection;17;0;16;0
WireConnection;17;2;18;0
WireConnection;17;1;19;4
WireConnection;20;0;15;0
WireConnection;20;1;21;0
WireConnection;24;0;9;1
WireConnection;24;4;25;0
WireConnection;15;0;24;0
WireConnection;15;1;14;1
ASEEND*/
//CHKSM=C05E673AAC4F90C453EB38432266C3D4D72350ED