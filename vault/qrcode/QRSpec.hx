/**
 * ...
 * @author Fabien Antoine
 */

package vault.qrcode;

using vault.qrcode.EncodingMode;
using vault.qrcode.ErrorCorrection;
using vault.qrcode.QRFrame;

class QRSpec {
	public static inline var versionMax : Int	= 40;
	public static inline var widthMax : Int		= 177;

    public static inline var capWidth : Int		= 0;
    public static inline var capWords : Int		= 1;
    public static inline var capReminder : Int	= 2;
    public static inline var capEC : Int		= 3;

	public static var capacity : Array<Array<Dynamic>> = [
            [  0,    0, 0, [   0,    0,    0,    0]],
            [ 21,   26, 0, [   7,   10,   13,   17]], // 1
            [ 25,   44, 7, [  10,   16,   22,   28]],
            [ 29,   70, 7, [  15,   26,   36,   44]],
            [ 33,  100, 7, [  20,   36,   52,   64]],
            [ 37,  134, 7, [  26,   48,   72,   88]], // 5
            [ 41,  172, 7, [  36,   64,   96,  112]],
            [ 45,  196, 0, [  40,   72,  108,  130]],
            [ 49,  242, 0, [  48,   88,  132,  156]],
            [ 53,  292, 0, [  60,  110,  160,  192]],
            [ 57,  346, 0, [  72,  130,  192,  224]], //10
            [ 61,  404, 0, [  80,  150,  224,  264]],
            [ 65,  466, 0, [  96,  176,  260,  308]],
            [ 69,  532, 0, [ 104,  198,  288,  352]],
            [ 73,  581, 3, [ 120,  216,  320,  384]],
            [ 77,  655, 3, [ 132,  240,  360,  432]], //15
            [ 81,  733, 3, [ 144,  280,  408,  480]],
            [ 85,  815, 3, [ 168,  308,  448,  532]],
            [ 89,  901, 3, [ 180,  338,  504,  588]],
            [ 93,  991, 3, [ 196,  364,  546,  650]],
            [ 97, 1085, 3, [ 224,  416,  600,  700]], //20
            [101, 1156, 4, [ 224,  442,  644,  750]],
            [105, 1258, 4, [ 252,  476,  690,  816]],
            [109, 1364, 4, [ 270,  504,  750,  900]],
            [113, 1474, 4, [ 300,  560,  810,  960]],
            [117, 1588, 4, [ 312,  588,  870, 1050]], //25
            [121, 1706, 4, [ 336,  644,  952, 1110]],
            [125, 1828, 4, [ 360,  700, 1020, 1200]],
            [129, 1921, 3, [ 390,  728, 1050, 1260]],
            [133, 2051, 3, [ 420,  784, 1140, 1350]],
            [137, 2185, 3, [ 450,  812, 1200, 1440]], //30
            [141, 2323, 3, [ 480,  868, 1290, 1530]],
            [145, 2465, 3, [ 510,  924, 1350, 1620]],
            [149, 2611, 3, [ 540,  980, 1440, 1710]],
            [153, 2761, 3, [ 570, 1036, 1530, 1800]],
            [157, 2876, 0, [ 570, 1064, 1590, 1890]], //35
            [161, 3034, 0, [ 600, 1120, 1680, 1980]],
            [165, 3196, 0, [ 630, 1204, 1770, 2100]],
            [169, 3362, 0, [ 660, 1260, 1860, 2220]],
            [173, 3532, 0, [ 720, 1316, 1950, 2310]],
            [177, 3706, 0, [ 750, 1372, 2040, 2430]] //40
        ];

        //----------------------------------------------------------------------
        public static function getDataLength(version : Int, level : ErrorCorrection) : Int {
            return Std.int(capacity[version][capWords] - capacity[version][capEC][level.toInt()]);
        }

        //----------------------------------------------------------------------
        public static function getECCLength(version : Int, level : ErrorCorrection) : Int {
            return capacity[version][capEC][level.toInt()];
        }

