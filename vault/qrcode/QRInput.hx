/**
 * ...
 * @author Fabien Antoine
 * @copy Intuitiv Technology
 */

package vault.qrcode;

using vault.qrcode.ErrorCorrection;

class QRInput {
	public static inline var structureHeaderBits : Int	= 20;
    public static inline var maxStructuredSymbols : Int	= 16;


	public var items : Array<QRInputItem>;

	private var version : Int;
	private var level : ErrorCorrection;

	//----------------------------------------------------------------------
	public function new(?version : Int = 0, ?level : ErrorCorrection) {
		if(level == null) level = ErrorCorrection.EC_L;

		if(version < 0 || version > QRSpec.versionMax || level.toInt() > ErrorCorrection.EC_H.toInt()) {
			throw 'Invalid version no';
		}

		this.items		= [];
		this.version	= version;
		this.level		= level;
	}

	//----------------------------------------------------------------------
	public function getVersion() : Int {
		return this.version;
	}

	//----------------------------------------------------------------------
	public function setVersion(version : Int) : Int {
		if(version < 0 || version > QRSpec.versionMax) {
			throw 'Invalid version no';
			return -1;
		}
		this.version = version;
		return 0;
	}

	//----------------------------------------------------------------------
	public function getErrorCorrectionLevel() : ErrorCorrection {
		return this.level;
	}

	//----------------------------------------------------------------------
	public function setErrorCorrectionLevel(level : ErrorCorrection) : Int {
		if(level.toInt() > ErrorCorrection.EC_H.toInt()) {
			throw 'Invalid ECLEVEL';
			return -1;
		}
		this.level = level;
		return 0;
	}

	//----------------------------------------------------------------------
	public function appendEntry(entry : QRInputItem) : Void {
		this.items.push(entry);
	}

	//----------------------------------------------------------------------
	public function append(mode : EncodingMode, size : Int, data : Array<Int>) : Int {
		try {
			this.items.push(new QRInputItem(mode, size, data));
			return 0;
		} catch(e : Dynamic) {
			return -1;
		}
	}

	//----------------------------------------------------------------------
	public function appendString(mode : EncodingMode, size : Int, data : String) : Int {
		var a = [];
		for(i in 0...data.length) a.push(data.charCodeAt(i));
		return this.append(mode, size, a);
	}


	//----------------------------------------------------------------------

	public function insertStructuredAppendHeader(size : Int, index : Int, parity : Int) : Int {
		if(size > maxStructuredSymbols) {
			throw 'insertStructuredAppendHeader wrong size';
		}

		if(index <= 0 || index > maxStructuredSymbols) {
			throw 'insertStructuredAppendHeader wrong index';
		}

		var buf = [size, index, parity];

		try {
			var entry = new QRInputItem(EncodingMode.MStructure, 3, buf);
			this.items.unshift(entry);
			return 0;
		} catch(e : Dynamic) {
			return -1;
		}
	}

	//----------------------------------------------------------------------
	public function calcParity() : Int {
		var parity = 0;

		for(item in this.items) {
			if(item.mode != EncodingMode.MStructure) {
				var i : Int = item.size - 1;
				while(i >= 0) {
					parity ^= item.data[i];
					i--;
				}
			}
		}

		return parity;
	}

	//----------------------------------------------------------------------
	public static function checkModeNum(size : Int, data : Array<Int>) : Bool {
		for(i in 0...size) {
			if((data[i] < '0'.charCodeAt(0)) || (data[i] > '9'.charCodeAt(0))) {
				return false;
			}
		}
		return true;
	}

	//----------------------------------------------------------------------
	public static function estimateBitsModeNum(size : Int) : Int {
		var w = Std.int(size / 3);
		var bits = w * 10;

		switch(size - w * 3) {
			case 1: bits += 4;
			case 2: bits += 7;
			default:
		}

		return bits;
	}

	//----------------------------------------------------------------------
	public static var anTable : Array<Int> = [
		-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
		-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
		36, -1, -1, -1, 37, 38, -1, -1, -1, -1, 39, 40, -1, 41, 42, 43,
		 0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 44, -1, -1, -1, -1, -1,
		-1, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24,
		25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, -1, -1, -1, -1, -1,
		-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
		-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
	];

