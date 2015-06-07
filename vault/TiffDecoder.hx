package vault;

import haxe.io.Bytes;
import openfl.utils.ByteArray;

// http://partners.adobe.com/public/developer/en/tiff/TIFF6.pdf

@:enum
abstract ACompression(Int) {
    var Uncompressed = 1;
    var CCITT_1D = 2;
    var Group_3_Fax = 3;
    var Group_4_Fax = 4;
    var LZW = 5;
    var JPEG = 6;
    var Uncompressed_Old = 32771;
    var Packbits = 32773;
}

@:enum
abstract ADataType(Int) {
    var BYTE = 1; // 8-bit unsigned integer

    // The value of the Count part of an ASCII field entry includes the NUL. If padding
    // is necessary, the Count does not include the pad byte. Note that there is no initial
    // "count byte" as in Pascal-style strings.
    // Any ASCII field can contain multiple strings, each terminated with a NUL. A
    // single string is preferred whenever possible. The Count for multi-string fields is
    // the number of bytes in all the strings in that field plus their terminating NUL
    // bytes. Only one NUL is allowed between strings, so that the strings following the
    // first string will often begin on an odd byte.
    var ASCII = 2; // 8-bit byte that contains a 7-bit ASCII code; the last byte must be NUL (binary zero)

    var SHORT = 3; // 16-bit (2-byte) unsigned integer
    var LONG = 4; // 32-bit (4-byte) unsigned integer
    var RATIONAL = 5; // Two LONGs: the first represents the numerator of a fraction; the second, the denominator

    var SBYTE = 6; // An 8-bit signed (twos-complement) integer
    var UNDEFINED = 7; // An 8-bit byte that may contain anything, depending on the definition of the field
    var SSHORT = 8; // A 16-bit (2-byte) signed (twos-complement) integer
    var SLONG = 9; // A 32-bit (4-byte) signed (twos-complement) integer
    var SRATIONAL = 10; // Two SLONG’s: the first represents the numerator of a fraction, the second the denominator
    var FLOAT = 11; // Single precision (4-byte) IEEE format
    var DOUBLE = 12; // Double precision (8-byte) IEEE format
}

@:enum
abstract AExtraSamples(Int) {
    var Unspecified = 0;
    var AssociatedAlpha = 1;
    var UnassociatedAlpha = 2;
}

@:enum
abstract APhotometricInterpretation(Int) {
    var WhiteIsZero = 0;
    var BlackIsZero = 1;
    var RGB = 2;
    var RGB_Palette = 3;
    var Tranparency_Mask = 4;
    var CMYK = 5;
    var YCbCr = 6;
    var CIELab = 8;
}

@:enum
abstract APlanarConfiguration(Int) {
    var Chunky = 1;
    var Planar = 2;
}

@:enum
abstract ASampleFormat(Int) {
    var Unsigned = 1; // unsigned integer data
    var Signed = 2; // two's complement signed integer data
    var IEEE = 3; // IEEE floating point data

    // A field value of "undefined" is a statement by the writer that it did not know how
    // to interpret the data samples; for example, if it were copying an existing image. A
    // reader would typically treat an image with "undefined" data as if the field were
    // not present (i.e. as unsigned integer data)
    var Undefined = 4; // undefined data format
}

