
String submitHexMd5(String s) {
  String encryptPwd1 = rstr2hex(rstrMd5(s));
  return rstr2hex(rstrMd5(encryptPwd1));
}

String rstrMd5(String s) {
  return binl2rstr(binlMd5(rstr2binl(s), s.length * 8));
}

// check
String rstr2hex(String input) {
  const hexTab = "0123456789abcdef";
  String output = "";
  for (int i = 0; i < input.length; i++) {
    int x = input.codeUnitAt(i);
    output += hexTab[(x >> 4) & 0x0F] + hexTab[x & 0x0F];
  }
  return output;
}

// check
List<int> rstr2binl(String input) {
  List<int> output = List<int>.filled(input.length >> 2, 0);
  for (int i = 0; i < output.length; i++) {
    output[i] = 0;
  }
  for (int i = 0; i < input.length * 8; i += 8) {
    int index = i >> 5;
    output = fillList(output, index);
    output[i >> 5] |= (input.codeUnitAt(i ~/ 8) & 0xFF) << (i % 32);
  }
  return output;
}

String binl2rstr(List<int> input) {
  String output = "";
  for (int i = 0; i < input.length * 32; i += 8) output += String.fromCharCode((input[i >> 5] >> (i % 32)) & 0xFF);
  return output;
}

List<int> fillList(List<int> x, int index) {
  if (x.length <= index) {
    int length = (index - (x.length - 1));
    x = List<int>.from(x);
    x.addAll(List.filled(length, 0));
  }
  return x;
}

List<int> binlMd5(List<int> x, int len) {
  int index1 = (len >> 5).toSigned(32);
  x = fillList(x, index1);
  x[index1] |= (0x80 << ((len) % 32)).toSigned(32);
  int num1 = (((len + 64) & 0xFFFFFFFF) >>> 9);
  int num2 = (num1 << 4).toSigned(32);
  int index2 = num2 + 14;
  x = fillList(x, index2);
  x[index2] = len;
  int a = 1732584193;
  int b = -271733879;
  int c = -1732584194;
  int d = 271733878;
  for (int i = 0; i < x.length; i += 16) {
    int olda = a;
    int oldb = b;
    int oldc = c;
    int oldd = d;
    List<int> copyX = List<int>.from(x);
    for (int j = 0; j < 64; j += 1) {
      copyX.add(0);
    }
    a = md5Ff(a, b, c, d, copyX[i], 7, -680876936);
    d = md5Ff(d, a, b, c, copyX[i + 1], 12, -389564586);
    c = md5Ff(c, d, a, b, copyX[i + 2], 17, 606105819);
    b = md5Ff(b, c, d, a, copyX[i + 3], 22, -1044525330);
    a = md5Ff(a, b, c, d, copyX[i + 4], 7, -176418897);
    d = md5Ff(d, a, b, c, copyX[i + 5], 12, 1200080426);
    c = md5Ff(c, d, a, b, copyX[i + 6], 17, -1473231341);
    b = md5Ff(b, c, d, a, copyX[i + 7], 22, -45705983);
    a = md5Ff(a, b, c, d, copyX[i + 8], 7, 1770035416);
    d = md5Ff(d, a, b, c, copyX[i + 9], 12, -1958414417);
    c = md5Ff(c, d, a, b, copyX[i + 10], 17, -42063);
    b = md5Ff(b, c, d, a, copyX[i + 11], 22, -1990404162);
    a = md5Ff(a, b, c, d, copyX[i + 12], 7, 1804603682);
    d = md5Ff(d, a, b, c, copyX[i + 13], 12, -40341101);
    c = md5Ff(c, d, a, b, copyX[i + 14], 17, -1502002290);
    b = md5Ff(b, c, d, a, copyX[i + 15], 22, 1236535329);

    a = md5Gg(a, b, c, d, copyX[i + 1], 5, -165796510);
    d = md5Gg(d, a, b, c, copyX[i + 6], 9, -1069501632);
    c = md5Gg(c, d, a, b, copyX[i + 11], 14, 643717713);
    b = md5Gg(b, c, d, a, copyX[i], 20, -373897302);
    a = md5Gg(a, b, c, d, copyX[i + 5], 5, -701558691);
    d = md5Gg(d, a, b, c, copyX[i + 10], 9, 38016083);
    c = md5Gg(c, d, a, b, copyX[i + 15], 14, -660478335);
    b = md5Gg(b, c, d, a, copyX[i + 4], 20, -405537848);
    a = md5Gg(a, b, c, d, copyX[i + 9], 5, 568446438);
    d = md5Gg(d, a, b, c, copyX[i + 14], 9, -1019803690);
    c = md5Gg(c, d, a, b, copyX[i + 3], 14, -187363961);
    b = md5Gg(b, c, d, a, copyX[i + 8], 20, 1163531501);
    a = md5Gg(a, b, c, d, copyX[i + 13], 5, -1444681467);
    d = md5Gg(d, a, b, c, copyX[i + 2], 9, -51403784);
    c = md5Gg(c, d, a, b, copyX[i + 7], 14, 1735328473);
    b = md5Gg(b, c, d, a, copyX[i + 12], 20, -1926607734);

    a = md5Hh(a, b, c, d, copyX[i + 5], 4, -378558);
    d = md5Hh(d, a, b, c, copyX[i + 8], 11, -2022574463);
    c = md5Hh(c, d, a, b, copyX[i + 11], 16, 1839030562);
    b = md5Hh(b, c, d, a, copyX[i + 14], 23, -35309556);
    a = md5Hh(a, b, c, d, copyX[i + 1], 4, -1530992060);
    d = md5Hh(d, a, b, c, copyX[i + 4], 11, 1272893353);
    c = md5Hh(c, d, a, b, copyX[i + 7], 16, -155497632);
    b = md5Hh(b, c, d, a, copyX[i + 10], 23, -1094730640);
    a = md5Hh(a, b, c, d, copyX[i + 13], 4, 681279174);
    d = md5Hh(d, a, b, c, copyX[i], 11, -358537222);
    c = md5Hh(c, d, a, b, copyX[i + 3], 16, -722521979);
    b = md5Hh(b, c, d, a, copyX[i + 6], 23, 76029189);
    a = md5Hh(a, b, c, d, copyX[i + 9], 4, -640364487);
    d = md5Hh(d, a, b, c, copyX[i + 12], 11, -421815835);
    c = md5Hh(c, d, a, b, copyX[i + 15], 16, 530742520);
    b = md5Hh(b, c, d, a, copyX[i + 2], 23, -995338651);

    a = md5Ii(a, b, c, d, copyX[i], 6, -198630844);
    d = md5Ii(d, a, b, c, copyX[i + 7], 10, 1126891415);
    c = md5Ii(c, d, a, b, copyX[i + 14], 15, -1416354905);
    b = md5Ii(b, c, d, a, copyX[i + 5], 21, -57434055);
    a = md5Ii(a, b, c, d, copyX[i + 12], 6, 1700485571);
    d = md5Ii(d, a, b, c, copyX[i + 3], 10, -1894986606);
    c = md5Ii(c, d, a, b, copyX[i + 10], 15, -1051523);
    b = md5Ii(b, c, d, a, copyX[i + 1], 21, -2054922799);
    a = md5Ii(a, b, c, d, copyX[i + 8], 6, 1873313359);
    d = md5Ii(d, a, b, c, copyX[i + 15], 10, -30611744);
    c = md5Ii(c, d, a, b, copyX[i + 6], 15, -1560198380);
    b = md5Ii(b, c, d, a, copyX[i + 13], 21, 1309151649);
    a = md5Ii(a, b, c, d, copyX[i + 4], 6, -145523070);
    d = md5Ii(d, a, b, c, copyX[i + 11], 10, -1120210379);
    c = md5Ii(c, d, a, b, copyX[i + 2], 15, 718787259);
    b = md5Ii(b, c, d, a, copyX[i + 9], 21, -343485551);

    a = safeAdd(a, olda);
    b = safeAdd(b, oldb);
    c = safeAdd(c, oldc);
    d = safeAdd(d, oldd);
  }
  return [a, b, c, d];
}