	//----------------------------------------------------------------------
	public static function lookAnTable(c) : Int {
		return ((c > 127)? -1 : anTable[c]);
	}

	//----------------------------------------------------------------------
	public static function checkModeAn(size : Int, data : Array<Int>) : Bool {
		for(i in 0...size) {
			if(lookAnTable(data[i]) == -1) {
				return false;
			}
		}
		return true;
	}

	//----------------------------------------------------------------------
	public static function estimateBitsModeAn(size : Int) : Int {
		var w = Std.int(size / 2);
		var bits = w * 11;

		if(size & 1 != 0) {
			bits += 6;
		}

		return bits;
	}

	//----------------------------------------------------------------------
	public static function estimateBitsMode8(size : Int) : Int {
		return size * 8;
	}

	//----------------------------------------------------------------------
	public static function estimateBitsModeKanji(size : Int) {
		return Std.int((size / 2) * 13);
	}

	//----------------------------------------------------------------------
	public static function checkModeKanji(size : Int, data : Array<Int>) : Bool {
		if(size & 1 != 0)
			return false;

		var i = 0;
		while(i < size) {
			var val = ((data[i] << 8) | data[i+1]);
			if( val < 0x8140
			|| (val > 0x9ffc && val < 0xe040)
			|| val > 0xebbf) {
				return false;
			}
			i += 2;
		}
		return true;
	}

	/***********************************************************************
	 * Validation
	 **********************************************************************/

	public static function check(mode : EncodingMode, size : Int, data : Array<Int>) : Bool {
		if(size <= 0)
			return false;

		return switch(mode) {
			case EncodingMode.MNum:       checkModeNum(size, data);
			case EncodingMode.MAn:        checkModeAn(size, data);
			case EncodingMode.MKanji:     checkModeKanji(size, data);
			case EncodingMode.M8:         true;
			case EncodingMode.MStructure: true;
			default: false;
		}
	}


	//----------------------------------------------------------------------
	public function estimateBitStreamSize(version : Int) : Int {
		var bits = 0;
		for(item in this.items) {
			bits += item.estimateBitStreamSizeOfEntry(version);
		}
		return bits;
	}

	//----------------------------------------------------------------------
	public function estimateVersion() : Int {
		var version = 0;
		var prev = 0;
		do {
			prev = version;
			var bits = this.estimateBitStreamSize(prev);
			version = QRSpec.getMinimumVersion(Std.int((bits + 7) / 8), this.level);
			if(version < 0) {
				return -1;
			}
		} while(version > prev);
		return version;
	}

	//----------------------------------------------------------------------
	public static function lengthOfCode(mode : EncodingMode, version : Int, bits : Int) : Int {
		var payload = bits - 4 - QRSpec.lengthIndicator(mode, version);
		var size = 0;
		switch(mode) {
			case EncodingMode.MNum:
				var chunks = Std.int(payload / 10);
				var remain = payload - chunks * 10;
				size = chunks * 3;
				if(remain >= 7) {
					size += 2;
				} else if(remain >= 4) {
					size += 1;
				}
			case EncodingMode.MAn:
				var chunks = Std.int(payload / 11);
				var remain = payload - chunks * 11;
				size = chunks * 2;
				if(remain >= 6)
					size++;
			case EncodingMode.M8:
				size = Std.int(payload / 8);
			case EncodingMode.MKanji:
				size = Std.int((payload / 13) * 2);
			case EncodingMode.MStructure:
				size = Std.int(payload / 8);
			default:
				size = 0;
		}

		var maxsize = QRSpec.maximumWords(mode, version);
		if(size < 0) size = 0;
		if(size > maxsize) size = maxsize;
		return size;
	}

	//----------------------------------------------------------------------
	public function createBitStream() : Int {
		var total = 0;
		for(item in this.items) {
			var bits = item.encodeBitStream(this.version);
			if(bits < 0)
				return -1;
			total += bits;
		}
		return total;
	}

	//----------------------------------------------------------------------
	public function convertData() : Int {
		var ver = this.estimateVersion();
		if(ver > this.getVersion()) {
			this.setVersion(ver);
		}

		while(true) {
			var bits = this.createBitStream();

			if(bits < 0)
				return -1;

			ver = QRSpec.getMinimumVersion(Std.int((bits + 7) / 8), this.level);
			if(ver < 0) {
				throw 'WRONG VERSION';
				return -1;
			} else if(ver > this.getVersion()) {
				this.setVersion(ver);
			} else {
				break;
			}
		}
		return 0;
	}