@:enum
abstract TagId(Int) {
    // hex representation, type, number of values
    var NewSubFileType = 254; // 0x00fe, LONG, 1
    var SubFileType = 255; // 0x00ff, SHORT, 1
    var ImageWidth = 256; // 0x0100, SHORT or LONG, 1
    var ImageLength = 257; // 0x0101, SHORT or LONG, 1
    var BitsPerSample = 258; // 0x0102, SHORT, SamplesPerPixel
    var Compression = 259; // 0x0103, SHORT, 1
    var PhotometricInterpretation = 262; // 0x0106, SHORT, 1
    var Thresholding = 263; // 0x0107, SHORT, 1
    var CellWidth = 264; // 0x0108, SHORT, 1
    var CellLength = 265; // 0x0109, SHORT, 1
    var FillOrder = 266; // 0x010a, SHORT, 1
    var DocumentName = 269; // 0x010d, ASCII
    var ImageDescription = 270; // 0x010e, ASCII
    var Make = 271; // 0x010f, ASCII
    var Model = 272; // 0x0110, ASCII
    var StripOffsets = 273; // 0x0111, SHORT or LONG, StripsPerImage
    var Orientation = 274; // 0x0112, SHORT, 1
    var SamplesPerPixel = 277; // 0x0115, SHORT, 1
    var RowsPerStrip = 278; // 0x0116, SHORT or LONG, 1
    var StripByteCounts = 279; // 0x0117, LONG or SHORT, StripsPerImage
    var MinSampleValue = 280; // 0x0118, SHORT, SamplesPerPixel
    var MaxSampleValue = 281; // 0x0119, SHORT, SamplesPerPixel
    var XResolution = 282; // 0x011a, RATIONAL, 1
    var YResolution = 283; // 0x011b, RATIONAL, 1
    var PlanarConfiguration = 284; // 0x011c, SHORT, 1
    var PageName = 285; // 0x011d, ASCII
    var XPosition = 286; // 0x011e, RATIONAL
    var YPosition = 287; // 0x011f, RATIONAL
    var FreeOffsets = 288; // 0x0120, LONG
    var FreeByteCounts = 289; // 0x0121, LONG
    var GrayResponseUnit = 290; // 0x0122, SHORT, 1
    var GrayResponseCurve = 291; // 0x0123, SHORT, pow(2, BitsPerSample)
    var T4Options = 292; // 0x0124, LONG, 1
    var T6Options = 293; // 0x0125, LONG, 1
    var ResolutionUnit = 296; // 0x0128, SHORT, 1
    var PageNumber = 297; // 0x0129, SHORT, 2
    var TransferFunction = 301; // 0x012d, SHORT, {1 or SamplesPerPixel} * pow(2, BitsPerSample)
    var Software = 305; // 0x0131, ASCII
    var DateTime = 306; // 0x0132, ASCII, 20
    var Artist = 315; // 0x013b, ASCII
    var HostComputer = 316; // 0x013c, ASCII
    var Predictor = 317; // 0x013d, SHORT, 1
    var WhitePoint = 318; // 0x013e, RATIONAL, 2
    var PrimaryChromaticities = 319; // 0x013f, RATIONAL, 6
    var ColorMap = 320; // 0x0140, SHORT, 3 * pow(2, BitsPerSample)
    var HalftoneHints = 321; // 0x0141, SHORT, 2
    var TileWidth = 322; // 0x0142, SHORT or LONG, 1
    var TileLength = 323; // 0x0143, SHORT or LONG, 1
    var TileOffsets = 324; // 0x0144, LONG, TilesPerImage
    var TileByteCounts = 325; // 0x0145, SHORT or LONG, TilesPerImage
    var InkSet = 332; // 0x014c, SHORT, 1
    var InkNames = 333; // 0x014d, ASCII, total number of characters in all ink name strings, including zeros
    var NumberOfInks = 334; // 0x014e, SHORT, 1
    var DotRange = 336; // 0x0150, BYTE or SHORT, {2 or 2 * NumberOfInks}
    var TargetPrinter = 337; // 0x0151, ASCII, any
    var ExtraSamples = 338; // 0x0152, BYTE, number of extra components per pixel
    var SampleFormat = 339; // 0x0153, SHORT, SamplesPerPixel
    var SMinSampleValue = 340; // 0x0154, Any, SamplesPerPixel
    var SMaxSampleValue = 341; // 0x0155, Any, SamplesPerPixel
    var TransferRange = 342; // 0x0156, SHORT, 6
    var JPEGProc = 512; // 0x0200, SHORT, 1
    var JPEGInterchangeFormat = 513; // 0x0201, LONG, 1
    var JPEGInterchangeFormatLength = 514; // 0x0202, LONG, 1
    var JPEGRestartInterval = 515; // 0x0203, SHORT, 1
    var JPEGLosslessPredictors = 517; // 0x0205, SHORT, SamplesPerPixel
    var JPEGPointTransforms = 518; // 0x0206, SHORT, SamplesPerPixel
    var JPEGQTables = 519; // 0x0207, LONG, SamplesPerPixel
    var JPEGDCTTables = 520; // 0x0208, LONG, SamplesPerPixel
    var JPEGACTTables = 521; // 0x0209, LONG, SamplesPerPixel
    var YCbCrCoefficients = 529; // 0x0211, RATIONAL, 3
    var YCbCrSubSampling = 530; // 0x0212, SHORT, 2
    var YCbCrPositioning = 531; // 0x0213, SHORT, 1
    var ReferenceBlackWhite = 532; // 0x0214, LONG, 2 * SamplesPerPixel
    var Copyright = 33432; // 0x08298, ASCII, any
}

