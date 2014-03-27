/**
 * ...
 * @author Fabien Antoine
 * @copy Intuitiv Technology
 */

package vault.qrcode;

class QRMask {
	public static inline var N1 : Int = 3;
	public static inline var N2 : Int = 3;
	public static inline var N3 : Int = 40;
	public static inline var N4 : Int = 10;


	public var runLength : Array<Int>;

	//----------------------------------------------------------------------
	public function new() {
		this.runLength = [];
		for(i in 0...QRSpec.widthMax)
			runLength.push(0);
	}

	//----------------------------------------------------------------------
	public function writeFormatInformation(width : Int, frame, mask : Int, level : ErrorCorrection) : Int {
		var blacks = 0;
		var format = QRSpec.getFormatInfo(mask, level);
		var v = 0;
		for(i in 0...8) {
			if(format & 1 != 0) {
				blacks += 2;
				v = 0x85;
			} else {
				v = 0x84;
			}

			frame[8][width - 1 - i] = v;
			if(i < 6) {
				frame[i][8] = v;
			} else {
				frame[i + 1][8] = v;
			}
			format = format >> 1;
		}

		for(i in 0...7) {
			if(format & 1 != 0) {
				blacks += 2;
				v = 0x85;
			} else {
				v = 0x84;
			}

			frame[width - 7 + i][8] = v;
			if(i == 0) {
				frame[8][7] = v;
			} else {
				frame[8][6 - i] = v;
			}

			format = format >> 1;
		}
		return blacks;
	}

	//----------------------------------------------------------------------
	public inline function mask0(x : Int, y : Int) { return (x+y)&1;                       }
	public inline function mask1(x : Int, y : Int) { return (y&1);                          }
	public inline function mask2(x : Int, y : Int) { return (x%3);                          }
	public inline function mask3(x : Int, y : Int) { return (x+y)%3;                       }
	public inline function mask4(x : Int, y : Int) { return ((Std.int(y/2))+(Std.int(x/3)))&1; }
	public inline function mask5(x : Int, y : Int) { return ((x*y)&1)+(x*y)%3;           }
	public inline function mask6(x : Int, y : Int) { return (((x*y)&1)+(x*y)%3)&1;       }
	public inline function mask7(x : Int, y : Int) { return (((x*y)%3)+((x+y)&1))&1;     }

	//----------------------------------------------------------------------
	private function generateMaskNo(maskNo : Int, width : Int, frame : QRFrame) : QRFrame {
		var fill0 : Array<Int> = [];
		for(i in 0...width)
			fill0.push(0);
		var bitMask = [];
		for(i in 0...width)
			bitMask.push(fill0.copy());

		for(y in 0...width) {
			for(x in 0...width) {
				if(frame[y][x] & 0x80 != 0) {
					bitMask[y][x] = 0;
				} else {
					var maskFunc = Reflect.callMethod(this, Reflect.field(this, 'mask' + maskNo), [x, y]);
					bitMask[y][x] = (maskFunc == 0) ? 1 : 0;
				}

			}
		}

		return bitMask;
	}

	//----------------------------------------------------------------------
	//public static function serial(bitFrame) {
		//var codeArr = [];
		//
		//for(line in bitFrame)
			//codeArr[] = line.join("");
		//
		//return gzcompress(join("\n", $codeArr), 9);
	//}

	//----------------------------------------------------------------------
	//public static function unserial($code)
	//{
		//$codeArr = array();
		//
		//$codeLines = explode("\n", gzuncompress($code));
		//foreach ($codeLines as $line)
			//$codeArr[] = str_split($line);
		//
		//return $codeArr;
	//}

	//----------------------------------------------------------------------
	public function makeMaskNo(maskNo : Int, width : Int, s : QRFrame, d : QRFrame, ?maskGenOnly : Bool = false) : Int {
		var b = 0;
		var bitMask = [];

		var fileName = QRCode.cacheDir + 'mask_' + maskNo + '/mask_' + width + '_' + maskNo + '.dat';

		if(QRCode.cacheable) {
			//if(file_exists($fileName)) {
				//$bitMask = self::unserial(file_get_contents($fileName));
			//} else {
				//$bitMask = this.generateMaskNo($maskNo, $width, $s, $d);
				//if (!file_exists(QR_CACHE_DIR.'mask_'.$maskNo))
					//mkdir(QR_CACHE_DIR.'mask_'.$maskNo);
				//file_put_contents($fileName, self::serial($bitMask));
			//}
		} else {
			//bitMask = this.generateMaskNo(maskNo, width, s, d);
			bitMask = this.generateMaskNo(maskNo, width, s);
		}
		if(maskGenOnly)
			return -1;

		while(d.length > 0) d.pop();
		for(i in s) d.push(i.copy());

		for(y in 0...width) {
			for(x in 0...width) {
				if(bitMask[y][x] == 1) {
					d[y][x] = s[y][x] ^ bitMask[y][x];
				}
				b += Std.int(d[y][x] & 1);
			}
		}
		return b;
	}

