/**
 * ...
 * @author Fabien Antoine
 * @copy Intuitiv Technology
 */

package vault.qrcode;

class QRRawCode {
	public var version : Int;
	public var datacode : Array<Int>;
	public var ecccode : Array<Int>;
	public var blocks : Int;
	public var rsblocks : Array<QRRsBlock>;
	public var count : Int;
	public var dataLength : Int;
	public var eccLength : Int;
	public var b1 : Int;

	//----------------------------------------------------------------------
	public function new(input : QRInput) {
		var spec = [0, 0, 0, 0, 0];

		this.datacode = new Array<Int>();

		this.datacode = input.getByteStream();
		if(this.datacode == null) {
			throw 'null input string';
		}

		QRSpec.getEccSpec(input.getVersion(), input.getErrorCorrectionLevel(), spec);
		this.version 		= input.getVersion();
		this.b1 			= QRSpec.rsBlockNum1(spec);
		this.dataLength 	= QRSpec.rsDataLength(spec);
		this.eccLength 		= QRSpec.rsEccLength(spec);
		this.blocks 		= QRSpec.rsBlockNum(spec);
		this.rsblocks		= [];
		this.ecccode 		= [];
		for(i in 0...this.eccLength)
			this.ecccode.push(0);

		var ret = this.init(spec);
		if(ret < 0) {
			throw 'block alloc error';
		}
		this.count = 0;
	}

	//----------------------------------------------------------------------
	public function init(spec : Array<Int>) : Int {
		var dl = QRSpec.rsDataCodes1(spec);
		var el = QRSpec.rsEccCodes1(spec);
		var rs = QRRs.init_rs(8, 0x11d, 0, 1, el, 255 - dl - el);


		var blockNo = 0;
		var dataPos = 0;
		var eccPos = 0;
		for(i in 0...QRSpec.rsBlockNum1(spec)) {
			var ecc = this.ecccode.slice(eccPos);
			this.rsblocks[blockNo] = new QRRsBlock(dl, this.datacode.slice(dataPos), el, ecc, rs);

			var newEcc : Array<Int> = (eccPos == 0 ? [] : this.ecccode.slice(0, eccPos));

			this.ecccode = newEcc.concat(ecc);

			dataPos += dl;
			eccPos += el;
			blockNo++;
		}
		if(QRSpec.rsBlockNum2(spec) == 0)
			return 0;

		dl = QRSpec.rsDataCodes2(spec);
		el = QRSpec.rsEccCodes2(spec);

		rs = QRRs.init_rs(8, 0x11d, 0, 1, el, 255 - dl - el);

		if(rs == null) return -1;

		for(i in 0...QRSpec.rsBlockNum2(spec)) {
			var ecc = this.ecccode.slice(eccPos);
			this.rsblocks[blockNo] = new QRRsBlock(dl, this.datacode.slice(dataPos), el, ecc, rs);
			this.ecccode = this.ecccode.slice(0, eccPos).concat(ecc);

			dataPos += dl;
			eccPos += el;
			blockNo++;
		}

		return 0;
	}

	//----------------------------------------------------------------------
	public function getCode() : Int {
		var ret;
		if(this.count < this.dataLength) {
			var row = Std.int(this.count % this.blocks);
			var col = Std.int(this.count / this.blocks);
			if(col >= this.rsblocks[0].dataLength) {
				row += this.b1;
			}
			ret = this.rsblocks[row].data[col];
		} else if(this.count < this.dataLength + this.eccLength) {
			var row = Std.int((this.count - this.dataLength) % this.blocks);
			var col = Std.int((this.count - this.dataLength) / this.blocks);
			ret = this.rsblocks[row].ecc[col];

		} else {
			return 0;
		}
		this.count++;

		return ret;
	}
}

private class QRRs {
	public static var items : Array<QRRsItem> = [];

	//----------------------------------------------------------------------
	public static function init_rs(symsize, gfpoly, fcr, prim, nroots, pad) : QRRsItem {
		for(rs in items) {
			if(rs.pad != pad)       continue;
			if(rs.nroots != nroots) continue;
			if(rs.mm != symsize)    continue;
			if(rs.gfpoly != gfpoly) continue;
			if(rs.fcr != fcr)       continue;
			if(rs.prim != prim)     continue;
			return rs;
		}

		var rs = QRRsItem.init_rs_char(symsize, gfpoly, fcr, prim, nroots, pad);
		items.unshift(rs);
		return rs;
	}
}

private class QRRsBlock {
	public var dataLength : Int;
	public var data : Array<Int>;
	public var eccLength : Int;
	public var ecc : Array<Int>;

	public function new(dl : Int, data : Array<Int>, el : Int, ecc : Array<Int>, rs : QRRsItem) {
		rs.encode_rs_char(data, ecc);
		this.dataLength	= dl;
		this.data		= data;
		this.eccLength	= el;
		this.ecc		= ecc;
	}
}

private class QRRsItem {
	public var mm : Int;            	// Bits per symbol
	public var nn : Int;            	// Symbols per block (= (1<<mm)-1)
	public var alpha_to : Array<Int>; 	// log lookup table
	public var index_of : Array<Int>; 	// Antilog lookup table
	public var genpoly : Array<Int>;  	// Generator polynomial
	public var nroots : Int;              // Number of generator roots = number of parity symbols
	public var fcr : Int;                 // First consecutive root, index form
	public var prim : Int;                // Primitive element, index form
	public var iprim : Int;               // prim-th root of 1, index form
	public var pad : Int;                 // Padding bytes in shortened block
	public var gfpoly : Int;

