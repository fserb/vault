/**
 * ...
 * @author Fabien Antoine
 */

package vault.qrcode;

enum ErrorCorrection {
	EC_L;
	EC_M;
	EC_Q;
	EC_H;
}

class ErrorCorrectionTools {
	public static function toInt(ec : ErrorCorrection) : Int {
		return switch(ec) {
			case EC_L:	0;
			case EC_M:	1;
			case EC_Q:	2;
			case EC_H:	3;
		}
	}
}
