unit NiFFSynthVoice;

/// /////////////////////////////////////////////////////////////////////////////
// //
// Version: MPL 1.1 or LGPL 2.1 with linking exception                       //
// //
// The contents of this file are subject to the Mozilla Public License       //
// Version 1.1 (the "License"); you may not use this file except in          //
// compliance with the License. You may obtain a copy of the License at      //
// http://www.mozilla.org/MPL/                                               //
// //
// Software distributed under the License is distributed on an "AS IS"       //
// basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the   //
// License for the specific language governing rights and limitations under  //
// the License.                                                              //
// //
// Alternatively, the contents of this file may be used under the terms of   //
// the Free Pascal modified version of the GNU Lesser General Public         //
// License Version 2.1 (the "FPC modified LGPL License"), in which case the  //
// provisions of this license are applicable instead of those above.         //
// Please see the file LICENSE.txt for additional information concerning     //
// this license.                                                             //
// //
// The code is part of the Delphi ASIO & VST Project                         //
// //
// The initial developer of this code is Christian-W. Budde                  //
// //
// Portions created by Christian-W. Budde are Copyright (C) 2009-2012        //
// by Christian-W. Budde. All Rights Reserved.                               //
// //
/// /////////////////////////////////////////////////////////////////////////////

interface

{$I DAV_Compiler.inc}

uses
  DAV_VSTModule, DAV_Complex, Generics.Collections,
  controllers, dx7note, lfo,
  fm_core
//  PluginParam,
//  PluginData,
//  PluginFx,
//  SysexComm,
//  EngineMkI,
//  EngineOpl
  ;

{$I Consts.inc}

type
  DexedEngineResolution  = (
    DEXED_ENGINE_MODERN = 0,
    DEXED_ENGINE_MARKI  = 1,
    DEXED_ENGINE_OPL    = 2
  );

  TNiFFSynthVoice = class
  var
    midi_note,
    velocity  : integer;
    keydown,
    sustained,
    live      : Boolean;
    dx7_note  : TDx7Note;
    FVSTModule : TVSTModule;
    constructor Create(theModule: TVSTModule);
  end;

  TVoiceList = TObjectList<TNiFFSynthVoice>;

implementation

uses
  Math, SysUtils, DAV_Common, DAV_Types, DAV_Math, NiFFSynthModule;

{ TOscilator }

{ TXSynthVoice }

constructor TNiFFSynthVoice.Create(theModule: TVSTModule);
begin
  FVSTModule := theModule;
end;

function TNiFFSynthVoice.Process: Single;
var
  i: Integer;
begin
  Result := FOscilators[0].Process + FOscilators[1].Process;
  if (FOscilators[0].FADSRGain = 0) and (FOscilators[1].FADSRGain = 0) then
    with (FVSTModule as TVSTSSModule) do
      for i := 0 to Voices.Count - 1 do
        if Voices.Items[i] = Self then
        begin
          Voices.Delete(i);
          Exit;
        end;
end;

procedure TNiFFSynthVoice.SetAmplitude(aAmplitude: Single);
var
  i: Integer;
begin
  FAmplitude := aAmplitude;
  for i := 0 to OSCILLATOR_COUNT - 1 do
    FOscilators[i].Amplitude := aAmplitude;
end;

procedure TNiFFSynthVoice.SetFrequency(aFrequency: Single);
var i : integer;
begin
  FFrequency := aFrequency;
  for i := 0 to OSCILLATOR_COUNT-1 do
    FOscilators[i].Frequency := FFrequency;
end;

procedure TNiFFSynthVoice.NoteOn(aFrequency, aAmplitude: Single);
begin
  SetFrequency(aFrequency);
  SetAmplitude(aAmplitude);
end;

procedure TNiFFSynthVoice.NoteOff;
var i:Integer;
begin
  for i := 0 to OSCILLATOR_COUNT-1 do
    FOscilators[i].ReleaseOsc;
  FReleased := True;
end;

{ TSawOscilator }

constructor TSawOscilator.Create;
begin
  inherited;
  w := 0;
  currentPhase:= 0;
end;

procedure TSawOscilator.FrequencyChanged;
begin
  inherited;
  w := (TwoDoublePi * frequency) / sampleRate;
end;

function TSawOscilator.process: Single;
begin
  Result := (DoublePiInv * currentPhase - 1) * FAmplitude * ProcessADSR;
  currentPhase := currentPhase + w;

  if CurrentPhase > TwoDoublePi then
    currentPhase := currentPhase - TwoDoublePi;
end;

end.
