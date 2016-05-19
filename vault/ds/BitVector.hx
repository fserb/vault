package vault.ds;

import haxe.ds.Vector;

/**
 * <p>An array data structure that compactly stores individual bits (Boolean values).</p>
 * <p><o>Worst-case running time in Big O notation</o></p>
 */
class BitVector {
  /**
   * A unique identifier for this object.<br/>
   * A hash table transforms this key into an index of an array element by using a hash function.<br/>
   * <warn>This value should never be changed by the user.</warn>
   */
  public var key:Int;

  var _bits:Vector<Int>;
  var _arrSize:Int;
  var _bitSize:Int;

  /**
   * Creates a bit-vector capable of storing a total of <code>size</code> bits.
   */
  public function new(size:Int) {
    _bits = null;
    _bitSize = 0;
    _arrSize = 0;

    resize(size);
  }

  /**
   * The exact number of bits that the bit-vector can store.
   * <o>1</o>
   */
  inline public function capacity():Int {
    return _bitSize;
  }

  /**
   * The total number of bits set to 1.
   * <o>n</o>
   */
  inline public function count():Int {
    var c = 0;
    for (i in 0..._arrSize) {
      var x = _bits[i];
      x -= ((x >> 1) & 0x55555555);
      x = (((x >> 2) & 0x33333333) + (x & 0x33333333));
      x = (((x >> 4) + x) & 0x0f0f0f0f);
      x += (x >> 8);
      x += (x >> 16);
      c += (x & 0x0000003f);
    }
    return c;
  }

  /**
   * The total number of 32-bit integers allocated for storing the bits.
   * <o>1</o>
   */
  inline public function bucketSize():Int {
    return _arrSize;
  }

  /**
   * Returns true if the bit at index <code>i</code> is 1.
   */
  inline public function is(i:Int):Bool {
    return ((_bits[i >> 5] & (1 << (i & (32 - 1)))) >> (i & (32 - 1))) != 0;
  }

  /**
   * Sets the bit at index <code>i</code> to 1.
   * <o>1</o>
   * @throws de.polygonal.ds.error.AssertError index out of range (debug only).
   */
  inline public function set(i:Int) {
    var p = i >> 5;
    _bits[p] = _bits[p] | (1 << (i & (32 - 1)));
  }

  /**
   * Sets the bit at index <code>i</code> to 0.
   * <o>1</o>
   * @throws de.polygonal.ds.error.AssertError index out of range (debug only).
   */
  inline public function clr(i:Int) {
    var p = i >> 5;
    _bits[p] = _bits[p] & (~(1 << (i & (32 - 1))));
  }

  /**
   * Sets all bits in the bit-vector to 0.
   * <o>n</o>
   */
  inline public function clrAll() {
    for (i in 0..._arrSize) _bits[i] = 0;
  }

  /**
   * Sets all bits in the bit-vector to 1.
   * <o>n</o>
   */
  inline public function setAll() {
    for (i in 0..._arrSize) _bits[i] = -1;
  }

  /**
   * Clears all bits in the range <arg>&#091;min, max)</arg>.
   * This is faster than clearing individual bits by using the <code>clr</code> method.
   * @throws de.polygonal.ds.error.AssertError min out of range (debug only).
   * @throws de.polygonal.ds.error.AssertError max out of range (debug only).
   * <o>n</o>
   */
  inline public function clrRange(min:Int, max:Int) {
    var current = min;

    while ( current < max ) {
      var binIndex = current >> 5;
      var nextBound = (binIndex + 1) << 5;
      var mask = -1 << (32 - nextBound + current);
      mask &= (max < nextBound) ? -1 >>> (nextBound - max) : -1;
      _bits[binIndex] &= ~mask;

      current = nextBound;
    }
  }

  /**
   * Sets all bits in the range <arg>&#091;min, max)</arg>.
   * This is faster than setting individual bits by using the <code>set</code> method.
   * @throws de.polygonal.ds.error.AssertError min out of range (debug only).
   * @throws de.polygonal.ds.error.AssertError max out of range (debug only).
   * <o>n</o>
   */
  inline public function setRange(min:Int, max:Int) {
    var current = min;

    while ( current < max )
    {
      var binIndex = current >> 5;
      var nextBound = (binIndex + 1) << 5;
      var mask = -1 << (32 - nextBound + current);
      mask &= (max < nextBound) ? -1 >>> (nextBound - max) : -1;
      _bits[binIndex] |= mask;

      current = nextBound;
    }
  }

  /**
   * Sets the bit at index <code>i</code> to 1 if <code>cond</code> is true or clears the bit at index <code>i</code> if <code>cond</code> is false.
   * <o>1</o>
   * @throws de.polygonal.ds.error.AssertError index out of range (debug only) (debug only).
   */
  inline public function ofBool(i:Int, cond:Bool)
  {
    cond ? set(i) : clr(i);
  }

  /**
   * Returns the bucket at index <code>i</code>.<br/>
   * A bucket is a 32-bit integer for storing the bit flags.
   * @throws de.polygonal.ds.error.AssertError <code>i</code> out of range (debug only).
   */
  inline public function getBucketAt(i:Int):Int
  {
    return _bits[i];
  }