        //----------------------------------------------------------------------
        public static function getWidth(version : Int) : Int {
            return capacity[version][capWidth];
        }

        //----------------------------------------------------------------------
        public static function getRemainder(version : Int) : Int {
            return capacity[version][capReminder];
        }

        //----------------------------------------------------------------------
        public static function getMinimumVersion(size : Int, level : ErrorCorrection) : Int {
            for(i in 1...(versionMax + 1)) {
                var words  = capacity[i][capWords] - capacity[i][capEC][level.toInt()];
                if(words >= size)
                    return i;
            }
            return -1;
        }

        //######################################################################

        public static var lengthTableBits : Array<Array<Int>> = [
            [10, 12, 14],
            [ 9, 11, 13],
            [8, 16, 16],
            [8, 10, 12]
        ];


        //----------------------------------------------------------------------
        public static function lengthIndicator(mode : EncodingMode, version : Int) : Int {
            if(mode == EncodingMode.MStructure)
                return 0;
            var l = if(version <= 9) {
                0;
            } else if(version <= 26) {
                1;
            } else {
                2;
            }
            return lengthTableBits[mode.toInt()][l];
        }

        //----------------------------------------------------------------------
        public static function maximumWords(mode : EncodingMode, version : Int)  : Int{
            if(mode == EncodingMode.MStructure)
                return 3;

            var l = if(version <= 9) {
                0;
            } else if(version <= 26) {
                1;
            } else {
                2;
            }
            var bits = lengthTableBits[mode.toInt()][l];
            var words = (1 << bits) - 1;

            if(mode == EncodingMode.MKanji) {
                words *= 2; // the number of bytes is required
            }

            return words;
        }

        // Error correction code -----------------------------------------------
        // Table of the error correction code (Reed-Solomon block)
        // See Table 12-16 (pp.30-36), JIS X0510:2004.

        public static var eccTable : Array<Array<Array<Int>>> = [
            [[ 0,  0], [ 0,  0], [ 0,  0], [ 0,  0]],
            [[ 1,  0], [ 1,  0], [ 1,  0], [ 1,  0]], // 1
            [[ 1,  0], [ 1,  0], [ 1,  0], [ 1,  0]],
            [[ 1,  0], [ 1,  0], [ 2,  0], [ 2,  0]],
            [[ 1,  0], [ 2,  0], [ 2,  0], [ 4,  0]],
            [[ 1,  0], [ 2,  0], [ 2,  2], [ 2,  2]], // 5
            [[ 2,  0], [ 4,  0], [ 4,  0], [ 4,  0]],
            [[ 2,  0], [ 4,  0], [ 2,  4], [ 4,  1]],
            [[ 2,  0], [ 2,  2], [ 4,  2], [ 4,  2]],
            [[ 2,  0], [ 3,  2], [ 4,  4], [ 4,  4]],
            [[ 2,  2], [ 4,  1], [ 6,  2], [ 6,  2]], //10
            [[ 4,  0], [ 1,  4], [ 4,  4], [ 3,  8]],
            [[ 2,  2], [ 6,  2], [ 4,  6], [ 7,  4]],
            [[ 4,  0], [ 8,  1], [ 8,  4], [12,  4]],
            [[ 3,  1], [ 4,  5], [11,  5], [11,  5]],
            [[ 5,  1], [ 5,  5], [ 5,  7], [11,  7]], //15
            [[ 5,  1], [ 7,  3], [15,  2], [ 3, 13]],
            [[ 1,  5], [10,  1], [ 1, 15], [ 2, 17]],
            [[ 5,  1], [ 9,  4], [17,  1], [ 2, 19]],
            [[ 3,  4], [ 3, 11], [17,  4], [ 9, 16]],
            [[ 3,  5], [ 3, 13], [15,  5], [15, 10]], //20
            [[ 4,  4], [17,  0], [17,  6], [19,  6]],
            [[ 2,  7], [17,  0], [ 7, 16], [34,  0]],
            [[ 4,  5], [ 4, 14], [11, 14], [16, 14]],
            [[ 6,  4], [ 6, 14], [11, 16], [30,  2]],
            [[ 8,  4], [ 8, 13], [ 7, 22], [22, 13]], //25
            [[10,  2], [19,  4], [28,  6], [33,  4]],
            [[ 8,  4], [22,  3], [ 8, 26], [12, 28]],
            [[ 3, 10], [ 3, 23], [ 4, 31], [11, 31]],
            [[ 7,  7], [21,  7], [ 1, 37], [19, 26]],
            [[ 5, 10], [19, 10], [15, 25], [23, 25]], //30
            [[13,  3], [ 2, 29], [42,  1], [23, 28]],
            [[17,  0], [10, 23], [10, 35], [19, 35]],
            [[17,  1], [14, 21], [29, 19], [11, 46]],
            [[13,  6], [14, 23], [44,  7], [59,  1]],
            [[12,  7], [12, 26], [39, 14], [22, 41]], //35
            [[ 6, 14], [ 6, 34], [46, 10], [ 2, 64]],
            [[17,  4], [29, 14], [49, 10], [24, 46]],
            [[ 4, 18], [13, 32], [48, 14], [42, 32]],
            [[20,  4], [40,  7], [43, 22], [10, 67]],
            [[19,  6], [18, 31], [34, 34], [20, 61]],//40
        ];