	//----------------------------------------------------------------------
	public function appendPaddingBit(bstream : QRBitStream) : Int {
		var bits = bstream.size();
		var maxwords = QRSpec.getDataLength(this.version, this.level);
		var maxbits = maxwords * 8;
		if(maxbits == bits) {
			return 0;
		}
		if(maxbits - bits < 5) {
			return bstream.appendNum(maxbits - bits, 0);
		}
		bits += 4;

		var words = Std.int((bits + 7) / 8);
		var padding = new QRBitStream();
		var ret = padding.appendNum(words * 8 - bits + 4, 0);

		if(ret < 0)
			return ret;

		var padlen = Std.int(maxwords - words);

		if(padlen > 0) {
			var padbuf = [];
			for(i in 0...padlen) {
				padbuf.push(i&1 != 0 ? 0x11 : 0xec);
			}

			ret = padding.appendBytes(padlen, padbuf);

			if(ret < 0)
				return ret;
		}
		ret = bstream.append(padding);
		return ret;
	}

	//----------------------------------------------------------------------
	public function mergeBitStream() : QRBitStream {
		if(this.convertData() < 0) {
			return null;
		}

		var bstream = new QRBitStream();

		for(item in this.items) {
			var ret = bstream.append(item.bstream);
			if(ret < 0) {
				return null;
			}
		}
		return bstream;
	}

	//----------------------------------------------------------------------
	public function getBitStream() : QRBitStream {
		var bstream = this.mergeBitStream();

		if(bstream == null) {
			return null;
		}

		var ret = this.appendPaddingBit(bstream);
		if(ret < 0) {
			return null;
		}
		return bstream;
	}

	//----------------------------------------------------------------------
	public function getByteStream() : Array<Int> {
		var bstream = this.getBitStream();
		if(bstream == null) {
			return null;
		}
		return bstream.toByte();
	}
}

private class QRInputItem {
	public var mode : EncodingMode;
	public var size : Int;
	public var data : Array<Int>;
	public var bstream : QRBitStream;

	public function new(mode : EncodingMode, size : Int, data : Array<Int>, ?bstream : QRBitStream) {
		var setData = data.slice(0, size);

		if(setData.length < size) {
			for(i in 0...(size - setData.length))
				setData.push(0);
		}

		if(!QRInput.check(mode, size, setData)) {
			throw 'Error m:' + mode + ',s:' + size + ',d:' + setData.join(",");
		}

		this.mode		= mode;
		this.size		= size;
		this.data		= setData;
		this.bstream	= bstream;
	}

	//----------------------------------------------------------------------
	public function encodeModeNum(version : Int) : Int {
		try {
			var words = Std.int(this.size / 3);
			var bs = new QRBitStream();

			var val = 0x1;
			bs.appendNum(4, val);
			bs.appendNum(QRSpec.lengthIndicator(EncodingMode.MNum, version), this.size);

			var cca0 = '0'.charCodeAt(0);

			for(i in 0...words) {
				val  = (this.data[i*3  ] - cca0) * 100;
				val += (this.data[i*3+1] - cca0) * 10;
				val += (this.data[i*3+2] - cca0);
				bs.appendNum(10, val);
			}

			if(this.size - words * 3 == 1) {
				val = this.data[words*3] - cca0;
				bs.appendNum(4, val);
			} else if(this.size - words * 3 == 2) {
				val  = (this.data[words*3  ] - cca0) * 10;
				val += (this.data[words*3+1] - cca0);
				bs.appendNum(7, val);
			}

			this.bstream = bs;
			return 0;
		} catch(e : Dynamic) {
			return -1;
		}
	}