	public function new() {
		this.alpha_to = [];
		this.index_of = [];
		this.genpoly = [];
	}

	//----------------------------------------------------------------------
	public function modnn(x : Int) : Int {
		while(x >= this.nn) {
			x -= this.nn;
			x = (x >> this.mm) + (x & this.nn);
		}
		return x;
	}

	//----------------------------------------------------------------------
	public static function init_rs_char(symsize : Int, gfpoly : Int, fcr : Int, prim : Int, nroots : Int, pad : Int) : QRRsItem {
		// Common code for intializing a Reed-Solomon control block (char or int symbols)
		// Copyright 2004 Phil Karn, KA9Q
		// May be used under the terms of the GNU Lesser General Public License (LGPL)

		var rs = null;

		// Check parameter ranges
		if(symsize < 0 || symsize > 8)                   return rs;
		if(fcr < 0 || fcr >= (1<<symsize))               return rs;
		if(prim <= 0 || prim >= (1<<symsize))            return rs;
		if(nroots < 0 || nroots >= (1<<symsize))         return rs; // Can't have more roots than symbol values!
		if(pad < 0 || pad >= ((1<<symsize) -1 - nroots)) return rs; // Too much padding

		rs = new QRRsItem();
		rs.mm = symsize;
		rs.nn = (1<<symsize)-1;
		rs.pad = pad;

		rs.alpha_to = [];
		rs.index_of = [];
		for(i in 0...(rs.nn + 1)) {
			rs.alpha_to.push(0);
			rs.index_of.push(0);
		}

		// PHP style macro replacement ;)
		var NN = rs.nn;
		var A0 = NN;

		// Generate Galois field lookup tables
		rs.index_of[0] = A0; // log(zero) = -inf
		rs.alpha_to[A0] = 0; // alpha**-inf = 0
		var sr = 1;

		for(i in 0...rs.nn) {
			rs.index_of[sr] = i;
			rs.alpha_to[i] = sr;
			sr <<= 1;
			if(sr & (1<<symsize) != 0) {
				sr ^= gfpoly;
			}
			sr &= rs.nn;
		}

		if(sr != 1){
			// field generator polynomial is not primitive!
			rs = null;
			return rs;
		}

		/* Form RS code generator polynomial from its roots */
		rs.genpoly = [];
		for(i in 0...(nroots + 1))
			rs.genpoly.push(0);

		rs.fcr = fcr;
		rs.prim = prim;
		rs.nroots = nroots;
		rs.gfpoly = gfpoly;

		/* Find prim-th root of 1, used in decoding */
		var iprim = 1;
		while((iprim % prim) != 0)
			iprim += rs.nn;

		rs.iprim = Std.int(iprim / prim);
		rs.genpoly[0] = 1;

		var root = fcr * prim;
		for(i in 0...nroots) {
			rs.genpoly[i+1] = 1;

			// Multiply rs->genpoly[] by  @**(root + x)
			var j = i;
			while(j > 0) {
				if(rs.genpoly[j] != 0) {
					rs.genpoly[j] = rs.genpoly[j-1] ^ rs.alpha_to[rs.modnn(rs.index_of[rs.genpoly[j]] + root)];
				} else {
					rs.genpoly[j] = rs.genpoly[j-1];
				}
				j--;
			}
			// rs->genpoly[0] can never be zero
			rs.genpoly[0] = rs.alpha_to[rs.modnn(rs.index_of[rs.genpoly[0]] + root)];

			root += prim;
		}

		// convert rs->genpoly[] to index form for quicker encoding
		for(i in 0...(nroots + 1)) {
			rs.genpoly[i] = rs.index_of[rs.genpoly[i]];
		}

		return rs;
	}

	//----------------------------------------------------------------------
	public function encode_rs_char(data : Array<Int>, parity : Array<Int>) : Void {
		var MM       = this.mm;
		var NN       = this.nn;
		var ALPHA_TO = this.alpha_to;
		var INDEX_OF = this.index_of;
		var GENPOLY  = this.genpoly;
		var NROOTS   = this.nroots;
		var FCR      = this.fcr;
		var PRIM     = this.prim;
		var IPRIM    = this.iprim;
		var PAD      = this.pad;
		var A0       = NN;

		while(parity.length > 0) parity.pop();
		for(i in 0...NROOTS)
			parity.push(0);

		for(i in 0...(NN-NROOTS-PAD)) {
			var feedback = INDEX_OF[data[i] ^ parity[0]];
			if(feedback != A0) {
				// feedback term is non-zero

				// This line is unnecessary when GENPOLY[NROOTS] is unity, as it must
				// always be for the polynomials constructed by init_rs()
				feedback = this.modnn(NN - GENPOLY[NROOTS] + feedback);

				for(j in 1...NROOTS) {
					parity[j] ^= ALPHA_TO[this.modnn(feedback + GENPOLY[NROOTS - j])];
				}
			}

			// Shift
			parity.shift();
			if(feedback != A0) {
				parity.push(ALPHA_TO[this.modnn(feedback + GENPOLY[0])]);
			} else {
				parity.push(0);
			}
		}
	}
}