        //----------------------------------------------------------------------
        // CACHEABLE!!!

        public static function getEccSpec(version : Int, level : ErrorCorrection, spec : Array<Int>) : Void {
            if(spec.length < 5) {
                spec.push(0);
                spec.push(0);
                spec.push(0);
                spec.push(0);
                spec.push(0);
            }
            var b1   = eccTable[version][level.toInt()][0];
            var b2   = eccTable[version][level.toInt()][1];
            var data = getDataLength(version, level);
            var ecc  = getECCLength(version, level);

            if(b2 == 0) {
                spec[0] = b1;
                spec[1] = Std.int(data / b1);
                spec[2] = Std.int(ecc / b1);
                spec[3] = 0;
                spec[4] = 0;
            } else {
                spec[0] = b1;
                spec[1] = Std.int(data / (b1 + b2));
                spec[2] = Std.int(ecc  / (b1 + b2));
                spec[3] = b2;
                spec[4] = spec[1] + 1;
            }
        }

        // Alignment pattern ---------------------------------------------------

        // Positions of alignment patterns.
        // This array includes only the second and the third position of the
        // alignment patterns. Rest of them can be calculated from the distance
        // between them.

        // See Table 1 in Appendix E (pp.71) of JIS X0510:2004.

        public static var alignmentPattern : Array<Array<Int>> = [
            [ 0,  0],
            [ 0,  0], [18,  0], [22,  0], [26,  0], [30,  0], // 1- 5
            [34,  0], [22, 38], [24, 42], [26, 46], [28, 50], // 6-10
            [30, 54], [32, 58], [34, 62], [26, 46], [26, 48], //11-15
            [26, 50], [30, 54], [30, 56], [30, 58], [34, 62], //16-20
            [28, 50], [26, 50], [30, 54], [28, 54], [32, 58], //21-25
            [30, 58], [34, 62], [26, 50], [30, 54], [26, 52], //26-30
            [30, 56], [34, 60], [30, 58], [34, 62], [30, 54], //31-35
            [24, 50], [28, 54], [32, 58], [26, 54], [30, 58], //35-40
        ];


