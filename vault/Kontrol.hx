package vault;

import rtmidi.RTMidiIn;

class Kontrol {
  var midi_input: RTMidiIn = null;

  public var slider: Array<Float>;
  public var knob: Array<Float>;
  public var track_solo: Array<Bool>;
  public var track_mute: Array<Bool>;
  public var track_rec: Array<Bool>;
  public var button: Array<Bool>;

  public function new() {
    midi_input = new RTMidiIn();
    var ports = midi_input.getPortCount();

    var valid = false;

    for (i in 0...ports) {
      midi_input.openPort(i);
      if (midi_input.getPortName(i) == "nanoKONTROL2 SLIDER/KNOB") {
        valid = true;
        break;
      }
      midi_input.closePort();
    }

    if (!valid) {
      midi_input.close();
      midi_input = null;
      return;
    }

    midi_input.setCallback(callback);
    midi_input.ignoreTypes(false, false, false);

    slider = new Array<Float>();
    knob = new Array<Float>();
    track_solo = new Array<Bool>();
    track_mute = new Array<Bool>();
    track_rec = new Array<Bool>();
    button = new Array<Bool>();

    for (i in 0...8) {
      slider.push(0.0);
      knob.push(0.0);
      track_solo.push(false);
      track_mute.push(false);
      track_rec.push(false);
    }

    for (i in 0...11) {
      button.push(false);
    }
  }

  public function close() {
    if (midi_input != null) {
      midi_input.close();
      midi_input = null;
    }
  }

  function callback(msg: Array<Int>) {
    if (msg[0] != 176) return;

    var track = msg[1] & 7;
    var clicked = msg[2] == 127;

    // sliders
    if (msg[1] >= 0 && msg[1] <= 7) {
      slider[track] = msg[2]/127.0;
    } else if (msg[1] >= 16 && msg[1] <= 23) {
      knob[track] = msg[2]/127.0;
    } else if (msg[1] >= 32 && msg[1] <= 39) {
      track_solo[track] = msg[2] == 127;
    } else if (msg[1] >= 48 && msg[1] <= 55) {
      track_mute[track] = msg[2] == 127;
    } else if (msg[1] >= 64 && msg[1] <= 71) {
      track_rec[track] = msg[2] == 127;
    } else if (msg[1] == 58) { button[TRACK_LEFT] = clicked; }
      else if (msg[1] == 59) { button[TRACK_RIGHT] = clicked; }
      else if (msg[1] == 46) { button[CYCLE] = clicked; }
      else if (msg[1] == 60) { button[MARKER_SET] = clicked; }
      else if (msg[1] == 61) { button[MARKER_LEFT] = clicked; }
      else if (msg[1] == 62) { button[MARKER_RIGHT] = clicked; }
      else if (msg[1] == 43) { button[REWIND] = clicked; }
      else if (msg[1] == 44) { button[FORWARD] = clicked; }
      else if (msg[1] == 42) { button[STOP] = clicked; }
      else if (msg[1] == 41) { button[PLAY] = clicked; }
      else if (msg[1] == 45) { button[RECORD] = clicked; }
    else {
      trace(msg, track);
    }
  }

  static public var TRACK_LEFT = 0;
  static public var TRACK_RIGHT = 1;
  static public var CYCLE = 2;
  static public var MARKER_SET = 3;
  static public var MARKER_LEFT = 4;
  static public var MARKER_RIGHT = 5;
  static public var REWIND = 6;
  static public var FORWARD = 7;
  static public var STOP = 8;
  static public var PLAY = 9;
  static public var RECORD = 10;

}