  /**
   * Writes all buckets to <code>output</code>.
   * A bucket is a 32-bit integer for storing the bit flags.
   * @return the total number of buckets.
   */
  inline public function getBuckets(output:Array<Int>):Int
  {
    var t = _bits;
    for (i in 0..._arrSize) output[i] = t[i];
    return _arrSize;
  }

  /**
   * Resizes the bit-vector to <code>x</code> bits.<br/>
   * Preserves existing values if the new size &gt; old size.
   * <o>n</o>
   */
  public function resize(x:Int)
  {
    if (_bitSize == x) return;

    var newSize = x >> 5;
    if ((x & (32 - 1)) > 0) newSize++;

    if (_bits == null)
    {
      _bits = new Vector(newSize);

      for (i in 0...newSize) _bits[i] = 0;
    }
    else
    if (newSize < _arrSize)
    {
      _bits = new Vector(newSize);

      for (i in 0...newSize) _bits[i] = 0;
    }
    else
    if (newSize > _arrSize)
    {
      var t = new Vector<Int>(newSize);
      Vector.blit(_bits, 0, t, 0, _arrSize);
      for (i in _arrSize...newSize) t[i] = 0;
      _bits = t;
    }
    else if (x < _bitSize)
    {
      for (i in 0...newSize) _bits[i] = 0;
    }

    _bitSize = x;
    _arrSize = newSize;
  }

  /**
   * Writes the data in this bit-vector to a byte array.<br/>
   * The number of bytes equals <em>bucketSize()</em> * 4 and the number of bits equals <em>capacity()</em>.
   * <o>n</o>
   * @param bigEndian the byte order (default is little endian)
   */
  public function toBytes(bigEndian = false):haxe.io.BytesData
  {
    #if flash9
    var output = new flash.utils.ByteArray();
    if (!bigEndian) output.endian = flash.utils.Endian.LITTLE_ENDIAN;
    for (i in 0..._arrSize)
      output.writeInt(_bits[i]);
    return output;
    #else
    var output = new haxe.io.BytesOutput();
    output.bigEndian = bigEndian;
    for (i in 0..._arrSize)
      output.writeInt32(_bits[i]);
    return output.getBytes().getData();
    #end
  }

  public function hash(): String {
    var output = new haxe.io.BytesOutput();
    for (i in 0..._arrSize) {
      output.writeInt32(_bits[i]);
    }
    return output.getBytes().toHex();
  }

  /**
   * Copies the bits from <code>bytes</code> into this bit vector.<br/>
   * The bit-vector is resized to the size of <code>bytes</code>.
   * <o>n</o>
   * @param bigEndian the input byte order (default is little endian)
   * @throws de.polygonal.ds.error.AssertError <code>input</code> is null (debug only).
   */
  public function ofBytes(bytes:haxe.io.BytesData, bigEndian = false)
  {
    #if flash9
    var input = bytes;
    input.position = 0;
    if (!bigEndian) input.endian = flash.utils.Endian.LITTLE_ENDIAN;
    #else
    var input = new haxe.io.BytesInput(haxe.io.Bytes.ofData(bytes));
    input.bigEndian = bigEndian;
    #end

    var k =
    #if neko
    neko.NativeString.length(bytes);
    #else
    input.length;
    #end

    var numBytes = k & 3;
    var numIntegers = (k - numBytes) >> 2;
    _arrSize = numIntegers + (numBytes > 0 ? 1 : 0);
    _bitSize = _arrSize << 5;
    _bits = new Vector<Int>(_arrSize);
    for (i in 0..._arrSize) _bits[i] = 0;
    for (i in 0...numIntegers)
    {
      #if flash9
      _bits[i] = input.readInt();
      #elseif cpp
      _bits[i] = (cast input.readInt32()) & 0xFFFFFFFF;
      #else
      _bits[i] = cast input.readInt32();
      #end
    }
    var index = numIntegers << 5;
    var shift = 0, t = 0;
    for (i in 0...numBytes)
    {
      var byte = input.readByte();
      for (j in 0...8)
      {
        if ((byte & 1) == 1) set(index);
        byte >>= 1;
        index++;
      }
    }
  }

  /**
   * Returns a string representing the current object.<br/>
   * Example:<br/>
   * <pre class="prettyprint">
   * var bv = new de.polygonal.ds.BitVector(40);
   * for (i in 0...bv.capacity()) {
   *     if (i & 1 == 0) {
   *         bv.set(i);
   *     }
   * }
   * trace(bv);</pre>
   * <pre class="console">
   * { BitVector set/all: 20/40 }
   * [
   *   0 -> b01010101010101010101010101010101
   *   1 -> b00000000000000000000000001010101
   * ]</pre>
   */
  public function toString():String
  {
    var s = '{ BitVector set/all: ${count()}/${capacity()} }';
    if (count() == 0) return s;
    s += "\n[\n";
    for (i in 0..._arrSize) {
      s += i + " -> ";
      for (r in 0...32) {
        s += _bits[i] & (1 << r) == 0 ? "0":"1";
      }
      s += "\n";
    }
    s += "]";
    return s;
  }

  /**
   * Creates a copy of this bit vector.
   * <o>n</o>
   */
  public function clone():BitVector
  {
    var copy = new BitVector(_bitSize);
    var t = copy._bits;
    Vector.blit(_bits, 0, copy._bits, 0, _arrSize);
    return copy;
  }
}