	//----------------------------------------------------------------------
	public function encodeModeAn(version : Int) : Int {
		try {
			var words = Std.int(this.size / 2);
			var bs = new QRBitStream();

			bs.appendNum(4, 0x02);
			bs.appendNum(QRSpec.lengthIndicator(EncodingMode.MAn, version), this.size);

			var val = 0;
			for(i in 0...words) {
				val  = QRInput.lookAnTable(this.data[i*2  ]) * 45;
				val += QRInput.lookAnTable(this.data[i*2+1]);
				bs.appendNum(11, val);
			}

			if(this.size & 1 != 0) {
				val = QRInput.lookAnTable(this.data[words * 2]);
				bs.appendNum(6, val);
			}

			this.bstream = bs;
			return 0;

		} catch(e : Dynamic) {
			return -1;
		}
	}

	//----------------------------------------------------------------------
	public function encodeMode8(version : Int) : Int {
		try {
			var bs = new QRBitStream();

			bs.appendNum(4, 0x4);
			bs.appendNum(QRSpec.lengthIndicator(EncodingMode.M8, version), this.size);

			for(i in 0...this.size) {
				bs.appendNum(8, this.data[i]);
			}

			this.bstream = bs;
			return 0;

		} catch(e : Dynamic) {
			return -1;
		}
	}

	//----------------------------------------------------------------------
	public function encodeModeKanji(version : Int) : Int {
		try {
			var bs = new QRBitStream();

			bs.appendNum(4, 0x8);
			bs.appendNum(QRSpec.lengthIndicator(EncodingMode.MKanji, version), Std.int(this.size / 2));

			var i = 0;
			while(i < this.size) {
				var val = (this.data[i] << 8) | this.data[i+1];
				if(val <= 0x9ffc) {
					val -= 0x8140;
				} else {
					val -= 0xc140;
				}

				var h = (val >> 8) * 0xc0;
				val = (val & 0xff) + h;

				bs.appendNum(13, val);

				i += 2;
			}

			this.bstream = bs;
			return 0;
		} catch(e : Dynamic) {
			return -1;
		}
	}

	//----------------------------------------------------------------------
	public function encodeModeStructure() : Int {
		try {
			var bs =  new QRBitStream();

			bs.appendNum(4, 0x03);
			bs.appendNum(4, this.data[1] - 1);
			bs.appendNum(4, this.data[0] - 1);
			bs.appendNum(8, this.data[2]);

			this.bstream = bs;
			return 0;

		} catch(e : Dynamic) {
			return -1;
		}
	}

	//----------------------------------------------------------------------
	public function estimateBitStreamSizeOfEntry(version : Int) : Int {
		var bits = 0;
		if(version == 0)
			version = 1;

		switch(this.mode) {
			case EncodingMode.MNum:			bits = QRInput.estimateBitsModeNum(this.size);
			case EncodingMode.MAn:			bits = QRInput.estimateBitsModeAn(this.size);
			case EncodingMode.M8:			bits = QRInput.estimateBitsMode8(this.size);
			case EncodingMode.MKanji:		bits = QRInput.estimateBitsModeKanji(this.size);
			case EncodingMode.MStructure:	return QRInput.structureHeaderBits;
			default: return 0;
		}

		var l = QRSpec.lengthIndicator(this.mode, version);
		var m = 1 << l;
		var num = Std.int((this.size + m - 1) / m);

		bits += num * (4 + l);
		return bits;
	}

	//----------------------------------------------------------------------
	public function encodeBitStream(version : Int) : Int {
		try {
			this.bstream = null;
			var words = QRSpec.maximumWords(this.mode, version);

			if(this.size > words) {
				var st1 = new QRInputItem(this.mode, words, this.data);
				var st2 = new QRInputItem(this.mode, this.size - words, this.data.slice(words));

				st1.encodeBitStream(version);
				st2.encodeBitStream(version);

				this.bstream = new QRBitStream();
				this.bstream.append(st1.bstream);
				this.bstream.append(st2.bstream);

				st1 = null;
				st2 = null;

			} else {

				var ret = 0;

				switch(this.mode) {
					case EncodingMode.MNum:			ret = this.encodeModeNum(version);
					case EncodingMode.MAn:			ret = this.encodeModeAn(version);
					case EncodingMode.M8:			ret = this.encodeMode8(version);
					case EncodingMode.MKanji:		ret = this.encodeModeKanji(version);
					case EncodingMode.MStructure:	ret = this.encodeModeStructure();
					default:
				}

				if(ret < 0)
					return -1;
			}
			return this.bstream.size();
		} catch(e : Dynamic) {
			return -1;
		}
	}
}
