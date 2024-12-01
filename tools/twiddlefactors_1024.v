// Copyright (c) 2012 Ben Reynwar
// Released under MIT License (see LICENSE.txt)

module twiddlefactors (
    input  wire                            clk,
    input  wire [8:0]          addr,
    input  wire                            addr_nd,
    output reg signed [25:0] tf_out
  );

  always @ (posedge clk)
    begin
      if (addr_nd)
        begin
          case (addr)
			
            9'd0: tf_out <= { 13'sd2048,  -13'sd0 };
			
            9'd1: tf_out <= { 13'sd2048,  -13'sd13 };
			
            9'd2: tf_out <= { 13'sd2048,  -13'sd25 };
			
            9'd3: tf_out <= { 13'sd2048,  -13'sd38 };
			
            9'd4: tf_out <= { 13'sd2047,  -13'sd50 };
			
            9'd5: tf_out <= { 13'sd2047,  -13'sd63 };
			
            9'd6: tf_out <= { 13'sd2047,  -13'sd75 };
			
            9'd7: tf_out <= { 13'sd2046,  -13'sd88 };
			
            9'd8: tf_out <= { 13'sd2046,  -13'sd100 };
			
            9'd9: tf_out <= { 13'sd2045,  -13'sd113 };
			
            9'd10: tf_out <= { 13'sd2044,  -13'sd126 };
			
            9'd11: tf_out <= { 13'sd2043,  -13'sd138 };
			
            9'd12: tf_out <= { 13'sd2042,  -13'sd151 };
			
            9'd13: tf_out <= { 13'sd2041,  -13'sd163 };
			
            9'd14: tf_out <= { 13'sd2040,  -13'sd176 };
			
            9'd15: tf_out <= { 13'sd2039,  -13'sd188 };
			
            9'd16: tf_out <= { 13'sd2038,  -13'sd201 };
			
            9'd17: tf_out <= { 13'sd2037,  -13'sd213 };
			
            9'd18: tf_out <= { 13'sd2036,  -13'sd226 };
			
            9'd19: tf_out <= { 13'sd2034,  -13'sd238 };
			
            9'd20: tf_out <= { 13'sd2033,  -13'sd251 };
			
            9'd21: tf_out <= { 13'sd2031,  -13'sd263 };
			
            9'd22: tf_out <= { 13'sd2029,  -13'sd276 };
			
            9'd23: tf_out <= { 13'sd2028,  -13'sd288 };
			
            9'd24: tf_out <= { 13'sd2026,  -13'sd301 };
			
            9'd25: tf_out <= { 13'sd2024,  -13'sd313 };
			
            9'd26: tf_out <= { 13'sd2022,  -13'sd325 };
			
            9'd27: tf_out <= { 13'sd2020,  -13'sd338 };
			
            9'd28: tf_out <= { 13'sd2018,  -13'sd350 };
			
            9'd29: tf_out <= { 13'sd2016,  -13'sd363 };
			
            9'd30: tf_out <= { 13'sd2013,  -13'sd375 };
			
            9'd31: tf_out <= { 13'sd2011,  -13'sd387 };
			
            9'd32: tf_out <= { 13'sd2009,  -13'sd400 };
			
            9'd33: tf_out <= { 13'sd2006,  -13'sd412 };
			
            9'd34: tf_out <= { 13'sd2004,  -13'sd424 };
			
            9'd35: tf_out <= { 13'sd2001,  -13'sd436 };
			
            9'd36: tf_out <= { 13'sd1998,  -13'sd449 };
			
            9'd37: tf_out <= { 13'sd1995,  -13'sd461 };
			
            9'd38: tf_out <= { 13'sd1993,  -13'sd473 };
			
            9'd39: tf_out <= { 13'sd1990,  -13'sd485 };
			
            9'd40: tf_out <= { 13'sd1987,  -13'sd498 };
			
            9'd41: tf_out <= { 13'sd1984,  -13'sd510 };
			
            9'd42: tf_out <= { 13'sd1980,  -13'sd522 };
			
            9'd43: tf_out <= { 13'sd1977,  -13'sd534 };
			
            9'd44: tf_out <= { 13'sd1974,  -13'sd546 };
			
            9'd45: tf_out <= { 13'sd1970,  -13'sd558 };
			
            9'd46: tf_out <= { 13'sd1967,  -13'sd570 };
			
            9'd47: tf_out <= { 13'sd1963,  -13'sd582 };
			
            9'd48: tf_out <= { 13'sd1960,  -13'sd595 };
			
            9'd49: tf_out <= { 13'sd1956,  -13'sd607 };
			
            9'd50: tf_out <= { 13'sd1952,  -13'sd619 };
			
            9'd51: tf_out <= { 13'sd1949,  -13'sd630 };
			
            9'd52: tf_out <= { 13'sd1945,  -13'sd642 };
			
            9'd53: tf_out <= { 13'sd1941,  -13'sd654 };
			
            9'd54: tf_out <= { 13'sd1937,  -13'sd666 };
			
            9'd55: tf_out <= { 13'sd1932,  -13'sd678 };
			
            9'd56: tf_out <= { 13'sd1928,  -13'sd690 };
			
            9'd57: tf_out <= { 13'sd1924,  -13'sd702 };
			
            9'd58: tf_out <= { 13'sd1920,  -13'sd714 };
			
            9'd59: tf_out <= { 13'sd1915,  -13'sd725 };
			
            9'd60: tf_out <= { 13'sd1911,  -13'sd737 };
			
            9'd61: tf_out <= { 13'sd1906,  -13'sd749 };
			
            9'd62: tf_out <= { 13'sd1902,  -13'sd760 };
			
            9'd63: tf_out <= { 13'sd1897,  -13'sd772 };
			
            9'd64: tf_out <= { 13'sd1892,  -13'sd784 };
			
            9'd65: tf_out <= { 13'sd1887,  -13'sd795 };
			
            9'd66: tf_out <= { 13'sd1882,  -13'sd807 };
			
            9'd67: tf_out <= { 13'sd1877,  -13'sd818 };
			
            9'd68: tf_out <= { 13'sd1872,  -13'sd830 };
			
            9'd69: tf_out <= { 13'sd1867,  -13'sd841 };
			
            9'd70: tf_out <= { 13'sd1862,  -13'sd853 };
			
            9'd71: tf_out <= { 13'sd1857,  -13'sd864 };
			
            9'd72: tf_out <= { 13'sd1851,  -13'sd876 };
			
            9'd73: tf_out <= { 13'sd1846,  -13'sd887 };
			
            9'd74: tf_out <= { 13'sd1840,  -13'sd898 };
			
            9'd75: tf_out <= { 13'sd1835,  -13'sd910 };
			
            9'd76: tf_out <= { 13'sd1829,  -13'sd921 };
			
            9'd77: tf_out <= { 13'sd1824,  -13'sd932 };
			
            9'd78: tf_out <= { 13'sd1818,  -13'sd943 };
			
            9'd79: tf_out <= { 13'sd1812,  -13'sd954 };
			
            9'd80: tf_out <= { 13'sd1806,  -13'sd965 };
			
            9'd81: tf_out <= { 13'sd1800,  -13'sd976 };
			
            9'd82: tf_out <= { 13'sd1794,  -13'sd988 };
			
            9'd83: tf_out <= { 13'sd1788,  -13'sd999 };
			
            9'd84: tf_out <= { 13'sd1782,  -13'sd1009 };
			
            9'd85: tf_out <= { 13'sd1776,  -13'sd1020 };
			
            9'd86: tf_out <= { 13'sd1769,  -13'sd1031 };
			
            9'd87: tf_out <= { 13'sd1763,  -13'sd1042 };
			
            9'd88: tf_out <= { 13'sd1757,  -13'sd1053 };
			
            9'd89: tf_out <= { 13'sd1750,  -13'sd1064 };
			
            9'd90: tf_out <= { 13'sd1744,  -13'sd1074 };
			
            9'd91: tf_out <= { 13'sd1737,  -13'sd1085 };
			
            9'd92: tf_out <= { 13'sd1730,  -13'sd1096 };
			
            9'd93: tf_out <= { 13'sd1724,  -13'sd1106 };
			
            9'd94: tf_out <= { 13'sd1717,  -13'sd1117 };
			
            9'd95: tf_out <= { 13'sd1710,  -13'sd1127 };
			
            9'd96: tf_out <= { 13'sd1703,  -13'sd1138 };
			
            9'd97: tf_out <= { 13'sd1696,  -13'sd1148 };
			
            9'd98: tf_out <= { 13'sd1689,  -13'sd1159 };
			
            9'd99: tf_out <= { 13'sd1682,  -13'sd1169 };
			
            9'd100: tf_out <= { 13'sd1674,  -13'sd1179 };
			
            9'd101: tf_out <= { 13'sd1667,  -13'sd1190 };
			
            9'd102: tf_out <= { 13'sd1660,  -13'sd1200 };
			
            9'd103: tf_out <= { 13'sd1652,  -13'sd1210 };
			
            9'd104: tf_out <= { 13'sd1645,  -13'sd1220 };
			
            9'd105: tf_out <= { 13'sd1637,  -13'sd1230 };
			
            9'd106: tf_out <= { 13'sd1630,  -13'sd1240 };
			
            9'd107: tf_out <= { 13'sd1622,  -13'sd1250 };
			
            9'd108: tf_out <= { 13'sd1615,  -13'sd1260 };
			
            9'd109: tf_out <= { 13'sd1607,  -13'sd1270 };
			
            9'd110: tf_out <= { 13'sd1599,  -13'sd1280 };
			
            9'd111: tf_out <= { 13'sd1591,  -13'sd1289 };
			
            9'd112: tf_out <= { 13'sd1583,  -13'sd1299 };
			
            9'd113: tf_out <= { 13'sd1575,  -13'sd1309 };
			
            9'd114: tf_out <= { 13'sd1567,  -13'sd1319 };
			
            9'd115: tf_out <= { 13'sd1559,  -13'sd1328 };
			
            9'd116: tf_out <= { 13'sd1551,  -13'sd1338 };
			
            9'd117: tf_out <= { 13'sd1543,  -13'sd1347 };
			
            9'd118: tf_out <= { 13'sd1534,  -13'sd1357 };
			
            9'd119: tf_out <= { 13'sd1526,  -13'sd1366 };
			
            9'd120: tf_out <= { 13'sd1517,  -13'sd1375 };
			
            9'd121: tf_out <= { 13'sd1509,  -13'sd1385 };
			
            9'd122: tf_out <= { 13'sd1500,  -13'sd1394 };
			
            9'd123: tf_out <= { 13'sd1492,  -13'sd1403 };
			
            9'd124: tf_out <= { 13'sd1483,  -13'sd1412 };
			
            9'd125: tf_out <= { 13'sd1475,  -13'sd1421 };
			
            9'd126: tf_out <= { 13'sd1466,  -13'sd1430 };
			
            9'd127: tf_out <= { 13'sd1457,  -13'sd1439 };
			
            9'd128: tf_out <= { 13'sd1448,  -13'sd1448 };
			
            9'd129: tf_out <= { 13'sd1439,  -13'sd1457 };
			
            9'd130: tf_out <= { 13'sd1430,  -13'sd1466 };
			
            9'd131: tf_out <= { 13'sd1421,  -13'sd1475 };
			
            9'd132: tf_out <= { 13'sd1412,  -13'sd1483 };
			
            9'd133: tf_out <= { 13'sd1403,  -13'sd1492 };
			
            9'd134: tf_out <= { 13'sd1394,  -13'sd1500 };
			
            9'd135: tf_out <= { 13'sd1385,  -13'sd1509 };
			
            9'd136: tf_out <= { 13'sd1375,  -13'sd1517 };
			
            9'd137: tf_out <= { 13'sd1366,  -13'sd1526 };
			
            9'd138: tf_out <= { 13'sd1357,  -13'sd1534 };
			
            9'd139: tf_out <= { 13'sd1347,  -13'sd1543 };
			
            9'd140: tf_out <= { 13'sd1338,  -13'sd1551 };
			
            9'd141: tf_out <= { 13'sd1328,  -13'sd1559 };
			
            9'd142: tf_out <= { 13'sd1319,  -13'sd1567 };
			
            9'd143: tf_out <= { 13'sd1309,  -13'sd1575 };
			
            9'd144: tf_out <= { 13'sd1299,  -13'sd1583 };
			
            9'd145: tf_out <= { 13'sd1289,  -13'sd1591 };
			
            9'd146: tf_out <= { 13'sd1280,  -13'sd1599 };
			
            9'd147: tf_out <= { 13'sd1270,  -13'sd1607 };
			
            9'd148: tf_out <= { 13'sd1260,  -13'sd1615 };
			
            9'd149: tf_out <= { 13'sd1250,  -13'sd1622 };
			
            9'd150: tf_out <= { 13'sd1240,  -13'sd1630 };
			
            9'd151: tf_out <= { 13'sd1230,  -13'sd1637 };
			
            9'd152: tf_out <= { 13'sd1220,  -13'sd1645 };
			
            9'd153: tf_out <= { 13'sd1210,  -13'sd1652 };
			
            9'd154: tf_out <= { 13'sd1200,  -13'sd1660 };
			
            9'd155: tf_out <= { 13'sd1190,  -13'sd1667 };
			
            9'd156: tf_out <= { 13'sd1179,  -13'sd1674 };
			
            9'd157: tf_out <= { 13'sd1169,  -13'sd1682 };
			
            9'd158: tf_out <= { 13'sd1159,  -13'sd1689 };
			
            9'd159: tf_out <= { 13'sd1148,  -13'sd1696 };
			
            9'd160: tf_out <= { 13'sd1138,  -13'sd1703 };
			
            9'd161: tf_out <= { 13'sd1127,  -13'sd1710 };
			
            9'd162: tf_out <= { 13'sd1117,  -13'sd1717 };
			
            9'd163: tf_out <= { 13'sd1106,  -13'sd1724 };
			
            9'd164: tf_out <= { 13'sd1096,  -13'sd1730 };
			
            9'd165: tf_out <= { 13'sd1085,  -13'sd1737 };
			
            9'd166: tf_out <= { 13'sd1074,  -13'sd1744 };
			
            9'd167: tf_out <= { 13'sd1064,  -13'sd1750 };
			
            9'd168: tf_out <= { 13'sd1053,  -13'sd1757 };
			
            9'd169: tf_out <= { 13'sd1042,  -13'sd1763 };
			
            9'd170: tf_out <= { 13'sd1031,  -13'sd1769 };
			
            9'd171: tf_out <= { 13'sd1020,  -13'sd1776 };
			
            9'd172: tf_out <= { 13'sd1009,  -13'sd1782 };
			
            9'd173: tf_out <= { 13'sd999,  -13'sd1788 };
			
            9'd174: tf_out <= { 13'sd988,  -13'sd1794 };
			
            9'd175: tf_out <= { 13'sd976,  -13'sd1800 };
			
            9'd176: tf_out <= { 13'sd965,  -13'sd1806 };
			
            9'd177: tf_out <= { 13'sd954,  -13'sd1812 };
			
            9'd178: tf_out <= { 13'sd943,  -13'sd1818 };
			
            9'd179: tf_out <= { 13'sd932,  -13'sd1824 };
			
            9'd180: tf_out <= { 13'sd921,  -13'sd1829 };
			
            9'd181: tf_out <= { 13'sd910,  -13'sd1835 };
			
            9'd182: tf_out <= { 13'sd898,  -13'sd1840 };
			
            9'd183: tf_out <= { 13'sd887,  -13'sd1846 };
			
            9'd184: tf_out <= { 13'sd876,  -13'sd1851 };
			
            9'd185: tf_out <= { 13'sd864,  -13'sd1857 };
			
            9'd186: tf_out <= { 13'sd853,  -13'sd1862 };
			
            9'd187: tf_out <= { 13'sd841,  -13'sd1867 };
			
            9'd188: tf_out <= { 13'sd830,  -13'sd1872 };
			
            9'd189: tf_out <= { 13'sd818,  -13'sd1877 };
			
            9'd190: tf_out <= { 13'sd807,  -13'sd1882 };
			
            9'd191: tf_out <= { 13'sd795,  -13'sd1887 };
			
            9'd192: tf_out <= { 13'sd784,  -13'sd1892 };
			
            9'd193: tf_out <= { 13'sd772,  -13'sd1897 };
			
            9'd194: tf_out <= { 13'sd760,  -13'sd1902 };
			
            9'd195: tf_out <= { 13'sd749,  -13'sd1906 };
			
            9'd196: tf_out <= { 13'sd737,  -13'sd1911 };
			
            9'd197: tf_out <= { 13'sd725,  -13'sd1915 };
			
            9'd198: tf_out <= { 13'sd714,  -13'sd1920 };
			
            9'd199: tf_out <= { 13'sd702,  -13'sd1924 };
			
            9'd200: tf_out <= { 13'sd690,  -13'sd1928 };
			
            9'd201: tf_out <= { 13'sd678,  -13'sd1932 };
			
            9'd202: tf_out <= { 13'sd666,  -13'sd1937 };
			
            9'd203: tf_out <= { 13'sd654,  -13'sd1941 };
			
            9'd204: tf_out <= { 13'sd642,  -13'sd1945 };
			
            9'd205: tf_out <= { 13'sd630,  -13'sd1949 };
			
            9'd206: tf_out <= { 13'sd619,  -13'sd1952 };
			
            9'd207: tf_out <= { 13'sd607,  -13'sd1956 };
			
            9'd208: tf_out <= { 13'sd595,  -13'sd1960 };
			
            9'd209: tf_out <= { 13'sd582,  -13'sd1963 };
			
            9'd210: tf_out <= { 13'sd570,  -13'sd1967 };
			
            9'd211: tf_out <= { 13'sd558,  -13'sd1970 };
			
            9'd212: tf_out <= { 13'sd546,  -13'sd1974 };
			
            9'd213: tf_out <= { 13'sd534,  -13'sd1977 };
			
            9'd214: tf_out <= { 13'sd522,  -13'sd1980 };
			
            9'd215: tf_out <= { 13'sd510,  -13'sd1984 };
			
            9'd216: tf_out <= { 13'sd498,  -13'sd1987 };
			
            9'd217: tf_out <= { 13'sd485,  -13'sd1990 };
			
            9'd218: tf_out <= { 13'sd473,  -13'sd1993 };
			
            9'd219: tf_out <= { 13'sd461,  -13'sd1995 };
			
            9'd220: tf_out <= { 13'sd449,  -13'sd1998 };
			
            9'd221: tf_out <= { 13'sd436,  -13'sd2001 };
			
            9'd222: tf_out <= { 13'sd424,  -13'sd2004 };
			
            9'd223: tf_out <= { 13'sd412,  -13'sd2006 };
			
            9'd224: tf_out <= { 13'sd400,  -13'sd2009 };
			
            9'd225: tf_out <= { 13'sd387,  -13'sd2011 };
			
            9'd226: tf_out <= { 13'sd375,  -13'sd2013 };
			
            9'd227: tf_out <= { 13'sd363,  -13'sd2016 };
			
            9'd228: tf_out <= { 13'sd350,  -13'sd2018 };
			
            9'd229: tf_out <= { 13'sd338,  -13'sd2020 };
			
            9'd230: tf_out <= { 13'sd325,  -13'sd2022 };
			
            9'd231: tf_out <= { 13'sd313,  -13'sd2024 };
			
            9'd232: tf_out <= { 13'sd301,  -13'sd2026 };
			
            9'd233: tf_out <= { 13'sd288,  -13'sd2028 };
			
            9'd234: tf_out <= { 13'sd276,  -13'sd2029 };
			
            9'd235: tf_out <= { 13'sd263,  -13'sd2031 };
			
            9'd236: tf_out <= { 13'sd251,  -13'sd2033 };
			
            9'd237: tf_out <= { 13'sd238,  -13'sd2034 };
			
            9'd238: tf_out <= { 13'sd226,  -13'sd2036 };
			
            9'd239: tf_out <= { 13'sd213,  -13'sd2037 };
			
            9'd240: tf_out <= { 13'sd201,  -13'sd2038 };
			
            9'd241: tf_out <= { 13'sd188,  -13'sd2039 };
			
            9'd242: tf_out <= { 13'sd176,  -13'sd2040 };
			
            9'd243: tf_out <= { 13'sd163,  -13'sd2041 };
			
            9'd244: tf_out <= { 13'sd151,  -13'sd2042 };
			
            9'd245: tf_out <= { 13'sd138,  -13'sd2043 };
			
            9'd246: tf_out <= { 13'sd126,  -13'sd2044 };
			
            9'd247: tf_out <= { 13'sd113,  -13'sd2045 };
			
            9'd248: tf_out <= { 13'sd100,  -13'sd2046 };
			
            9'd249: tf_out <= { 13'sd88,  -13'sd2046 };
			
            9'd250: tf_out <= { 13'sd75,  -13'sd2047 };
			
            9'd251: tf_out <= { 13'sd63,  -13'sd2047 };
			
            9'd252: tf_out <= { 13'sd50,  -13'sd2047 };
			
            9'd253: tf_out <= { 13'sd38,  -13'sd2048 };
			
            9'd254: tf_out <= { 13'sd25,  -13'sd2048 };
			
            9'd255: tf_out <= { 13'sd13,  -13'sd2048 };
			
            9'd256: tf_out <= { 13'sd0,  -13'sd2048 };
			
            9'd257: tf_out <= { -13'sd13,  -13'sd2048 };
			
            9'd258: tf_out <= { -13'sd25,  -13'sd2048 };
			
            9'd259: tf_out <= { -13'sd38,  -13'sd2048 };
			
            9'd260: tf_out <= { -13'sd50,  -13'sd2047 };
			
            9'd261: tf_out <= { -13'sd63,  -13'sd2047 };
			
            9'd262: tf_out <= { -13'sd75,  -13'sd2047 };
			
            9'd263: tf_out <= { -13'sd88,  -13'sd2046 };
			
            9'd264: tf_out <= { -13'sd100,  -13'sd2046 };
			
            9'd265: tf_out <= { -13'sd113,  -13'sd2045 };
			
            9'd266: tf_out <= { -13'sd126,  -13'sd2044 };
			
            9'd267: tf_out <= { -13'sd138,  -13'sd2043 };
			
            9'd268: tf_out <= { -13'sd151,  -13'sd2042 };
			
            9'd269: tf_out <= { -13'sd163,  -13'sd2041 };
			
            9'd270: tf_out <= { -13'sd176,  -13'sd2040 };
			
            9'd271: tf_out <= { -13'sd188,  -13'sd2039 };
			
            9'd272: tf_out <= { -13'sd201,  -13'sd2038 };
			
            9'd273: tf_out <= { -13'sd213,  -13'sd2037 };
			
            9'd274: tf_out <= { -13'sd226,  -13'sd2036 };
			
            9'd275: tf_out <= { -13'sd238,  -13'sd2034 };
			
            9'd276: tf_out <= { -13'sd251,  -13'sd2033 };
			
            9'd277: tf_out <= { -13'sd263,  -13'sd2031 };
			
            9'd278: tf_out <= { -13'sd276,  -13'sd2029 };
			
            9'd279: tf_out <= { -13'sd288,  -13'sd2028 };
			
            9'd280: tf_out <= { -13'sd301,  -13'sd2026 };
			
            9'd281: tf_out <= { -13'sd313,  -13'sd2024 };
			
            9'd282: tf_out <= { -13'sd325,  -13'sd2022 };
			
            9'd283: tf_out <= { -13'sd338,  -13'sd2020 };
			
            9'd284: tf_out <= { -13'sd350,  -13'sd2018 };
			
            9'd285: tf_out <= { -13'sd363,  -13'sd2016 };
			
            9'd286: tf_out <= { -13'sd375,  -13'sd2013 };
			
            9'd287: tf_out <= { -13'sd387,  -13'sd2011 };
			
            9'd288: tf_out <= { -13'sd400,  -13'sd2009 };
			
            9'd289: tf_out <= { -13'sd412,  -13'sd2006 };
			
            9'd290: tf_out <= { -13'sd424,  -13'sd2004 };
			
            9'd291: tf_out <= { -13'sd436,  -13'sd2001 };
			
            9'd292: tf_out <= { -13'sd449,  -13'sd1998 };
			
            9'd293: tf_out <= { -13'sd461,  -13'sd1995 };
			
            9'd294: tf_out <= { -13'sd473,  -13'sd1993 };
			
            9'd295: tf_out <= { -13'sd485,  -13'sd1990 };
			
            9'd296: tf_out <= { -13'sd498,  -13'sd1987 };
			
            9'd297: tf_out <= { -13'sd510,  -13'sd1984 };
			
            9'd298: tf_out <= { -13'sd522,  -13'sd1980 };
			
            9'd299: tf_out <= { -13'sd534,  -13'sd1977 };
			
            9'd300: tf_out <= { -13'sd546,  -13'sd1974 };
			
            9'd301: tf_out <= { -13'sd558,  -13'sd1970 };
			
            9'd302: tf_out <= { -13'sd570,  -13'sd1967 };
			
            9'd303: tf_out <= { -13'sd582,  -13'sd1963 };
			
            9'd304: tf_out <= { -13'sd595,  -13'sd1960 };
			
            9'd305: tf_out <= { -13'sd607,  -13'sd1956 };
			
            9'd306: tf_out <= { -13'sd619,  -13'sd1952 };
			
            9'd307: tf_out <= { -13'sd630,  -13'sd1949 };
			
            9'd308: tf_out <= { -13'sd642,  -13'sd1945 };
			
            9'd309: tf_out <= { -13'sd654,  -13'sd1941 };
			
            9'd310: tf_out <= { -13'sd666,  -13'sd1937 };
			
            9'd311: tf_out <= { -13'sd678,  -13'sd1932 };
			
            9'd312: tf_out <= { -13'sd690,  -13'sd1928 };
			
            9'd313: tf_out <= { -13'sd702,  -13'sd1924 };
			
            9'd314: tf_out <= { -13'sd714,  -13'sd1920 };
			
            9'd315: tf_out <= { -13'sd725,  -13'sd1915 };
			
            9'd316: tf_out <= { -13'sd737,  -13'sd1911 };
			
            9'd317: tf_out <= { -13'sd749,  -13'sd1906 };
			
            9'd318: tf_out <= { -13'sd760,  -13'sd1902 };
			
            9'd319: tf_out <= { -13'sd772,  -13'sd1897 };
			
            9'd320: tf_out <= { -13'sd784,  -13'sd1892 };
			
            9'd321: tf_out <= { -13'sd795,  -13'sd1887 };
			
            9'd322: tf_out <= { -13'sd807,  -13'sd1882 };
			
            9'd323: tf_out <= { -13'sd818,  -13'sd1877 };
			
            9'd324: tf_out <= { -13'sd830,  -13'sd1872 };
			
            9'd325: tf_out <= { -13'sd841,  -13'sd1867 };
			
            9'd326: tf_out <= { -13'sd853,  -13'sd1862 };
			
            9'd327: tf_out <= { -13'sd864,  -13'sd1857 };
			
            9'd328: tf_out <= { -13'sd876,  -13'sd1851 };
			
            9'd329: tf_out <= { -13'sd887,  -13'sd1846 };
			
            9'd330: tf_out <= { -13'sd898,  -13'sd1840 };
			
            9'd331: tf_out <= { -13'sd910,  -13'sd1835 };
			
            9'd332: tf_out <= { -13'sd921,  -13'sd1829 };
			
            9'd333: tf_out <= { -13'sd932,  -13'sd1824 };
			
            9'd334: tf_out <= { -13'sd943,  -13'sd1818 };
			
            9'd335: tf_out <= { -13'sd954,  -13'sd1812 };
			
            9'd336: tf_out <= { -13'sd965,  -13'sd1806 };
			
            9'd337: tf_out <= { -13'sd976,  -13'sd1800 };
			
            9'd338: tf_out <= { -13'sd988,  -13'sd1794 };
			
            9'd339: tf_out <= { -13'sd999,  -13'sd1788 };
			
            9'd340: tf_out <= { -13'sd1009,  -13'sd1782 };
			
            9'd341: tf_out <= { -13'sd1020,  -13'sd1776 };
			
            9'd342: tf_out <= { -13'sd1031,  -13'sd1769 };
			
            9'd343: tf_out <= { -13'sd1042,  -13'sd1763 };
			
            9'd344: tf_out <= { -13'sd1053,  -13'sd1757 };
			
            9'd345: tf_out <= { -13'sd1064,  -13'sd1750 };
			
            9'd346: tf_out <= { -13'sd1074,  -13'sd1744 };
			
            9'd347: tf_out <= { -13'sd1085,  -13'sd1737 };
			
            9'd348: tf_out <= { -13'sd1096,  -13'sd1730 };
			
            9'd349: tf_out <= { -13'sd1106,  -13'sd1724 };
			
            9'd350: tf_out <= { -13'sd1117,  -13'sd1717 };
			
            9'd351: tf_out <= { -13'sd1127,  -13'sd1710 };
			
            9'd352: tf_out <= { -13'sd1138,  -13'sd1703 };
			
            9'd353: tf_out <= { -13'sd1148,  -13'sd1696 };
			
            9'd354: tf_out <= { -13'sd1159,  -13'sd1689 };
			
            9'd355: tf_out <= { -13'sd1169,  -13'sd1682 };
			
            9'd356: tf_out <= { -13'sd1179,  -13'sd1674 };
			
            9'd357: tf_out <= { -13'sd1190,  -13'sd1667 };
			
            9'd358: tf_out <= { -13'sd1200,  -13'sd1660 };
			
            9'd359: tf_out <= { -13'sd1210,  -13'sd1652 };
			
            9'd360: tf_out <= { -13'sd1220,  -13'sd1645 };
			
            9'd361: tf_out <= { -13'sd1230,  -13'sd1637 };
			
            9'd362: tf_out <= { -13'sd1240,  -13'sd1630 };
			
            9'd363: tf_out <= { -13'sd1250,  -13'sd1622 };
			
            9'd364: tf_out <= { -13'sd1260,  -13'sd1615 };
			
            9'd365: tf_out <= { -13'sd1270,  -13'sd1607 };
			
            9'd366: tf_out <= { -13'sd1280,  -13'sd1599 };
			
            9'd367: tf_out <= { -13'sd1289,  -13'sd1591 };
			
            9'd368: tf_out <= { -13'sd1299,  -13'sd1583 };
			
            9'd369: tf_out <= { -13'sd1309,  -13'sd1575 };
			
            9'd370: tf_out <= { -13'sd1319,  -13'sd1567 };
			
            9'd371: tf_out <= { -13'sd1328,  -13'sd1559 };
			
            9'd372: tf_out <= { -13'sd1338,  -13'sd1551 };
			
            9'd373: tf_out <= { -13'sd1347,  -13'sd1543 };
			
            9'd374: tf_out <= { -13'sd1357,  -13'sd1534 };
			
            9'd375: tf_out <= { -13'sd1366,  -13'sd1526 };
			
            9'd376: tf_out <= { -13'sd1375,  -13'sd1517 };
			
            9'd377: tf_out <= { -13'sd1385,  -13'sd1509 };
			
            9'd378: tf_out <= { -13'sd1394,  -13'sd1500 };
			
            9'd379: tf_out <= { -13'sd1403,  -13'sd1492 };
			
            9'd380: tf_out <= { -13'sd1412,  -13'sd1483 };
			
            9'd381: tf_out <= { -13'sd1421,  -13'sd1475 };
			
            9'd382: tf_out <= { -13'sd1430,  -13'sd1466 };
			
            9'd383: tf_out <= { -13'sd1439,  -13'sd1457 };
			
            9'd384: tf_out <= { -13'sd1448,  -13'sd1448 };
			
            9'd385: tf_out <= { -13'sd1457,  -13'sd1439 };
			
            9'd386: tf_out <= { -13'sd1466,  -13'sd1430 };
			
            9'd387: tf_out <= { -13'sd1475,  -13'sd1421 };
			
            9'd388: tf_out <= { -13'sd1483,  -13'sd1412 };
			
            9'd389: tf_out <= { -13'sd1492,  -13'sd1403 };
			
            9'd390: tf_out <= { -13'sd1500,  -13'sd1394 };
			
            9'd391: tf_out <= { -13'sd1509,  -13'sd1385 };
			
            9'd392: tf_out <= { -13'sd1517,  -13'sd1375 };
			
            9'd393: tf_out <= { -13'sd1526,  -13'sd1366 };
			
            9'd394: tf_out <= { -13'sd1534,  -13'sd1357 };
			
            9'd395: tf_out <= { -13'sd1543,  -13'sd1347 };
			
            9'd396: tf_out <= { -13'sd1551,  -13'sd1338 };
			
            9'd397: tf_out <= { -13'sd1559,  -13'sd1328 };
			
            9'd398: tf_out <= { -13'sd1567,  -13'sd1319 };
			
            9'd399: tf_out <= { -13'sd1575,  -13'sd1309 };
			
            9'd400: tf_out <= { -13'sd1583,  -13'sd1299 };
			
            9'd401: tf_out <= { -13'sd1591,  -13'sd1289 };
			
            9'd402: tf_out <= { -13'sd1599,  -13'sd1280 };
			
            9'd403: tf_out <= { -13'sd1607,  -13'sd1270 };
			
            9'd404: tf_out <= { -13'sd1615,  -13'sd1260 };
			
            9'd405: tf_out <= { -13'sd1622,  -13'sd1250 };
			
            9'd406: tf_out <= { -13'sd1630,  -13'sd1240 };
			
            9'd407: tf_out <= { -13'sd1637,  -13'sd1230 };
			
            9'd408: tf_out <= { -13'sd1645,  -13'sd1220 };
			
            9'd409: tf_out <= { -13'sd1652,  -13'sd1210 };
			
            9'd410: tf_out <= { -13'sd1660,  -13'sd1200 };
			
            9'd411: tf_out <= { -13'sd1667,  -13'sd1190 };
			
            9'd412: tf_out <= { -13'sd1674,  -13'sd1179 };
			
            9'd413: tf_out <= { -13'sd1682,  -13'sd1169 };
			
            9'd414: tf_out <= { -13'sd1689,  -13'sd1159 };
			
            9'd415: tf_out <= { -13'sd1696,  -13'sd1148 };
			
            9'd416: tf_out <= { -13'sd1703,  -13'sd1138 };
			
            9'd417: tf_out <= { -13'sd1710,  -13'sd1127 };
			
            9'd418: tf_out <= { -13'sd1717,  -13'sd1117 };
			
            9'd419: tf_out <= { -13'sd1724,  -13'sd1106 };
			
            9'd420: tf_out <= { -13'sd1730,  -13'sd1096 };
			
            9'd421: tf_out <= { -13'sd1737,  -13'sd1085 };
			
            9'd422: tf_out <= { -13'sd1744,  -13'sd1074 };
			
            9'd423: tf_out <= { -13'sd1750,  -13'sd1064 };
			
            9'd424: tf_out <= { -13'sd1757,  -13'sd1053 };
			
            9'd425: tf_out <= { -13'sd1763,  -13'sd1042 };
			
            9'd426: tf_out <= { -13'sd1769,  -13'sd1031 };
			
            9'd427: tf_out <= { -13'sd1776,  -13'sd1020 };
			
            9'd428: tf_out <= { -13'sd1782,  -13'sd1009 };
			
            9'd429: tf_out <= { -13'sd1788,  -13'sd999 };
			
            9'd430: tf_out <= { -13'sd1794,  -13'sd988 };
			
            9'd431: tf_out <= { -13'sd1800,  -13'sd976 };
			
            9'd432: tf_out <= { -13'sd1806,  -13'sd965 };
			
            9'd433: tf_out <= { -13'sd1812,  -13'sd954 };
			
            9'd434: tf_out <= { -13'sd1818,  -13'sd943 };
			
            9'd435: tf_out <= { -13'sd1824,  -13'sd932 };
			
            9'd436: tf_out <= { -13'sd1829,  -13'sd921 };
			
            9'd437: tf_out <= { -13'sd1835,  -13'sd910 };
			
            9'd438: tf_out <= { -13'sd1840,  -13'sd898 };
			
            9'd439: tf_out <= { -13'sd1846,  -13'sd887 };
			
            9'd440: tf_out <= { -13'sd1851,  -13'sd876 };
			
            9'd441: tf_out <= { -13'sd1857,  -13'sd864 };
			
            9'd442: tf_out <= { -13'sd1862,  -13'sd853 };
			
            9'd443: tf_out <= { -13'sd1867,  -13'sd841 };
			
            9'd444: tf_out <= { -13'sd1872,  -13'sd830 };
			
            9'd445: tf_out <= { -13'sd1877,  -13'sd818 };
			
            9'd446: tf_out <= { -13'sd1882,  -13'sd807 };
			
            9'd447: tf_out <= { -13'sd1887,  -13'sd795 };
			
            9'd448: tf_out <= { -13'sd1892,  -13'sd784 };
			
            9'd449: tf_out <= { -13'sd1897,  -13'sd772 };
			
            9'd450: tf_out <= { -13'sd1902,  -13'sd760 };
			
            9'd451: tf_out <= { -13'sd1906,  -13'sd749 };
			
            9'd452: tf_out <= { -13'sd1911,  -13'sd737 };
			
            9'd453: tf_out <= { -13'sd1915,  -13'sd725 };
			
            9'd454: tf_out <= { -13'sd1920,  -13'sd714 };
			
            9'd455: tf_out <= { -13'sd1924,  -13'sd702 };
			
            9'd456: tf_out <= { -13'sd1928,  -13'sd690 };
			
            9'd457: tf_out <= { -13'sd1932,  -13'sd678 };
			
            9'd458: tf_out <= { -13'sd1937,  -13'sd666 };
			
            9'd459: tf_out <= { -13'sd1941,  -13'sd654 };
			
            9'd460: tf_out <= { -13'sd1945,  -13'sd642 };
			
            9'd461: tf_out <= { -13'sd1949,  -13'sd630 };
			
            9'd462: tf_out <= { -13'sd1952,  -13'sd619 };
			
            9'd463: tf_out <= { -13'sd1956,  -13'sd607 };
			
            9'd464: tf_out <= { -13'sd1960,  -13'sd595 };
			
            9'd465: tf_out <= { -13'sd1963,  -13'sd582 };
			
            9'd466: tf_out <= { -13'sd1967,  -13'sd570 };
			
            9'd467: tf_out <= { -13'sd1970,  -13'sd558 };
			
            9'd468: tf_out <= { -13'sd1974,  -13'sd546 };
			
            9'd469: tf_out <= { -13'sd1977,  -13'sd534 };
			
            9'd470: tf_out <= { -13'sd1980,  -13'sd522 };
			
            9'd471: tf_out <= { -13'sd1984,  -13'sd510 };
			
            9'd472: tf_out <= { -13'sd1987,  -13'sd498 };
			
            9'd473: tf_out <= { -13'sd1990,  -13'sd485 };
			
            9'd474: tf_out <= { -13'sd1993,  -13'sd473 };
			
            9'd475: tf_out <= { -13'sd1995,  -13'sd461 };
			
            9'd476: tf_out <= { -13'sd1998,  -13'sd449 };
			
            9'd477: tf_out <= { -13'sd2001,  -13'sd436 };
			
            9'd478: tf_out <= { -13'sd2004,  -13'sd424 };
			
            9'd479: tf_out <= { -13'sd2006,  -13'sd412 };
			
            9'd480: tf_out <= { -13'sd2009,  -13'sd400 };
			
            9'd481: tf_out <= { -13'sd2011,  -13'sd387 };
			
            9'd482: tf_out <= { -13'sd2013,  -13'sd375 };
			
            9'd483: tf_out <= { -13'sd2016,  -13'sd363 };
			
            9'd484: tf_out <= { -13'sd2018,  -13'sd350 };
			
            9'd485: tf_out <= { -13'sd2020,  -13'sd338 };
			
            9'd486: tf_out <= { -13'sd2022,  -13'sd325 };
			
            9'd487: tf_out <= { -13'sd2024,  -13'sd313 };
			
            9'd488: tf_out <= { -13'sd2026,  -13'sd301 };
			
            9'd489: tf_out <= { -13'sd2028,  -13'sd288 };
			
            9'd490: tf_out <= { -13'sd2029,  -13'sd276 };
			
            9'd491: tf_out <= { -13'sd2031,  -13'sd263 };
			
            9'd492: tf_out <= { -13'sd2033,  -13'sd251 };
			
            9'd493: tf_out <= { -13'sd2034,  -13'sd238 };
			
            9'd494: tf_out <= { -13'sd2036,  -13'sd226 };
			
            9'd495: tf_out <= { -13'sd2037,  -13'sd213 };
			
            9'd496: tf_out <= { -13'sd2038,  -13'sd201 };
			
            9'd497: tf_out <= { -13'sd2039,  -13'sd188 };
			
            9'd498: tf_out <= { -13'sd2040,  -13'sd176 };
			
            9'd499: tf_out <= { -13'sd2041,  -13'sd163 };
			
            9'd500: tf_out <= { -13'sd2042,  -13'sd151 };
			
            9'd501: tf_out <= { -13'sd2043,  -13'sd138 };
			
            9'd502: tf_out <= { -13'sd2044,  -13'sd126 };
			
            9'd503: tf_out <= { -13'sd2045,  -13'sd113 };
			
            9'd504: tf_out <= { -13'sd2046,  -13'sd100 };
			
            9'd505: tf_out <= { -13'sd2046,  -13'sd88 };
			
            9'd506: tf_out <= { -13'sd2047,  -13'sd75 };
			
            9'd507: tf_out <= { -13'sd2047,  -13'sd63 };
			
            9'd508: tf_out <= { -13'sd2047,  -13'sd50 };
			
            9'd509: tf_out <= { -13'sd2048,  -13'sd38 };
			
            9'd510: tf_out <= { -13'sd2048,  -13'sd25 };
			
            9'd511: tf_out <= { -13'sd2048,  -13'sd13 };
			
            default:
              begin
                tf_out <= 26'd0;
              end
         endcase
      end
  end
endmodule