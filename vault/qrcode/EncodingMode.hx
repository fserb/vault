/**
 * ...
 * @author Fabien Antoine
 */

package vault.qrcode;

enum EncodingMode {
	MNul;
	MNum;
	MAn;
	M8;
	MKanji;
	MStructure;
}

class EncodingModeTools {
	public static function toInt(em : EncodingMode) : Int {
		return switch(em) {
			case MNul:			-1;
			case MNum:			0;
			case MAn:			1;
			case M8:			2;
			case MKanji:		3;
			case MStructure:	4;
		}
	}
}
