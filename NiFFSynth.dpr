{$J-,H+,T-P+,X+,B-,V-,O+,A+,W-,U-,R-,I-,Q-,D-,L-,Y-,C-}
library NiFFSynth;

uses
  FastMM4,
  {$IFDEF UseFastMove}
  FastMove,
  {$ENDIF }
  DAV_VSTEffect,
  DAV_VSTBasicModule,
  NiFFSynthModule in 'NiFFSynthModule.pas' {VSTSSModule: TVSTModule},
  NiFFSynthGUI in 'NiFFSynthGUI.pas' {VSTGUI},
  NiFFSynthVoice in 'NiFFSynthVoice.pas',
  controllers in 'FM\controllers.pas',
  dx7note in 'FM\dx7note.pas',
  env in 'FM\env.pas',
  exp2 in 'FM\exp2.pas',
  fm_core in 'FM\fm_core.pas',
  fm_op_kernel in 'FM\fm_op_kernel.pas',
  freqlut in 'FM\freqlut.pas',
  lfo in 'FM\lfo.pas',
  pitchenv in 'FM\pitchenv.pas',
  sin in 'FM\sin.pas',
  EngineMkI in 'FM\EngineMkI.pas',
  EngineOpl in 'FM\EngineOpl.pas';

function VstPluginMain(AudioMasterCallback: TAudioMasterCallbackFunc): PVSTEffect; cdecl; export;
begin
 Result := VstModuleMain(AudioMasterCallback, TVSTSSModule);
end;

exports 
  VstPluginMain name 'main',
  VstPluginMain name 'VSTPluginMain';

begin
end.

