/**
 * ...
 * @author Fabien Antoine
 * @copy Intuitiv Technology
 */

package vault.qrcode;

class QREncode {
	public var casesensitive : Bool;
	public var eightbit : Bool;

	public var version : Int;
	public var size : Int;
	public var margin : Int;

	//public var structured : Int; // not supported yet

	public var level : ErrorCorrection;
	public var hint : EncodingMode;

	//----------------------------------------------------------------------
	public function new(?level : ErrorCorrection = null, ?size : Int = 3, ?margin : Int = 4) : Void {
		this.casesensitive	= true;
		this.eightbit		= false;
		this.version		= 0;
		this.size			= size;
		this.margin			= margin;
		//this.structured		= 0;
		this.level			= (level == null ? ErrorCorrection.EC_L : level);
		this.hint			= EncodingMode.M8;
	}

	//----------------------------------------------------------------------
	public function encodeRAW(intext : String) : QRFrame {
		var code = new QRCode();
		if(this.eightbit) {
			code.encodeString8bit(intext, this.version, this.level);
		} else {
			code.encodeString(intext, this.version, this.level, this.hint, this.casesensitive);
		}
		return code.data;
	}

	//----------------------------------------------------------------------
	public function encode(intext : String) : QRFrame {
		var code = new QRCode();
		if(this.eightbit) {
			code.encodeString8bit(intext, this.version, this.level);
		} else {
			code.encodeString(intext, this.version, this.level, this.hint, this.casesensitive);
		}
		return QRTools.binarize(code.data);
	}
}
