/**
 * ...
 * @author Fabien Antoine
 * @copy Intuitiv Technology
 */

package vault.qrcode;

class QRTools {
	//----------------------------------------------------------------------
	public static function binarize(frame : QRFrame) : QRFrame {
		var len = frame.length;
		var bin = [];

		for(frameLine in frame) {
			var tmp = [];
			for(i in 0...len) {
				tmp.push(frameLine[i] & 1 != 0 ? 1 : 0);
			}
			bin.push(tmp);
		}
		return bin;
	}
}