        /** --------------------------------------------------------------------
         * Put an alignment marker.
         * @param frame
         * @param width
         * @param ox,oy center coordinate of the pattern
         */
        public static function putAlignmentMarker(frame : QRFrame, ox : Int, oy : Int) : Void {
            //var finder = [
                //"\xa1\xa1\xa1\xa1\xa1",
                //"\xa1\xa0\xa0\xa0\xa1",
                //"\xa1\xa0\xa1\xa0\xa1",
                //"\xa1\xa0\xa0\xa0\xa1",
                //"\xa1\xa1\xa1\xa1\xa1"
            //];
			var finder = [
				[0xa1, 0xa1, 0xa1, 0xa1, 0xa1],
                [0xa1, 0xa0, 0xa0, 0xa0, 0xa1],
                [0xa1, 0xa0, 0xa1, 0xa0, 0xa1],
                [0xa1, 0xa0, 0xa0, 0xa0, 0xa1],
                [0xa1, 0xa1, 0xa1, 0xa1, 0xa1]
            ];

            var yStart = oy-2;
            var xStart = ox-2;

            for(y in 0...5) {
                frame.set(xStart, yStart+y, finder[y]);
            }
        }

        //----------------------------------------------------------------------
        public static function putAlignmentPattern(version : Int, frame : QRFrame, width : Int) : Void {
            if(version < 2)
                return;

            var d = alignmentPattern[version][1] - alignmentPattern[version][0];
            var w = if(d < 0) {
                2;
            } else {
                Std.int((width - alignmentPattern[version][0]) / d + 2);
            }

            if(w * w - 3 == 1) {
                var x = alignmentPattern[version][0];
                var y = alignmentPattern[version][0];
                putAlignmentMarker(frame, x, y);
                return;
            }

            var cx = alignmentPattern[version][0];
            for(x in 1...(w - 1)) {
				putAlignmentMarker(frame, 6, cx);
                putAlignmentMarker(frame, cx,  6);
                cx += d;
            }

			//trace(QRSpec.debug(frame));
            var cy = alignmentPattern[version][0];
            for(y in 0...(w - 1)) {
                var cx = alignmentPattern[version][0];
				for(x in 0...(w - 1)) {
                    putAlignmentMarker(frame, cx, cy);
                    cx += d;
                }
                cy += d;
            }
        }

        // Version information pattern -----------------------------------------

		// Version information pattern (BCH coded).
        // See Table 1 in Appendix D (pp.68) of JIS X0510:2004.

		// size: [QRSPEC_VERSION_MAX - 6]

        public static var versionPattern : Array<Int> = [
            0x07c94, 0x085bc, 0x09a99, 0x0a4d3, 0x0bbf6, 0x0c762, 0x0d847, 0x0e60d,
            0x0f928, 0x10b78, 0x1145d, 0x12a17, 0x13532, 0x149a6, 0x15683, 0x168c9,
            0x177ec, 0x18ec4, 0x191e1, 0x1afab, 0x1b08e, 0x1cc1a, 0x1d33f, 0x1ed75,
            0x1f250, 0x209d5, 0x216f0, 0x228ba, 0x2379f, 0x24b0b, 0x2542e, 0x26a64,
            0x27541, 0x28c69
        ];

        //----------------------------------------------------------------------
        public static function getVersionPattern(version : Int) : Int {
            if(version < 7 || version > versionMax)
                return 0;
            return versionPattern[version - 7];
        }

        // Format information --------------------------------------------------
        // See calcFormatInfo in tests/test_qrspec.c (orginal qrencode c lib)

        public static var formatInfo : Array<Array<Int>> = [
            [0x77c4, 0x72f3, 0x7daa, 0x789d, 0x662f, 0x6318, 0x6c41, 0x6976],
            [0x5412, 0x5125, 0x5e7c, 0x5b4b, 0x45f9, 0x40ce, 0x4f97, 0x4aa0],
            [0x355f, 0x3068, 0x3f31, 0x3a06, 0x24b4, 0x2183, 0x2eda, 0x2bed],
            [0x1689, 0x13be, 0x1ce7, 0x19d0, 0x0762, 0x0255, 0x0d0c, 0x083b]
        ];

