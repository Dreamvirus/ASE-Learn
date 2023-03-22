// Made with Amplify Shader Editor v1.9.1
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Card_ASE"
{
	Properties
	{
		_TextureSample0("Texture Sample 0", 2D) = "white" {}
		_NormalTex("NormalTex", 2D) = "bump" {}
		_RampTex("RampTex", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Opaque" }
	LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend Off
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
			#include "UnityStandardBRDF.cginc"
			#include "UnityStandardUtils.cginc"
			#define ASE_NEEDS_FRAG_WORLD_POSITION


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;
				float3 ase_normal : NORMAL;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
				#endif
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform sampler2D _RampTex;
			uniform sampler2D _TextureSample0;
			uniform float4 _TextureSample0_ST;
			uniform sampler2D _NormalTex;
			uniform float4 _NormalTex_ST;
			inline float3 ASESafeNormalize(float3 inVec)
			{
				float dp3 = max( 0.001f , dot( inVec , inVec ) );
				return inVec* rsqrt( dp3);
			}
			

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float3 ase_worldTangent = UnityObjectToWorldDir(v.ase_tangent);
				o.ase_texcoord2.xyz = ase_worldTangent;
				float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord3.xyz = ase_worldNormal;
				float ase_vertexTangentSign = v.ase_tangent.w * ( unity_WorldTransformParams.w >= 0.0 ? 1.0 : -1.0 );
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				o.ase_texcoord4.xyz = ase_worldBitangent;
				
				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;
				o.ase_texcoord2.w = 0;
				o.ase_texcoord3.w = 0;
				o.ase_texcoord4.w = 0;
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
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(WorldPosition);
				ase_worldViewDir = Unity_SafeNormalize( ase_worldViewDir );
				float3 worldToObjDir25 = ASESafeNormalize( mul( unity_WorldToObject, float4( ase_worldViewDir, 0 ) ).xyz );
				float cos28 = cos( ( ( 45.0 / 180.0 ) * UNITY_PI ) );
				float sin28 = sin( ( ( 45.0 / 180.0 ) * UNITY_PI ) );
				float2 rotator28 = mul( worldToObjDir25.xy - float2( 0,0 ) , float2x2( cos28 , -sin28 , sin28 , cos28 )) + float2( 0,0 );
				float ViewDir38 = abs( (frac( rotator28.x )*2.0 + -1.0) );
				float saferPower43 = abs( ViewDir38 );
				float2 uv_TextureSample0 = i.ase_texcoord1.xy * _TextureSample0_ST.xy + _TextureSample0_ST.zw;
				float4 tex2DNode3 = tex2D( _TextureSample0, uv_TextureSample0 );
				float2 texCoord5 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float temp_output_6_0 = step( 0.5 , texCoord5.x );
				float BackMask12 = ( tex2DNode3.a * ( 1.0 - temp_output_6_0 ) );
				float3 temp_cast_1 = (ViewDir38).xxx;
				float2 uv_NormalTex = i.ase_texcoord1.xy * _NormalTex_ST.xy + _NormalTex_ST.zw;
				float3 ase_worldTangent = i.ase_texcoord2.xyz;
				float3 ase_worldNormal = i.ase_texcoord3.xyz;
				float3 ase_worldBitangent = i.ase_texcoord4.xyz;
				float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
				float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
				float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
				float3 tanNormal19 = UnpackScaleNormal( tex2D( _NormalTex, uv_NormalTex ), 1.0 );
				float3 worldNormal19 = normalize( float3(dot(tanToWorld0,tanNormal19), dot(tanToWorld1,tanNormal19), dot(tanToWorld2,tanNormal19)) );
				float fresnelNdotV16 = dot( normalize( worldNormal19 ), temp_cast_1 );
				float fresnelNode16 = ( 0.0 + 1.0 * pow( max( 1.0 - fresnelNdotV16 , 0.0001 ), 3.0 ) );
				float FrontMask9 = ( tex2DNode3.a * temp_output_6_0 );
				float CustomFresnel22 = ( fresnelNode16 * FrontMask9 );
				float2 appendResult48 = (float2(( ( pow( saferPower43 , 3.0 ) * BackMask12 ) + CustomFresnel22 ) , 0.5));
				float4 RampColoe50 = tex2D( _RampTex, appendResult48 );
				float4 MainColor13 = tex2DNode3;
				
				
				finalColor = ( ( ( ( RampColoe50 * 1.0 ) + MainColor13 ) * FrontMask9 ) + ( ( MainColor13 + ( MainColor13 * RampColoe50 * 1.0 ) ) * BackMask12 ) + ( MainColor13 * ( 1.0 - ( BackMask12 + FrontMask9 ) ) ) );
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
Node;AmplifyShaderEditor.CommentaryNode;76;-2980.327,895.916;Inherit;False;1719.755;378.389;Comment;10;46;47;48;49;42;43;44;45;41;50;RampColor;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;75;-2980.74,175.2505;Inherit;False;1874.676;507.4918;Comment;13;24;25;28;31;30;32;33;34;35;36;38;72;29;CustomViewDir;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;74;-2988.986,-348.8339;Inherit;False;1877.069;425.3318;Comment;9;18;19;16;20;22;21;40;15;17;Fresnel;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;73;-931.0936,-366.0333;Inherit;False;1196.464;629.6141;;10;9;12;3;5;6;7;10;8;11;13;Color & Mask;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;9;-9.356805,20.29649;Inherit;False;FrontMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;12;40.57001,-251.7184;Inherit;False;BackMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;3;-881.0936,-316.0333;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;7b07d296f866f024aa0132e5dd07e416;7b07d296f866f024aa0132e5dd07e416;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;5;-839.8668,104.7641;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StepOpNode;6;-590.1469,10.18089;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-775.4743,4.802003;Inherit;False;Constant;_Float0;Float 0;1;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;10;-357.1224,-103.6596;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;-331.2983,6.523584;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;11;-200.4557,-232.7807;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;13;-527.1088,-310.011;Inherit;False;MainColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;18;-2898.742,-298.8339;Inherit;False;0;15;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;17;-2938.986,-134.9795;Inherit;False;Constant;_NormalScale;NormalScale;2;0;Create;True;0;0;0;False;0;False;1;1;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;24;-2744.212,225.2508;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleDivideOpNode;31;-2598.325,437.1015;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-2877.655,555.911;Inherit;False;Constant;_Float1;Float 1;4;0;Create;True;0;0;0;False;0;False;180;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-2930.74,435.8375;Inherit;False;Constant;_RotateAngel;RotateAngel;3;0;Create;True;0;0;0;False;0;False;45;45;0;360;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;19;-2133.57,-273.5427;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.FresnelNode;16;-1888.598,-275.9536;Inherit;True;Standard;WorldNormal;ViewDir;True;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;-1528.95,-258.9327;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;22;-1341.517,-252.8208;Inherit;False;CustomFresnel;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;21;-1801.951,-38.9022;Inherit;False;9;FrontMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;40;-2224.866,-50.87729;Inherit;False;38;ViewDir;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;15;-2557.073,-276.1868;Inherit;True;Property;_NormalTex;NormalTex;1;0;Create;True;0;0;0;False;0;False;-1;None;ed2f679be62102f41b8d2fadc8eb9f24;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TransformDirectionNode;25;-2525.604,226.9196;Inherit;False;World;Object;True;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RotatorNode;28;-2217.226,280.934;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;-2412.527,473.7555;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;33;-2633.715,572.3422;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;34;-2014.651,287.127;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.FractNode;35;-1856.659,294.7108;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;36;-1707.515,289.6548;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;38;-1330.865,283.3352;Inherit;False;ViewDir;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;72;-1496.481,285.6473;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;46;-2330.741,1026.058;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;47;-2626.704,1140.407;Inherit;False;22;CustomFresnel;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;48;-2132.312,1051.283;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;49;-2344.195,1158.905;Inherit;False;Constant;_Float2;Float 2;5;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;42;-2930.327,945.916;Inherit;False;38;ViewDir;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;43;-2736.009,950.387;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;-2566.167,1022.696;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;45;-2848.676,1076.507;Inherit;False;12;BackMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;41;-1928.398,994.0388;Inherit;True;Property;_RampTex;RampTex;2;0;Create;True;0;0;0;False;0;False;-1;None;7bcf229020ad6c641a0bdc471a637920;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;50;-1485.372,992.8868;Inherit;False;RampColoe;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;53;-923.7787,480.3375;Inherit;False;50;RampColoe;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;54;-663.8353,529.5167;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;52;-472.3311,567.9421;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;60;-945.2402,890.4661;Inherit;False;50;RampColoe;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;62;-337.6179,763.6331;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;63;-156.2164,818.2009;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;64;-406.934,964.2068;Inherit;False;12;BackMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;65;-501.3219,676.6193;Inherit;False;9;FrontMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;57;-238.8055,616.1525;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;322.6277,685.2167;Float;False;True;-1;2;ASEMaterialInspector;100;5;Card_ASE;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;False;True;0;1;False;;0;False;;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;RenderType=Opaque=RenderType;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.GetLocalVarNode;67;-827.8168,1197.217;Inherit;False;12;BackMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;69;-549.9495,1233.96;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;68;-837.0024,1316.631;Inherit;False;9;FrontMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;70;-343.2713,1238.553;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;71;-102.1469,1114.546;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;66;80.0036,705.6301;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;59;-619.1592,830.356;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;51;-844.5514,710.4561;Inherit;False;13;MainColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;56;-989.8774,585.7117;Inherit;False;Constant;_FloatInt;FloatInt;5;0;Create;True;0;0;0;False;0;False;1;1;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;61;-989.296,988.7728;Inherit;False;Constant;_BackInt;BackInt;6;0;Create;True;0;0;0;False;0;False;1;0;0;2;0;1;FLOAT;0
WireConnection;9;0;8;0
WireConnection;12;0;11;0
WireConnection;6;0;7;0
WireConnection;6;1;5;1
WireConnection;10;0;6;0
WireConnection;8;0;3;4
WireConnection;8;1;6;0
WireConnection;11;0;3;4
WireConnection;11;1;10;0
WireConnection;13;0;3;0
WireConnection;31;0;29;0
WireConnection;31;1;30;0
WireConnection;19;0;15;0
WireConnection;16;0;19;0
WireConnection;16;4;40;0
WireConnection;20;0;16;0
WireConnection;20;1;21;0
WireConnection;22;0;20;0
WireConnection;15;1;18;0
WireConnection;15;5;17;0
WireConnection;25;0;24;0
WireConnection;28;0;25;0
WireConnection;28;2;32;0
WireConnection;32;0;31;0
WireConnection;32;1;33;0
WireConnection;34;0;28;0
WireConnection;35;0;34;0
WireConnection;36;0;35;0
WireConnection;38;0;72;0
WireConnection;72;0;36;0
WireConnection;46;0;44;0
WireConnection;46;1;47;0
WireConnection;48;0;46;0
WireConnection;48;1;49;0
WireConnection;43;0;42;0
WireConnection;44;0;43;0
WireConnection;44;1;45;0
WireConnection;41;1;48;0
WireConnection;50;0;41;0
WireConnection;54;0;53;0
WireConnection;54;1;56;0
WireConnection;52;0;54;0
WireConnection;52;1;51;0
WireConnection;62;0;51;0
WireConnection;62;1;59;0
WireConnection;63;0;62;0
WireConnection;63;1;64;0
WireConnection;57;0;52;0
WireConnection;57;1;65;0
WireConnection;0;0;66;0
WireConnection;69;0;67;0
WireConnection;69;1;68;0
WireConnection;70;0;69;0
WireConnection;71;0;51;0
WireConnection;71;1;70;0
WireConnection;66;0;57;0
WireConnection;66;1;63;0
WireConnection;66;2;71;0
WireConnection;59;0;51;0
WireConnection;59;1;60;0
WireConnection;59;2;61;0
ASEEND*/
//CHKSM=5F042E02294DC21BD317DE3913D302EEE80FCAC0