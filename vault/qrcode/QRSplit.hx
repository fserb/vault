/**
 * ...
 * @author Fabien Antoine
 * @copy Intuitiv Technology
 */

package vault.qrcode;

using vault.qrcode.EncodingMode;

class QRSplit {
	public var dataStr : String;
	public var input : QRInput;
	public var modeHint : EncodingMode;

	//----------------------------------------------------------------------
	public function new(dataStr : String, input : QRInput, modeHint : EncodingMode) {
		this.dataStr  = dataStr;
		this.input    = input;
		this.modeHint = modeHint;
	}

	//----------------------------------------------------------------------
	public static function isdigitat(str : String, pos : Int) : Bool {
		if(pos >= str.length)
			return false;

		return ((str.charCodeAt(pos) >= '0'.charCodeAt(0))&&(str.charCodeAt(pos) <= '9'.charCodeAt(0)));
	}

	//----------------------------------------------------------------------
	public static function isalnumat(str : String, pos : Int) : Bool {
		if(pos >= str.length)
			return false;

		return (QRInput.lookAnTable(str.charCodeAt(pos)) >= 0);
	}

	//----------------------------------------------------------------------
	public function identifyMode(pos : Int) {
		return this.identifyStringMode(this.dataStr, pos);
	}

	//----------------------------------------------------------------------
	public function identifyStringMode(str : String, pos : Int) {
		if(pos >= str.length)
			return EncodingMode.MNul;

		var c = str.charCodeAt(pos);

		if(isdigitat(str, pos)) {
			return EncodingMode.MNum;
		} else if(isalnumat(str, pos)) {
			return EncodingMode.MAn;
		} else if(this.modeHint == EncodingMode.MKanji) {
			if(pos + 1 < str.length)  {
				var d = str.charCodeAt(pos+1);
				var word = (c << 8) | d;
				if((word >= 0x8140 && word <= 0x9ffc) || (word >= 0xe040 && word <= 0xebbf)) {
					return EncodingMode.MKanji;
				}
			}
		}
		return EncodingMode.M8;
	}

	//----------------------------------------------------------------------
	public function eatNum() {
		var ln = QRSpec.lengthIndicator(EncodingMode.MNum, this.input.getVersion());

		var p = 0;
		while(isdigitat(this.dataStr, p)) {
			p++;
		}

		var run = p;
		var mode = this.identifyMode(p);

		if(mode == EncodingMode.M8) {
			var dif = QRInput.estimateBitsModeNum(run) + 4 + ln
				 + QRInput.estimateBitsMode8(1)         // + 4 + l8
				 - QRInput.estimateBitsMode8(run + 1); // - 4 - l8
			if(dif > 0) {
				return this.eat8();
			}
		}
		if(mode == EncodingMode.MAn) {
			var dif = QRInput.estimateBitsModeNum(run) + 4 + ln
				 + QRInput.estimateBitsModeAn(1)        // + 4 + la
				 - QRInput.estimateBitsModeAn(run + 1);// - 4 - la
			if(dif > 0) {
				return this.eatAn();
			}
		}

		var ret = this.input.appendString(EncodingMode.MNum, run, this.dataStr);
		if(ret < 0)
			return -1;

		return run;
	}

	//----------------------------------------------------------------------
	public function eatAn() {
		var la = QRSpec.lengthIndicator(EncodingMode.MAn,  this.input.getVersion());
		var ln = QRSpec.lengthIndicator(EncodingMode.MNum, this.input.getVersion());

		var p = 0;

		while(isalnumat(this.dataStr, p)) {
			if(isdigitat(this.dataStr, p)) {
				var q = p;
				while(isdigitat(this.dataStr, q)) {
					q++;
				}

				var dif = QRInput.estimateBitsModeAn(p) // + 4 + la
					 + QRInput.estimateBitsModeNum(q - p) + 4 + ln
					 - QRInput.estimateBitsModeAn(q); // - 4 - la

				if(dif < 0) {
					break;
				} else {
					p = q;
				}
			} else {
				p++;
			}
		}

		var run = p;

		if(!isalnumat(this.dataStr, p)) {
			var dif = QRInput.estimateBitsModeAn(run) + 4 + la
				 + QRInput.estimateBitsMode8(1) // + 4 + l8
				  - QRInput.estimateBitsMode8(run + 1); // - 4 - l8
			if(dif > 0) {
				return this.eat8();
			}
		}

		var ret = this.input.appendString(EncodingMode.MAn, run, this.dataStr);
		if(ret < 0)
			return -1;

		return run;
	}