	//----------------------------------------------------------------------
	public function makeMask(width : Int, frame : QRFrame, maskNo : Int, level : ErrorCorrection) : QRFrame {
		var masked = [];
		for(i in 0...width) {
			var a = [];
			for(j in 0...width)
				a.push(0);
			masked.push(a);
		}
		this.makeMaskNo(maskNo, width, frame, masked);
		this.writeFormatInformation(width, masked, maskNo, level);

		return masked;
	}

	//----------------------------------------------------------------------
	public function calcN1N3(length : Int) : Int {
		var demerit = 0;
		for(i in 0...length) {
			if(this.runLength[i] >= 5) {
				demerit += (N1 + (this.runLength[i] - 5));
			}
			if(i & 1 != 0) {
				if((i >= 3) && (i < (length-2)) && (this.runLength[i] % 3 == 0)) {
					var fact = Std.int(this.runLength[i] / 3);
					if((this.runLength[i-2] == fact) &&
					   (this.runLength[i-1] == fact) &&
					   (this.runLength[i+1] == fact) &&
					   (this.runLength[i+2] == fact)) {
						if((this.runLength[i-3] < 0) || (this.runLength[i-3] >= (4 * fact))) {
							demerit += N3;
						} else if(((i+3) >= length) || (this.runLength[i+3] >= (4 * fact))) {
							demerit += N3;
						}
					}
				}
			}
		}
		return demerit;
	}

	//----------------------------------------------------------------------
	public function evaluateSymbol(width : Int, frame : QRFrame) : Int {
		var head = 0;
		var demerit = 0;

		for(y in 0...width) {
			head = 0;
			this.runLength[0] = 1;

			var frameY = frame[y];
			var frameYM = [];
			if(y > 0)
				frameYM = frame[y-1];

			for(x in 0...width) {
				if((x > 0) && (y > 0)) {
					var b22 = frameY[x] & frameY[x-1] & frameYM[x] & frameYM[x-1];
					var w22 = frameY[x] | frameY[x-1] | frameYM[x] | frameYM[x-1];

					if((b22 | (w22 ^ 1))&1 != 0) {
						demerit += N2;
					}
				}
				if((x == 0) && (frameY[x] & 1 != 0)) {
					this.runLength[0] = -1;
					head = 1;
					this.runLength[head] = 1;
				} else if(x > 0) {
					if((frameY[x] ^ frameY[x-1]) & 1 != 0) {
						head++;
						this.runLength[head] = 1;
					} else {
						this.runLength[head]++;
					}
				}
			}

			demerit += this.calcN1N3(head+1);
		}

		for(x in 0...width) {
			head = 0;
			this.runLength[0] = 1;

			for(y in 0...width) {
				if(y == 0 && (frame[y][x] & 1 != 0)) {
					this.runLength[0] = -1;
					head = 1;
					this.runLength[head] = 1;
				} else if(y > 0) {
					if((frame[y][x] ^ frame[y-1][x]) & 1 != 0) {
						head++;
						this.runLength[head] = 1;
					} else {
						this.runLength[head]++;
					}
				}
			}
			demerit += this.calcN1N3(head+1);
		}
		return demerit;
	}


	//----------------------------------------------------------------------
	public function mask(width : Int, frame, level : ErrorCorrection) : QRFrame {
		var minDemerit = 0xFFFFFF; // 2147483647; // PHP_INT_MAX;
		var bestMaskNum = 0;
		var bestMask = [];

		var checked_masks = [0,1,2,3,4,5,6,7];
		if(QRCode.findFromRandom > 0) {
			var howManuOut = 8 - (QRCode.findFromRandom % 9);
			for(i in 0...howManuOut) {
				var remPos = Math.floor(Math.random() * checked_masks.length);
				checked_masks.splice(remPos, 1);
			}
		}

		bestMask = frame;

		for(i in checked_masks) {
			var mask = [];
			for(j in 0...width) {
				var a = [];
				for(k in 0...width) {
					a.push(0);
				}
				mask.push(a);
			}

			var demerit = 0;
			var blacks = 0;
			blacks  = this.makeMaskNo(i, width, frame, mask);
			blacks += this.writeFormatInformation(width, mask, i, level);
			blacks  = Std.int(100 * blacks / (width * width));
			demerit = Std.int(Std.int(Math.abs(blacks - 50) / 5) * N4);
			demerit += this.evaluateSymbol(width, mask);

			if(demerit < minDemerit) {
				minDemerit = demerit;
				bestMask = mask;
				bestMaskNum = i;
			}
		}

		return bestMask;
	}
}