int md5Cmn(int q, int a, int b, int x, int s, int t) {
  int a1 = safeAdd(a, q);
  int a2 = safeAdd(x, t);
  int a3 = safeAdd(a1, a2);
  int a4 = bitRol(a3, s);
  int a5 = safeAdd(a4, b);
  return a5;
}

int md5Ff(int a, int b, int c, int d, int x, int s, int t) {
  return md5Cmn((b & c) | ((~b) & d), a, b, x, s, t);
}

int md5Gg(int a, int b, int c, int d, int x, int s, int t) {
  return md5Cmn((b & d) | (c & (~d)), a, b, x, s, t);
}

int md5Hh(int a, int b, int c, int d, int x, int s, int t) {
  return md5Cmn(b ^ c ^ d, a, b, x, s, t);
}

int md5Ii(int a, int b, int c, int d, int x, int s, int t) {
  return md5Cmn(c ^ (b | (~d)), a, b, x, s, t);
}

int safeAdd(int x, int y) {
  int lsw = (x & 0xFFFF) + (y & 0xFFFF);
  int msw = (x >> 16).toSigned(32) + (y >> 16).toSigned(32) + (lsw >> 16).toSigned(32);
  return (msw << 16).toSigned(32) | (lsw & 0xFFFF);
}

int bitRol(int num, int cnt) {
  int b1 = (num << cnt).toSigned(32);
  int b2 = ((num & 0xFFFFFFFF) >>> (32 - cnt)).toSigned(32);
  int b3 = b1 | b2;
  return b3;
}
