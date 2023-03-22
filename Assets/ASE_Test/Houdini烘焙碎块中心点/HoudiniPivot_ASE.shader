// Made with Amplify Shader Editor v1.9.1
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "HoudiniPivot_ASE"
{
	Properties
	{
		_Length("Length", Float) = 0
		_Raidus("Raidus", Float) = 0
		_TargetPos("TargetPos", Vector) = (0,0,0,0)
		_Hardness("Hardness", Range( 0 , 1)) = 0
		[HDR]_EmissionColor("EmissionColor", Color) = (0,0,0,0)
		_EmossionInt("EmossionInt", Float) = 0
		_RotationAxis("RotationAxis", Vector) = (0,0,0,0)
		_TimeScale("TimeScale", Float) = 0.6

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

			#define ASE_ABSOLUTE_VERTEX_POS 1


			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#include "UnityShaderVariables.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			#define ASE_NEEDS_FRAG_WORLD_POSITION


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord3 : TEXCOORD3;
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
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			//This is a late directive
			
			uniform float3 _RotationAxis;
			uniform float _TimeScale;
			uniform float _Length;
			uniform float3 _TargetPos;
			uniform float _Raidus;
			uniform float _Hardness;
			uniform float4 _EmissionColor;
			uniform float _EmossionInt;
			float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
			{
				original -= center;
				float C = cos( angle );
				float S = sin( angle );
				float t = 1 - C;
				float m00 = t * u.x * u.x + C;
				float m01 = t * u.x * u.y - S * u.z;
				float m02 = t * u.x * u.z + S * u.y;
				float m10 = t * u.x * u.y + S * u.z;
				float m11 = t * u.y * u.y + C;
				float m12 = t * u.y * u.z - S * u.x;
				float m20 = t * u.x * u.z - S * u.y;
				float m21 = t * u.y * u.z + S * u.x;
				float m22 = t * u.z * u.z + C;
				float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
				return mul( finalMatrix, original ) + center;
			}
			

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float mulTime38 = _Time.y * _TimeScale;
				float3 objToWorld8 = mul( unity_ObjectToWorld, float4( float3(0,0,0), 1 ) ).xyz;
				float2 texCoord1 = v.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 texCoord2 = v.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float3 appendResult4 = (float3(-texCoord1.x , texCoord1.y , texCoord2.x));
				float3 PivotPos5 = appendResult4;
				float3 rotatedValue40 = RotateAroundAxis( objToWorld8, PivotPos5, _RotationAxis, mulTime38 );
				float3 temp_output_22_0 = ( ( PivotPos5 - _TargetPos ) / _Raidus );
				float dotResult18 = dot( temp_output_22_0 , temp_output_22_0 );
				float SphereMask28 = ( 1.0 - pow( saturate( dotResult18 ) , _Hardness ) );
				float3 ase_worldPos = mul(unity_ObjectToWorld, float4( (v.vertex).xyz, 1 )).xyz;
				float3 rotatedValue37 = RotateAroundAxis( objToWorld8, ase_worldPos, _RotationAxis, mulTime38 );
				float3 worldToObj13 = mul( unity_WorldToObject, float4( ( ( ( rotatedValue40 - objToWorld8 ) * _Length * SphereMask28 ) + rotatedValue37 ), 1 ) ).xyz;
				
				float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord1.xyz = ase_worldNormal;
				
				o.ase_texcoord2.xy = v.ase_texcoord1.xy;
				o.ase_texcoord2.zw = v.ase_texcoord3.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.w = 0;
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = worldToObj13;
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
				float3 ase_worldNormal = i.ase_texcoord1.xyz;
				float3 worldSpaceLightDir = UnityWorldSpaceLightDir(WorldPosition);
				float dotResult5_g1 = dot( ase_worldNormal , worldSpaceLightDir );
				float temp_output_14_0 = (dotResult5_g1*0.5 + 0.5);
				float4 temp_cast_0 = (temp_output_14_0).xxxx;
				float2 texCoord1 = i.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 texCoord2 = i.ase_texcoord2.zw * float2( 1,1 ) + float2( 0,0 );
				float3 appendResult4 = (float3(-texCoord1.x , texCoord1.y , texCoord2.x));
				float3 PivotPos5 = appendResult4;
				float3 temp_output_22_0 = ( ( PivotPos5 - _TargetPos ) / _Raidus );
				float dotResult18 = dot( temp_output_22_0 , temp_output_22_0 );
				float SphereMask28 = ( 1.0 - pow( saturate( dotResult18 ) , _Hardness ) );
				float4 lerpResult34 = lerp( temp_cast_0 , ( temp_output_14_0 * ( _EmissionColor * _EmossionInt ) ) , SphereMask28);
				
				
				finalColor = lerpResult34;
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
Node;AmplifyShaderEditor.CommentaryNode;49;-2219.046,-258.1961;Inherit;False;2408.776;1089.424;Comment;19;36;38;12;37;39;3;5;7;40;4;8;2;1;6;11;9;10;29;13;碎片炸开;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;48;725.7448,315.2607;Inherit;False;1328.082;370.7644;Comment;7;41;42;45;46;44;43;47;碎片缩放;1,1,1,1;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;659.9788,-129.1597;Float;False;True;-1;2;ASEMaterialInspector;100;5;HoudiniPivot_ASE;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;False;True;0;1;False;;0;False;;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;RenderType=Opaque=RenderType;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;0;638148881989445383;0;1;True;False;;False;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;18.23072,-451.8391;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldNormalVector;15;-268.1202,-674.6516;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.FunctionNode;14;1.879868,-665.6516;Inherit;False;Half Lambert Term;-1;;1;86299dc21373a954aa5772333626c9c1;0;1;3;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;35;180.1232,-335.4328;Inherit;False;28;SphereMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;245.6907,-501.7349;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;34;447.4292,-518.5063;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;17;-596.3137,997.735;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;18;-740.3135,997.735;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;20;-1092.313,997.735;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PowerNode;21;-420.3136,997.735;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;22;-900.3126,997.735;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;23;-1329.543,1023.255;Inherit;False;5;PivotPos;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-1084.584,1158.241;Inherit;False;Property;_Raidus;Raidus;1;0;Create;True;0;0;0;False;0;False;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-738.1765,1164.747;Inherit;False;Property;_Hardness;Hardness;3;0;Create;True;0;0;0;False;0;False;0;0.6;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;27;-261.6613,1010.244;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;28;-48.61269,989.1022;Inherit;False;SphereMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;24;-1336.049,1171.252;Inherit;False;Property;_TargetPos;TargetPos;2;0;Create;True;0;0;0;False;0;False;0,0,0;-0.1,0,2.87;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ColorNode;30;-264.2384,-486.6361;Inherit;False;Property;_EmissionColor;EmissionColor;4;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,0;0,0.4332013,2.369866,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;41;779.5129,365.2607;Inherit;False;5;PivotPos;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;42;775.7448,487.7259;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;45;1047.052,570.6251;Inherit;False;28;SphereMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;46;1574.595,444.3918;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;1325.896,406.7102;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;43;1096.038,402.9423;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TransformPositionNode;47;1822.627,434.9717;Inherit;False;World;Object;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;32;-239.6758,-296.2765;Inherit;False;Property;_EmossionInt;EmossionInt;5;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;36;-1420.573,369.462;Inherit;False;Property;_RotationAxis;RotationAxis;6;0;Create;True;0;0;0;False;0;False;0,0,0;1,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleTimeNode;38;-1430.264,536.6366;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;12;-1331.772,650.6281;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RotateAboutAxisNode;37;-1081.378,371.8849;Inherit;False;False;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;39;-1638.96,529.4678;Inherit;False;Property;_TimeScale;TimeScale;7;0;Create;True;0;0;0;False;0;False;0.6;0.6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;3;-1886.668,-206.024;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;5;-1550.599,-147.8353;Inherit;False;PivotPos;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;7;-1838.232,198.1733;Inherit;False;Constant;_Vector0;Vector 0;0;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RotateAboutAxisNode;40;-1080.37,-155.6457;Inherit;False;False;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;4;-1728.194,-139.6974;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TransformPositionNode;8;-1661.483,192.6927;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TextureCoordinatesNode;2;-2169.046,-53.97456;Inherit;False;3;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;1;-2169.046,-208.1961;Inherit;False;1;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;6;-637.1587,-159.0176;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;11;-207.3145,-103.4501;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;9;-430.2668,-139.8362;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-730.671,-37.356;Inherit;False;Property;_Length;Length;0;0;Create;True;0;0;0;False;0;False;0;1.13;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;29;-772.4232,63.27066;Inherit;False;28;SphereMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformPositionNode;13;-41.47002,-92.1526;Inherit;False;World;Object;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
WireConnection;0;0;34;0
WireConnection;0;1;13;0
WireConnection;31;0;30;0
WireConnection;31;1;32;0
WireConnection;14;3;15;0
WireConnection;33;0;14;0
WireConnection;33;1;31;0
WireConnection;34;0;14;0
WireConnection;34;1;33;0
WireConnection;34;2;35;0
WireConnection;17;0;18;0
WireConnection;18;0;22;0
WireConnection;18;1;22;0
WireConnection;20;0;23;0
WireConnection;20;1;24;0
WireConnection;21;0;17;0
WireConnection;21;1;26;0
WireConnection;22;0;20;0
WireConnection;22;1;25;0
WireConnection;27;0;21;0
WireConnection;28;0;27;0
WireConnection;46;0;44;0
WireConnection;46;1;42;0
WireConnection;44;0;43;0
WireConnection;44;1;45;0
WireConnection;43;0;41;0
WireConnection;43;1;42;0
WireConnection;47;0;46;0
WireConnection;38;0;39;0
WireConnection;37;0;36;0
WireConnection;37;1;38;0
WireConnection;37;2;8;0
WireConnection;37;3;12;0
WireConnection;3;0;1;1
WireConnection;5;0;4;0
WireConnection;40;0;36;0
WireConnection;40;1;38;0
WireConnection;40;2;8;0
WireConnection;40;3;5;0
WireConnection;4;0;3;0
WireConnection;4;1;1;2
WireConnection;4;2;2;1
WireConnection;8;0;7;0
WireConnection;6;0;40;0
WireConnection;6;1;8;0
WireConnection;11;0;9;0
WireConnection;11;1;37;0
WireConnection;9;0;6;0
WireConnection;9;1;10;0
WireConnection;9;2;29;0
WireConnection;13;0;11;0
ASEEND*/
//CHKSM=602950E0F0DD03F34158A06CA7086B6756BE979E