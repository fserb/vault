/**
 * ...
 * @author Fabien Antoine
 * @copy Intuitiv Technology
 */

package vault.qrcode;

using vault.qrcode.ErrorCorrection;
using vault.qrcode.EncodingMode;

class QRCode {
	public static var cacheable : Bool		= false;       // use cache - more disk reads but less CPU power, masks and format templates are stored there
    public static var cacheDir : String		= null;       // used when cacheable === true
    public static var logDir : String		= null;       // default error logs dir

    public static var findBestMask : Bool	= false;        // if true, estimates best mask (spec. default, but extremally slow; set to false to significant performance boost but (propably) worst quality code
    public static var findFromRandom : Int	= 2;           // if false, checks all masks available, otherwise value tells count of masks need to be checked, mask id are got randomly
    public static var defaultMask : Int		= 2;           // when findBestMask === false


	//----------------------------------------------------------------------
	//public static var pngMaximumSize : Int	= 1024;
	//public static function png(text : String, outfile = false, level : ErrorCorrection = null, size : Int = 3, margin : Int = 4, saveandprint : Bool = false) {
		//if(level == null) level = ErrorCorrection.EC_L;
		//
		//var enc = QREncode.factory(level, size, margin);
		//return enc.encodePNG(text, outfile, saveandprint);
	//}

	//----------------------------------------------------------------------
	public static function text(text : String, level : ErrorCorrection = null, size : Int = 3, margin : Int = 4) : QRFrame {
		return new QREncode(level, size, margin).encode(text);
	}

	//----------------------------------------------------------------------
	public static function raw(text : String, level : ErrorCorrection = null, size : Int = 3, margin : Int = 4) : QRFrame {
		return new QREncode(level, size, margin).encodeRAW(text);
	}

	public var version : Int;
	public var width : Int;
	public var data : QRFrame;

	public function new() : Void {
		this.version	= 0;
		this.width		= 3;
		this.data		= [];
	}

	//----------------------------------------------------------------------
	public function encodeMask(input : QRInput, mask : Int) : QRCode {
		if(input.getVersion() < 0 || input.getVersion() > QRSpec.versionMax) {
			throw 'wrong version';
		}
		if(input.getErrorCorrectionLevel().toInt() > ErrorCorrection.EC_H.toInt()) {
			throw 'wrong level';
		}
		var raw = new QRRawCode(input);

		//QRtools::markTime('after_raw');

		var version = raw.version;
		var width = QRSpec.getWidth(version);
		var frame = QRSpec.newFrame(version);

		var filler = new FrameFiller(width, frame);

		// inteleaved data and ecc codes
		for(i in 0...(raw.dataLength + raw.eccLength)) {
			var code = raw.getCode();
			var bit = 0x80;
			for(j in 0...8) {
				var addr = filler.next();
				filler.setFrameAt(addr, 0x02 | ((bit & code) != 0 ? 1 : 0));
				bit = bit >> 1;
			}
		}

		//QRtools::markTime('after_filler');

		raw = null;

		// remainder bits
		for(i in 0...QRSpec.getRemainder(version)) {
			var addr = filler.next();
			filler.setFrameAt(addr, 0x02);
		}

		frame = filler.frame;
		filler = null;



		// masking
		var maskObj = new QRMask();
		var masked = null;
		if(mask < 0) {
			if(QRCode.findBestMask) {
				masked = maskObj.mask(width, frame, input.getErrorCorrectionLevel());
			} else {
				masked = maskObj.makeMask(width, frame, (QRCode.defaultMask % 8), input.getErrorCorrectionLevel());
			}
		} else {
			masked = maskObj.makeMask(width, frame, mask, input.getErrorCorrectionLevel());
		}

		if(masked == null) {
			return null;
		}

		//QRtools::markTime('after_mask');

		this.version	= version;
		this.width		= width;
		this.data		= masked;

		return this;
	}

	//----------------------------------------------------------------------
	public function encodeInput(input : QRInput) : QRCode {
		return this.encodeMask(input, -1);
	}

	//----------------------------------------------------------------------
	public function encodeString8bit(string : String, version : Int, level : ErrorCorrection) : QRCode {
		if(string == null) {
			throw 'empty string!';
			return null;
		}

		var input = new QRInput(version, level);

		//var ret = input.append(input, EncodingMode.M8, string.length, string.split(""));
		var ret = input.appendString(EncodingMode.M8, string.length, string);
		if(ret < 0) {
			input = null;
			return null;
		}
		return this.encodeInput(input);
	}

	//----------------------------------------------------------------------
	public function encodeString(string : String, version : Int, level : ErrorCorrection, hint : EncodingMode, casesensitive : Bool) : QRCode {
		if(hint != EncodingMode.M8 && hint != EncodingMode.MKanji) {
			throw 'bad hint';
			return null;
		}

		var input = new QRInput(version, level);
		var ret = QRSplit.splitStringToQRinput(string, input, hint, casesensitive);
		if(ret < 0) {
			return null;
		}
		return this.encodeInput(input);
	}
}

private class FrameFiller {
	public var width : Int;
	public var frame : QRFrame;
	public var x : Int;
	public var y : Int;
	public var dir : Int;
	public var bit : Int;

	//----------------------------------------------------------------------
	public function new(width : Int, frame : QRFrame) {
		this.width = width;
		this.frame = frame;
		this.x = width - 1;
		this.y = width - 1;
		this.dir = -1;
		this.bit = -1;
	}

	//----------------------------------------------------------------------
	public function setFrameAt(at : FramePos, val : Int) : Void {
		this.frame[at.y][at.x] = val;
	}

	//----------------------------------------------------------------------
	public function getFrameAt(at : FramePos) : Int {
		return this.frame[at.y][at.x];
	}

	//----------------------------------------------------------------------
	public function next() : FramePos {
		do {
			if(this.bit == -1) {
				this.bit = 0;
				return { x : this.x, y : this.y };
			}

			var x = this.x;
			var y = this.y;
			var w = this.width;

			if(this.bit == 0) {
				x--;
				this.bit++;
			} else {
				x++;
				y += this.dir;
				this.bit--;
			}

			if(this.dir < 0) {
				if(y < 0) {
					y = 0;
					x -= 2;
					this.dir = 1;
					if(x == 6) {
						x--;
						y = 9;
					}
				}
			} else {
				if(y == w) {
					y = w - 1;
					x -= 2;
					this.dir = -1;
					if(x == 6) {
						x--;
						y -= 8;
					}
				}
			}
			if(x < 0 || y < 0) return null;

			this.x = x;
			this.y = y;

		} while(this.frame[y][x] & 0x80 != 0);

		return { x : x, y : y };
	}
}
private typedef FramePos = {
	var x : Int;
	var y : Int;
}
