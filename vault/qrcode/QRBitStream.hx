/**
 * ...
 * @author Fabien Antoine
 * @copy Intuitiv Technology
 */

package vault.qrcode;

class QRBitStream {
	public var data : Array<Int>;

	public function new() {
		this.data = new Array<Int>();
	}

	//----------------------------------------------------------------------
	public function size() : Int {
		return this.data.length;
	}

	//----------------------------------------------------------------------
	public function allocate(setLength : Int) : Int {
		this.data = [];
		for(i in 0...setLength)
			this.data.push(0);
		return 0;
	}

	//----------------------------------------------------------------------
	public static function newFromNum(bits : Int, num : Int) : QRBitStream {
		var bstream = new QRBitStream();
		bstream.allocate(bits);

		var mask = 1 << (bits - 1);
		for(i in 0...bits) {
			if(num & mask != 0) {
				bstream.data[i] = 1;
			} else {
				bstream.data[i] = 0;
			}
			mask = mask >> 1;
		}
		return bstream;
	}

	//----------------------------------------------------------------------
	public static function newFromBytes(size : Int, data : Array<Int>) : QRBitStream {
		var bstream = new QRBitStream();
		bstream.allocate(size * 8);
		var p = 0;
		for(i in 0...size) {
			var mask = 0x80;
			for(j in 0...8) {
				if(data[i] & mask != 0) {
					bstream.data[p] = 1;
				} else {
					bstream.data[p] = 0;
				}
				p++;
				mask = mask >> 1;
			}
		}
		return bstream;
	}

	//----------------------------------------------------------------------
	public function append(arg : QRBitStream) : Int {
		if(arg == null) {
			return -1;
		}

		if(arg.size() == 0) {
			return 0;
		}

		if(this.size() == 0) {
			this.data = arg.data.copy();
			return 0;
		}

		this.data = this.data.concat(arg.data);
		return 0;
	}

	//----------------------------------------------------------------------
	public function appendNum(bits : Int, num : Int) : Int {
		if(bits == 0)
			return 0;

		var b = QRBitStream.newFromNum(bits, num);

		if(b == null)
			return -1;

		var ret = this.append(b);
		b = null;

		return ret;
	}

	//----------------------------------------------------------------------
	public function appendBytes(size : Int, data : Array<Int>) : Int {
		if(size == 0)
			return 0;

		var b = QRBitStream.newFromBytes(size, data);

		if(b == null)
			return -1;

		var ret = this.append(b);
		b = null;

		return ret;
	}

	//----------------------------------------------------------------------
	public function toByte() : Array<Int> {
		var size = this.size();

		if(size == 0) {
			return [];
		}

		var data = [];
		for(i in 0...Std.int((size + 7) / 8))
			data.push(0);
		var bytes = Std.int(size / 8);

		var p = 0;

		for(i in 0...bytes) {
			var v = 0;
			for(j in 0...8) {
				v = v << 1;
				v |= this.data[p];
				p++;
			}
			data[i] = v;
		}

		if(size & 7 != 0) {
			var v = 0;
			for(j in 0...Std.int(size & 7)) {
				v = v << 1;
				v |= this.data[p];
				p++;
			}
			data[bytes] = v;
		}
		return data;
	}
}