typedef TiffImage = {
    width:Int,
    height:Int,
    pixels:ByteArray,
};

class TiffDecoder {
    private var data:Bytes;
    private var isBigEndian:Bool;
    private var ifdOffset:Int;

    public function new(data:Bytes):Void {
        if (data.length < 8) {
            throw "invalid header: size";
        }

        this.data = data;

        if (data.get(0) == 0x4d && data.get(1) == 0x4d) {
            isBigEndian = true;
        } else if (data.get(0) == 0x49 && data.get(1) == 0x49) {
            isBigEndian = false;
        } else {
            throw "invalid header: Identifier";
        }

        if (getUShort(2) != 0x2a) {
            throw "invalid header: Version";
        }

        ifdOffset = getULong(4);

        if (ifdOffset >= data.length) {
            throw "invalid header: IFDOffset";
        }
    }

    public function run():TiffImage {
        return parseIfd(ifdOffset);
    }

    private function parseIfd(pos:Int):TiffImage {
        var numDirEntries = getUShort(pos);
        pos += 2;

        var tagMap = new Map<Int, Array<Int>>();

        for (i in 0 ... numDirEntries) {
            parseTag(pos, tagMap);
            pos += 12;
        }

        // getULong(pos) - next IFD offset, but:
        // "A Baseline TIFF reader is not required to read any IFDs beyond the first one"

        return parseImage(tagMap);
    }