        public static function getFormatInfo(mask : Int, level : ErrorCorrection) : Int {
            if(mask < 0 || mask > 7)
                return 0;

            if(level.toInt() < 0 || level.toInt() > 3)
                return 0;

            return formatInfo[level.toInt()][mask];
        }

        // Frame ---------------------------------------------------------------
        // Cache of initial frames.

        public static var frames : Map<Int, QRFrame> = new Map<Int, QRFrame>();

        /** --------------------------------------------------------------------
         * Put a finder pattern.
         * @param frame
         * @param width
         * @param ox,oy upper-left coordinate of the pattern
         */
        public static function putFinderPattern(frame : QRFrame, ox : Int, oy : Int) : Void {
            var finder = [
                [0xc1, 0xc1, 0xc1, 0xc1, 0xc1, 0xc1, 0xc1],
                [0xc1, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc1],
                [0xc1, 0xc0, 0xc1, 0xc1, 0xc1, 0xc0, 0xc1],
                [0xc1, 0xc0, 0xc1, 0xc1, 0xc1, 0xc0, 0xc1],
                [0xc1, 0xc0, 0xc1, 0xc1, 0xc1, 0xc0, 0xc1],
                [0xc1, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc1],
                [0xc1, 0xc1, 0xc1, 0xc1, 0xc1, 0xc1, 0xc1]
            ];

            for(y in 0...7) {
                frame.set(ox, oy+y, finder[y]);
            }
        }

        //----------------------------------------------------------------------
        public static function createFrame(version : Int) : QRFrame {
            var width = capacity[version][capWidth];

            var frameLine = [];
			for(i in 0...width) frameLine.push(0); // "\0";
            var frame = [];
			for(i in 0...width) frame.push(frameLine.copy());

            // Finder pattern
            putFinderPattern(frame, 0, 0);
            putFinderPattern(frame, width - 7, 0);
            putFinderPattern(frame, 0, width - 7);

			// Separator
            var yOffset = width - 7;

            for(y in 0...7) {
                frame[y][7] 		= 0xc0;
                frame[y][width - 8] = 0xc0;
                frame[yOffset][7] 	= 0xc0;
                yOffset++;
            }

            var setPattern = [];
			for(i in 0...8) setPattern.push(0xc0);

            frame.set(0, 7, setPattern);
            frame.set(width-8, 7, setPattern);
            frame.set(0, width - 8, setPattern);

            // Format info
			setPattern = [];
			for(i in 0...9) setPattern.push(0x84);
            frame.set(0, 8, setPattern);
            frame.set(width - 8, 8, setPattern, 8);

            yOffset = width - 8;

			{
				var y = 0;
				while(y < 8) {
					frame[y][8] 		= 0x84;
					frame[yOffset][8] 	= 0x84;
					y++;
					yOffset++;
				}
            }

            // Timing pattern

            for(i in 1...(width-15)) {
                frame[6][7+i] = (0x90 | (i & 1));
                frame[7+i][6] = (0x90 | (i & 1));
            }

            // Alignment pattern
            putAlignmentPattern(version, frame, width);

            // Version information
            if(version >= 7) {
                var vinf = getVersionPattern(version);
                var v = vinf;

                for(x in 0...6) {
                    for(y in 0...3) {
                        frame[(width - 11)+y][x] = (0x88 | (v & 1));
                        v = v >> 1;
                    }
                }

                v = vinf;
                for(y in 0...6) {
                    for(x in 0...3) {
                        frame[y][x+(width - 11)] = (0x88 | (v & 1));
                        v = v >> 1;
                    }
                }
            }

            // and a little bit...
            frame[width - 8][8] = 0x81;

            return frame;
        }