	//----------------------------------------------------------------------
	public function eatKanji() {
		var p = 0;

		while(this.identifyMode(p) == EncodingMode.MKanji) {
			p += 2;
		}

		var run = p;

		var ret = this.input.appendString(EncodingMode.MKanji, p, this.dataStr);
		if(ret < 0)
			return -1;

		return run;
	}

	//----------------------------------------------------------------------
	public function eat8() {
		var la = QRSpec.lengthIndicator(EncodingMode.MAn, this.input.getVersion());
		var ln = QRSpec.lengthIndicator(EncodingMode.MNum, this.input.getVersion());

		var p = 1;
		var dataStrLen = this.dataStr.length;

		while(p < dataStrLen) {
			var mode = this.identifyMode(p);
			if(mode == EncodingMode.MKanji) {
				break;
			}
			if(mode == EncodingMode.MNul) {
				var q = p;
				while(isdigitat(this.dataStr, q)) {
					q++;
				}
				var dif = QRInput.estimateBitsMode8(p) // + 4 + l8
					 + QRInput.estimateBitsModeNum(q - p) + 4 + ln
					 - QRInput.estimateBitsMode8(q); // - 4 - l8
				if(dif < 0) {
					break;
				} else {
					p = q;
				}
			} else if(mode == EncodingMode.MAn) {
				var q = p;
				while(isalnumat(this.dataStr, q)) {
					q++;
				}
				var dif = QRInput.estimateBitsMode8(p)  // + 4 + l8
					 + QRInput.estimateBitsModeAn(q - p) + 4 + la
					 - QRInput.estimateBitsMode8(q); // - 4 - l8
				if(dif < 0) {
					break;
				} else {
					p = q;
				}
			} else {
				p++;
			}
		}

		var run = p;
		var ret = this.input.appendString(EncodingMode.M8, run, this.dataStr);

		if(ret < 0)
			return -1;

		return run;
	}

	//----------------------------------------------------------------------
	public function splitString() : Int {
		while(this.dataStr.length > 0) {
			if(this.dataStr == '')
				return 0;

			var mode = this.identifyMode(0);

			var length = switch(mode) {
				case EncodingMode.MNum:		this.eatNum();
				case EncodingMode.MAn:		this.eatAn();
				case EncodingMode.MKanji:	if(this.modeHint == EncodingMode.MKanji) this.eatKanji(); else this.eat8();
				default: 					this.eat8();
			}

			if(length == 0) return 0;
			if(length < 0)  return -1;

			this.dataStr = this.dataStr.substr(length);
		}
		return 0;
	}

	//----------------------------------------------------------------------
	public function toUpper() {
		var stringLen = this.dataStr.length;
		var p = 0;

		while(p < stringLen) {
			var mode = null; // this.identifyStringMode(this.dataStr.substr(p), this.modeHint);
			if(mode == EncodingMode.MKanji) {
				p += 2;
			} else {
				if(this.dataStr.charCodeAt(p) >= 'a'.charCodeAt(0) && this.dataStr.charCodeAt(p) <= 'z'.charCodeAt(0)) {
					var start : String = this.dataStr.substr(0, p);
					var end : String = this.dataStr.substr(p + 1);

					this.dataStr = start + (String.fromCharCode(this.dataStr.charCodeAt(p) - 32)) + end;

					//this.dataStr[$p] = chr(ord(this.dataStr[$p]) - 32);
				}
				p++;
			}
		}

		return this.dataStr;
	}

	//----------------------------------------------------------------------
	public static function splitStringToQRinput(string, input : QRInput, modeHint, ?casesensitive : Bool = true) {
		if(string == null || string == '') {
			throw 'empty string!!!';
		}

		var split = new QRSplit(string, input, modeHint);

		if(!casesensitive)
			split.toUpper();

		return split.splitString();
	}
}