    private function parseImage(tagMap:Map<Int, Array<Int>>):TiffImage {
        if (!tagMap.exists(cast TagId.ImageWidth)
            || !tagMap.exists(cast TagId.ImageLength)
            || !tagMap.exists(cast TagId.PhotometricInterpretation)
            || !tagMap.exists(cast TagId.StripOffsets)
            || !tagMap.exists(cast TagId.StripByteCounts)
        ) {
            throw "required tags are missing: ImageWidth | ImageLength | PhotometricInterpretation | StripOffsets | StripByteCounts";
        }

        if (tagMap[cast TagId.PhotometricInterpretation][0] != (cast APhotometricInterpretation.RGB)) {
            throw "PhotometricInterpretation must be = RGB";
        }

        if (getOrDefault(tagMap, TagId.Compression, [cast ACompression.Uncompressed])[0] != (cast ACompression.Uncompressed)) {
            throw "Compression must be = Uncompressed";
        }

        if (getOrDefault(tagMap, TagId.Orientation, [1])[0] != 1) {
            throw "Orientation must be = 1";
        }

        if (getOrDefault(tagMap, TagId.PlanarConfiguration, [cast APlanarConfiguration.Chunky])[0] != (cast APlanarConfiguration.Chunky)) {
            throw "PlanarConfiguration must be = Chunky";
        }

        var imageLength = tagMap[cast TagId.ImageLength][0];
        var rowsPerStrip = getOrDefault(tagMap, TagId.RowsPerStrip, [0xffffffff])[0];
        var stripsPerImage = Std.int((imageLength + rowsPerStrip - 1) / rowsPerStrip);

        if (getOrDefault(tagMap, TagId.SamplesPerPixel, [1])[0] != 4) {
            throw "SamplesPerPixel must be = 4";
        }

        if (!compareArray(getOrDefault(tagMap, TagId.BitsPerSample, [1, 1, 1, 1]), [8, 8, 8, 8])) {
            throw "BitsPerSample must be = [8, 8, 8, 8]";
        }

        var sampleFormat = getOrDefault(
            tagMap,
            TagId.SampleFormat,
            [cast ASampleFormat.Unsigned, cast ASampleFormat.Unsigned, cast ASampleFormat.Unsigned, cast ASampleFormat.Unsigned]
        );

        for (i in 0 ... sampleFormat.length) {
            if (sampleFormat[i] == cast ASampleFormat.Undefined) {
                sampleFormat[i] = cast ASampleFormat.Unsigned;
            }
        }

        if (!compareArray(
            sampleFormat,
            [cast ASampleFormat.Unsigned, cast ASampleFormat.Unsigned, cast ASampleFormat.Unsigned, cast ASampleFormat.Unsigned]
        )) {
            throw "unsupported SampleFormat value";
        }

        var extraSamples = getOrDefault(tagMap, TagId.ExtraSamples, []);

        if (extraSamples.length != 1) {
            throw "ExtraSamples.length must be = 1";
        }

        var extraSampleValue:Int = extraSamples[0];

        if ((extraSampleValue != cast AExtraSamples.AssociatedAlpha) && (extraSampleValue != cast AExtraSamples.UnassociatedAlpha)) {
            throw "unsupported ExtraSamples value";
        }

        var stripOffsets = tagMap[cast TagId.StripOffsets];

        if (stripOffsets.length != stripsPerImage) {
            throw "invalid StripOffsets length";
        }

        var stripByteCounts = tagMap[cast TagId.StripByteCounts];

        if (stripOffsets.length != stripsPerImage) {
            throw "invalid StripByteCounts length";
        }

        var imageWidth = tagMap[cast TagId.ImageWidth][0];
        var computedSize = Lambda.fold(stripByteCounts, function(a:Int, b:Int):Int { return a + b; }, 0);

        if (imageWidth * imageLength * 4 != computedSize) {
            throw "invalid StripByteCounts value";
        }

        for (bc in stripByteCounts) {
            if (bc % 4 != 0) {
                throw "each StripByteCounts element must be dividable by 4";
            }
        }

        #if flash
            var pixels = new ByteArray();
            pixels.length = computedSize;
        #else
            var pixels = new ByteArray(computedSize);
        #end

        pixels.position = 0;

        #if js
            var ba = ByteArray.fromBytes(data);

            for (i in 0 ... stripsPerImage) {
                ba.position = stripOffsets[i];
                var count = Std.int(stripByteCounts[i] / 4);

                for (j in 0 ... count) {
                    var r = ba.readUnsignedByte();
                    var g = ba.readUnsignedByte();
                    var b = ba.readUnsignedByte();
                    var a = ba.readUnsignedByte();

                    pixels.writeByte(a);
                    pixels.writeByte(r);
                    pixels.writeByte(g);
                    pixels.writeByte(b);
                }
            }
        #else
            for (i in 0 ... stripsPerImage) {
                var offset = stripOffsets[i];
                var count = Std.int(stripByteCounts[i] / 4);

                for (j in 0 ... count) {
                    pixels.writeByte(data.get(offset + 3));
                    pixels.writeByte(data.get(offset + 0));
                    pixels.writeByte(data.get(offset + 1));
                    pixels.writeByte(data.get(offset + 2));
                    offset += 4;
                }
            }
        #end

        pixels.position = 0;

        return {
            width: imageWidth,
            height: imageLength,
            pixels: pixels,
        };
    }