        //----------------------------------------------------------------------
        public static function debug(frame : QRFrame, ?binaryMode : Bool = false) : String {
			var buf : StringBuf = new StringBuf();
            if(binaryMode) {
				buf.add('<style>.m { background-color: white; }</style>');
				buf.add('<pre><tt><br/ ><br/ ><br/ >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;');
				var first = true;
				for(frameLine in frame) {
					if(!first) buf.add('<br/ >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;');
					else first = false;

					for(cell in frameLine) {
						if(cell == 0)
							buf.add('<span class="m">&nbsp;&nbsp;</span>');
						else
							buf.add('&#9608;&#9608;');
					}
				}
				buf.add('</tt></pre><br/ ><br/ ><br/ ><br/ ><br/ ><br/ >');
            } else {
				buf.add('<style>//.p { background-color: yellow; }.m { background-color: #00FF00; }.s { background-color: #FF0000; }.c { background-color: aqua; }.x { background-color: pink; }.f { background-color: gold; }</style>');
                buf.add('<pre><tt>');
				var first = true;
                for(frameLine in frame) {
					if(!first) buf.add('<br/ >');
					else first = false;

					for(cell in frameLine) {
						switch(cell) {
							case 0xc0: buf.add('<span class="m">&nbsp;</span>');
							case 0xc1: buf.add('<span class="m">&#9618;</span>');
							case 0xa0: buf.add('<span class="p">&nbsp;</span>');
							case 0xa1: buf.add('<span class="p">&#9618;</span>');
							case 0x84: buf.add('<span class="s">&#9671;</span>'); //format 0
							case 0x85: buf.add('<span class="s">&#9670;</span>'); //format 1
							case 0x81: buf.add('<span class="x">&#9762;</span>'); //special bit
							case 0x90: buf.add('<span class="c">&nbsp;</span>'); //clock 0
							case 0x91: buf.add('<span class="c">&#9719;</span>'); //clock 1
							case 0x88: buf.add('<span class="f">&nbsp;</span>'); //version
							case 0x89: buf.add('<span class="f">&#9618;</span>'); //version
							case 0x01: buf.add('&#9830;');
							case 0x0:  buf.add('&#8901;');
							default:   buf.add(cell);
						}
					}
                }
				buf.add('</tt></pre>');
            }
			return buf.toString();
        }

        //----------------------------------------------------------------------
        //public static function serial(frame) {
            //return gzcompress(join("\n", $frame), 9);
        //}

        //----------------------------------------------------------------------
        //public static function unserial(code) {
            //return explode("\n", gzuncompress($code));
        //}

        //----------------------------------------------------------------------
        public static function newFrame(version : Int) {
            if(version < 1 || version > versionMax)
                return null;

			if(!frames.exists(version)) {

                var fileName = QRCode.cacheDir + 'frame_' + version + '.dat';

                if(QRCode.cacheable) {
                    //if(file_exists($fileName)) {
                        //self::$frames[$version] = self::unserial(file_get_contents($fileName));
                    //} else {
                        //self::$frames[$version] = self::createFrame($version);
                        //file_put_contents($fileName, self::serial(self::$frames[$version]));
                    //}
                } else {
                    QRSpec.frames.set(version, createFrame(version));
                }
            }

			return QRSpec.frames.get(version);
        }

        //----------------------------------------------------------------------
        public static inline function rsBlockNum(spec) : Int     { return spec[0] + spec[3]; }
        public static inline function rsBlockNum1(spec) : Int    { return spec[0]; }
        public static inline function rsDataCodes1(spec) : Int   { return spec[1]; }
        public static inline function rsEccCodes1(spec) : Int    { return spec[2]; }
        public static inline function rsBlockNum2(spec) : Int    { return spec[3]; }
        public static inline function rsDataCodes2(spec) : Int   { return spec[4]; }
        public static inline function rsEccCodes2(spec) : Int    { return spec[2]; }
        public static inline function rsDataLength(spec) : Int   { return (spec[0] * spec[1]) + (spec[3] * spec[4]);    }
        public static inline function rsEccLength(spec) : Int    { return (spec[0] + spec[3]) * spec[2]; }

}
