unit Lfo;

interface

uses sin;

const
  LG_N = 6;
  N = 1 shl LG_N;

type
TParamsArray=array[0..5] of byte;

TLfo = record
  unit_,
  phase_,
  delta_      : uint32;
  waveform_,
  randstate_  : byte;
  sync_       : Boolean;
  delaystate_,
  delayinc_,
  delayinc2_  : uint32;
  procedure init( sample_rate : Double);
  procedure reset(const params : TParamsArray);
  function getsample:integer;
  function getdelay:integer;
  procedure keydown;
end;


implementation

uses system.Math, system.SysUtils;

{ Lfo }


procedure TLfo.init( sample_rate : Double);
begin
    // constant is 1  shl  32 / 15.5s / 11
    unit_ := trunc(N * 25190424 / sample_rate + 0.5);
end;


procedure TLfo.reset(const params : TParamsArray);
var
  rate,
  a:integer;
  sr : integer;
begin
    rate := params[0]; // 0..99
    sr := ifthen(rate = 0 , 1 , (165 * rate)  shr  6);
    sr  := sr  * ifthen(sr < 160 , 11  ,  11 + ((sr - 160) shr 4) );
    delta_ := unit_ * sr;
    a := 99 - params[1];  // LFO delay

    if a = 99 then
    begin
        delayinc_ := Cardinal(not 0);
        delayinc2_ := Cardinal(not 0);
    end
    else
    begin
        a := (16 + (a and 15))  shl  (1 + (a  shr  4));
        delayinc_ := unit_ * a;
        a  := a and $ff80;
        a := max($80, a);
        delayinc2_ := unit_ * a;
    end;
    waveform_ := params[5];
    sync_ := params[4] <> 0;
end;


function TLfo.getsample:integer;
var
  x : integer;
begin
    phase_  := phase_ + delta_;
    case waveform_ of
      0:
        begin
          // triangle
          x := phase_  shr  7;
          x  := x xor (-(phase_  shr  31));
          x  := x and ((1  shl  24) - 1);
          Exit(x)
        end;
      1:
        begin
          // sawtooth down
          Exit((not phase_  xor  (1  shl  31))  shr  8)
        end;
      2:
        begin
          // sawtooth up
          Exit((phase_  xor  (1  shl  31))  shr  8)
        end;
      3:
        begin
          // square
          Exit(((not phase_)  shr  7) and (1  shl  24))
        end;
      4:
        begin
          // sine
          Exit((1  shl  23) + (TSin.lookup(phase_  shr  8)  shr  1))
        end;
      5:
        begin
          // s&h
          if phase_ < delta_ then begin
            randstate_ := (randstate_ * 179 + 17) and $ff
          end;
          x := randstate_  xor  $80;
          Exit((x + 1)  shl  16);
        end;
    end;
    Result := 1  shl  23;
end;


function TLfo.getdelay: integer;
var
  delta: uint32;
  d    : uint64;
begin
  if delaystate_ < int64(1 shl 31) then
    delta := delayinc_
  else
    delta := delayinc2_;

  d := (delaystate_) + delta;
  if d > Cardinal(not 0) then
    Exit(1 shl 24);

  delaystate_ := d;
  if d < (1 shl 31) then
    Exit(0)
  else
    Exit((d shr 7) and ((1 shl 24) - 1));
end;


procedure TLfo.keydown;
begin
    if sync_ then
      phase_ := {@@@int64(1  shl  31) - 1} Cardinal.MaxValue;

    delaystate_ := 0;
end;





end.