    private function getOrDefault(tagMap:Map<Int, Array<Int>>, tagId:TagId, def:Array<Int>):Array<Int> {
        return (tagMap.exists(cast tagId) ? tagMap[cast tagId] : def);
    }

    private function compareArray(a:Array<Int>, b:Array<Int>):Bool {
        if (a.length != b.length) {
            return false;
        }

        for (i in 0 ... a.length) {
            if (a[i] != b[i]) {
                return false;
            }
        }

        return true;
    }

    private function parseTag(pos:Int, tagMap:Map<Int, Array<Int>>):Void {
        var tagId:TagId = cast getUShort(pos);

        switch (tagId) {
            case ImageWidth
                    | ImageLength
                    | BitsPerSample
                    | Compression
                    | PhotometricInterpretation
                    | StripOffsets
                    | Orientation
                    | SamplesPerPixel
                    | RowsPerStrip
                    | StripByteCounts
                    | PlanarConfiguration
                    | ExtraSamples
                    | SampleFormat:
                tagMap[cast tagId] = parseTagData(pos);

            default:
        }
    }

    private function parseTagData(pos:Int):Array<Int> {
        var dataType:ADataType = cast getUShort(pos + 2);
        var dataCount = getULong(pos + 4);

        if (dataCount == 0) {
            throw "data count is zero";
        }

        var sizeInBytes = dataCount * switch (dataType) {
            case BYTE | ASCII | SBYTE | UNDEFINED: 1;
            case SHORT | SSHORT: 2;
            case LONG | SLONG: 4;
            case FLOAT: throw "unsupported data type: FLOAT"; // 4
            case RATIONAL | SRATIONAL | DOUBLE: throw "unsupported data type: RATIONAL | SRATIONAL | DOUBLE"; // 8
        };

        var dataPos = (sizeInBytes <= 4 ? pos + 8 : getULong(pos + 8));
        var result = new Array<Int>();

        for (i in 0 ... dataCount) {
            switch (dataType) {
                case BYTE | ASCII | UNDEFINED:
                    result.push(data.get(dataPos));
                    dataPos++;

                case SBYTE:
                    result.push(getSByte(dataPos));
                    dataPos++;

                case SHORT:
                    result.push(getUShort(dataPos));
                    dataPos += 2;

                case SSHORT:
                    result.push(getSShort(dataPos));
                    dataPos += 2;

                case LONG:
                    result.push(getULong(dataPos));
                    dataPos += 4;

                case SLONG:
                    result.push(getSLong(dataPos));
                    dataPos += 4;

                default:
            }
        }

        return result;
    }

    private function getSByte(pos:Int):Int {
        var value = data.get(pos);
        return (value <= 0x7f ? value : value - 0x100);
    }

    private function getUShort(pos:Int):Int {
        if (isBigEndian) {
            return (data.get(pos) << 8) | data.get(pos + 1);
        } else {
            return data.get(pos) | (data.get(pos + 1) << 8);
        }
    }

    private function getSShort(pos:Int):Int {
        var value = getUShort(pos);
        return (value <= 0x7fff ? value : value - 0x10000);
    }

    private function getULong(pos:Int):Int {
        if (isBigEndian) {
            return (data.get(pos) << 24) | (data.get(pos + 1) << 16) | (data.get(pos + 2) << 8) | data.get(pos + 3);
        } else {
            return data.get(pos) | (data.get(pos + 1) << 8) | (data.get(pos + 2) << 16) | (data.get(pos + 3) << 24);
        }
    }

    private function getSLong(pos:Int):Int {
        var value = getULong(pos);
        return (value <= 0x7fffffff ? value : ((value - 0x7fffffff) - 0x7fffffff) - 2);
    }

    public static function decode(data:Bytes):TiffImage {
        var decoder = new TiffDecoder(data);
        return decoder.run();
    }
}
