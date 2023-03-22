// Made with Amplify Shader Editor v1.9.1
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Card2-ASE"
{
	Properties
	{
		_MainTex("MainTex", 2D) = "white" {}
		_DissolveTex("DissolveTex", 2D) = "white" {}
		_Dissolve_P("Dissolve_P", Range( -0.1 , 1)) = 0
		_AddTex("AddTex", 2D) = "white" {}
		_AddIntensity("AddIntensity", Float) = 1
		[HDR]_AddColor("AddColor", Color) = (1,1,1,0)
		_EdgeTex("EdgeTex", 2D) = "white" {}
		_EdgeMask("EdgeMask", 2D) = "white" {}
		_EdgeMask_p("EdgeMask_p", Float) = 0
		_G_p("G_p", Float) = 0
		_EdgeIntensity("EdgeIntensity", Float) = 0
		[HDR]_EdgeColor("EdgeColor", Color) = (1,1,1,0)
		_G_Tex("G_Tex", 2D) = "white" {}
		_G_Intensity("G_Intensity", Float) = 0.1
		_MainIntensity("MainIntensity", Float) = 0
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
		Cull Off
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
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform sampler2D _AddTex;
			uniform float4 _AddTex_ST;
			uniform float4 _AddColor;
			uniform float _AddIntensity;
			uniform sampler2D _EdgeMask;
			uniform float _EdgeMask_p;
			uniform sampler2D _EdgeTex;
			uniform float4 _EdgeTex_ST;
			uniform float4 _EdgeColor;
			uniform float _EdgeIntensity;
			uniform sampler2D _G_Tex;
			uniform float _G_p;
			uniform float _G_Intensity;
			uniform float _MainIntensity;
			uniform sampler2D _DissolveTex;
			uniform float4 _DissolveTex_ST;
			uniform float _Dissolve_P;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = vertexValue;
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
				float2 uv_AddTex = i.ase_texcoord1.xy * _AddTex_ST.xy + _AddTex_ST.zw;
				float2 panner10 = ( 1.0 * _Time.y * float2( 0,0.2 ) + uv_AddTex);
				float4 temp_cast_0 = (0.0).xxxx;
				float4 AddColor37 = max( ( tex2D( _AddTex, panner10 ).r * _AddColor * _AddIntensity ) , temp_cast_0 );
				float2 texCoord24 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult28 = (float2(0.0 , _EdgeMask_p));
				float2 uv_EdgeTex = i.ase_texcoord1.xy * _EdgeTex_ST.xy + _EdgeTex_ST.zw;
				float temp_output_22_0 = ( tex2D( _EdgeMask, ( texCoord24 + appendResult28 ) ).r * tex2D( _EdgeTex, uv_EdgeTex ).r );
				float4 EdgeColor34 = ( temp_output_22_0 * _EdgeColor * _EdgeIntensity );
				float2 texCoord43 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult44 = (float2(0.0 , _G_p));
				float4 G_Color48 = ( tex2D( _G_Tex, ( texCoord43 + appendResult44 ) ).r * _EdgeColor * _G_Intensity );
				float2 uv_DissolveTex = i.ase_texcoord1.xy * _DissolveTex_ST.xy + _DissolveTex_ST.zw;
				float Dissolve39 = step( saturate( ( 1.0 - tex2D( _DissolveTex, uv_DissolveTex ).r ) ) , _Dissolve_P );
				float4 appendResult7 = (float4(( tex2DNode1 + AddColor37 + EdgeColor34 + G_Color48 + ( pow( tex2DNode1.r , 0.5 ) * tex2DNode1 * _MainIntensity ) ).rgb , saturate( ( temp_output_22_0 + ( tex2DNode1.a * Dissolve39 ) ) )));
				
				
				finalColor = appendResult7;
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
Node;AmplifyShaderEditor.CommentaryNode;41;-789.0334,145.717;Inherit;False;1156.35;404.699;Comment;6;39;2;5;6;4;3;Dissovle;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;36;-3035.418,-992.3221;Inherit;False;2049.381;854.7931;Comment;12;34;26;30;29;31;27;22;28;24;25;23;21;EdgeColor;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;20;-2552.43,-59.25439;Inherit;False;1567.055;660.8401;Comment;9;10;13;12;9;16;17;15;14;37;AddColor;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;9;-2502.43,-9.254395;Inherit;False;0;12;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;21;-2245.333,-653.8509;Inherit;True;Property;_EdgeTex;EdgeTex;6;0;Create;True;0;0;0;False;0;False;-1;7b64d0bb4c0acd64fb5701483ee2b691;7b64d0bb4c0acd64fb5701483ee2b691;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;23;-2225.836,-874.081;Inherit;True;Property;_EdgeMask;EdgeMask;7;0;Create;True;0;0;0;False;0;False;-1;223c5d6922667bd47be226017aae3261;223c5d6922667bd47be226017aae3261;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;-1773.456,-748.9572;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;30;-1812.073,-477.249;Inherit;False;Property;_EdgeColor;EdgeColor;11;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,0;23.38894,6.457777,3.177364,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;10;-2209.706,-0.3703928;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0.2;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;12;-1915.094,-14.96097;Inherit;True;Property;_AddTex;AddTex;3;0;Create;True;0;0;0;False;0;False;-1;ce5dee1d50c3a8141b120eab424bcaa2;ce5dee1d50c3a8141b120eab424bcaa2;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;14;-1859.456,263.1195;Inherit;False;Property;_AddColor;AddColor;5;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,0;1.788235,0.5019608,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;13;-1501.555,24.1271;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-1496.754,167.4638;Inherit;False;Constant;_Float0;Float 0;4;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;16;-1346.329,23.80052;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;37;-1182.821,21.3528;Inherit;False;AddColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-770.9424,467.6419;Inherit;False;Property;_Dissolve_P;Dissolve_P;2;0;Create;True;0;0;0;False;0;False;0;-0.1;-0.1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;39;162.9082,229.0143;Inherit;False;Dissolve;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;7;383.5556,-809.1429;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;613.7948,-808.6578;Float;False;True;-1;2;ASEMaterialInspector;100;5;Card2-ASE;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;True;2;5;False;;10;False;;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;True;True;2;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;2;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;19;-23.17613,-468.4493;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;2;-155.8382,216.1084;Inherit;True;Property;_DissolveTex;DissolveTex;1;0;Create;True;0;0;0;False;0;False;-1;ab978986b78b95248814a7257e0147cd;ab978986b78b95248814a7257e0147cd;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;3;-735.9768,235.4635;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;4;-528.5696,233.7206;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;5;-376.5368,237.4121;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;33;-1874.189,-1715.678;Inherit;True;Property;_G_Tex;G_Tex;12;0;Create;True;0;0;0;False;0;False;-1;7a7fb69be64fdbc43966bb7364699b2e;7a7fb69be64fdbc43966bb7364699b2e;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;25;-2543.23,-817.5332;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;24;-2869.747,-892.3221;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;28;-2732.94,-684.3738;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;27;-2935.417,-597.7791;Inherit;False;Property;_EdgeMask_p;EdgeMask_p;8;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-2935.418,-686.1981;Inherit;False;Constant;_Float1;Float 1;8;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;42;-2110.202,-1684.755;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;43;-2436.719,-1759.544;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;44;-2299.912,-1551.596;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;46;-2502.39,-1553.42;Inherit;False;Constant;_Float2;Float 1;8;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;47;-1448.563,-1600.806;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;45;-2554.389,-1466.546;Inherit;False;Property;_G_p;G_p;9;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;50;-1769.122,-1416.222;Inherit;False;Property;_G_Intensity;G_Intensity;13;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;18;167.7658,-809.3297;Inherit;False;5;5;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;1;-724.7311,-958.1;Inherit;True;Property;_MainTex;MainTex;0;0;Create;True;0;0;0;False;0;False;-1;5d86dc39788292b4dbf88268526f74d6;5d86dc39788292b4dbf88268526f74d6;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;35;-262.6848,-1085.288;Inherit;False;34;EdgeColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;38;-268.0467,-1214.458;Inherit;False;37;AddColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;49;-245.8932,-989.0042;Inherit;False;48;G_Color;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;53;-371.924,-636.4976;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;51;-716.7321,-669.5719;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;54;-672.1015,-423.9878;Inherit;False;Property;_MainIntensity;MainIntensity;14;0;Create;True;0;0;0;False;0;False;0;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;48;-1275.487,-1610.997;Inherit;False;G_Color;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-1848.922,469.5241;Inherit;False;Property;_AddIntensity;AddIntensity;4;0;Create;True;0;0;0;False;0;False;1;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;40;-227.8665,-444.6786;Inherit;False;39;Dissolve;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;55;181.6115,-541.9061;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;56;350.9125,-514.6972;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;31;-1798.369,-252.929;Inherit;False;Property;_EdgeIntensity;EdgeIntensity;10;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;52;-947.4008,-735.254;Inherit;False;Constant;_Float3;Float 3;14;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;34;-1207.406,-621.0486;Inherit;False;EdgeColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;-1426.625,-622.5769;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
WireConnection;23;1;25;0
WireConnection;22;0;23;1
WireConnection;22;1;21;1
WireConnection;10;0;9;0
WireConnection;12;1;10;0
WireConnection;13;0;12;1
WireConnection;13;1;14;0
WireConnection;13;2;15;0
WireConnection;16;0;13;0
WireConnection;16;1;17;0
WireConnection;37;0;16;0
WireConnection;39;0;5;0
WireConnection;7;0;18;0
WireConnection;7;3;56;0
WireConnection;0;0;7;0
WireConnection;19;0;1;4
WireConnection;19;1;40;0
WireConnection;3;0;2;1
WireConnection;4;0;3;0
WireConnection;5;0;4;0
WireConnection;5;1;6;0
WireConnection;33;1;42;0
WireConnection;25;0;24;0
WireConnection;25;1;28;0
WireConnection;28;0;26;0
WireConnection;28;1;27;0
WireConnection;42;0;43;0
WireConnection;42;1;44;0
WireConnection;44;0;46;0
WireConnection;44;1;45;0
WireConnection;47;0;33;1
WireConnection;47;1;30;0
WireConnection;47;2;50;0
WireConnection;18;0;1;0
WireConnection;18;1;38;0
WireConnection;18;2;35;0
WireConnection;18;3;49;0
WireConnection;18;4;53;0
WireConnection;53;0;51;0
WireConnection;53;1;1;0
WireConnection;53;2;54;0
WireConnection;51;0;1;1
WireConnection;51;1;52;0
WireConnection;48;0;47;0
WireConnection;55;0;22;0
WireConnection;55;1;19;0
WireConnection;56;0;55;0
WireConnection;34;0;29;0
WireConnection;29;0;22;0
WireConnection;29;1;30;0
WireConnection;29;2;31;0
ASEEND*/
//CHKSM=BBDA3A90622FBAD062C7CC348021D716026FBF7F