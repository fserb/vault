/**
 * ...
 * @author Fabien Antoine
 * @copy Intuitiv Technology
 */

package vault.qrcode;

typedef QRFrame = Array<Array<Int>>;

class QRFrameTools {
	public static function set(srctab : QRFrame, x : Int, y : Int, repl : Array<Int>, ?replLen : Int = -1) : Void {
		var newRepl = (replLen < 0 ? repl : repl.slice(0, replLen));
		var length	= (replLen < 0 ? repl.length : replLen);
		srctab[y].splice(x, length);
		for(i in 0...newRepl.length) {
			srctab[y].insert(x + i, newRepl[i]);
		}
	}
}
