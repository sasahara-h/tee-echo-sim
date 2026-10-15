// =====================================================================
//  TEE プローブ 模型ハンドル（二重同軸ロータリーエンコーダ Bourns PEC11D 用）
//  v2 (2026-10-15)：PEC11D-4120F-S0015 の寸法に合わせて改訂
//  OpenSCAD で開き、下の PART を切り替えて F6 → STL 書き出し
//  単位：mm   座標：+Z = ハンドル上端, +X = 右側面（ダイヤル側）, -Y = 前面（ボタン側）
//
//  ★ 印の寸法はデータシート読み取りの「仮の値」。実物が届いたらノギスで測って上書きする。
//     まず PART = "fit_test" を印刷して、はめあい余裕（*_CLEAR）を決めるのがおすすめ。
// =====================================================================

/* [出力する部品] */
// assembly=組立確認, right=右半分, left=左半分, big_knob=大ダイヤル, small_knob=小ダイヤル, fit_test=はめあい試験片
PART = "assembly"; // [assembly, right, left, big_knob, small_knob, fit_test]
// true にすると印刷向きに回転（平らな外側面が下）
PRINT_ORIENT = false;

/* [本体の形] */
HW   = 17;     // 本体の半幅（X）。左右の外側面は平ら＝印刷時に下になる面
WALL = 2.4;    // 壁厚
RC   = 4;      // 断面の角の丸み
// 高さ方向の断面：[z, 半奥行き(Y)]  グリップ → くびれ → ヘッド
STATIONS = [[0, 17], [110, 18], [126, 24], [178, 24]];

/* [PEC11D 本体] ※ネジ・ナットなし。ブッシュ（筒）を壁穴に通し、本体は受け台＋小基板で固定 */
ENC_Z     = 150;   // エンコーダ軸の高さ
ENC_Y     = 0;     // エンコーダ軸の前後位置
ENC_BODY  = 12.0;  // 本体の一辺（データシート 12.0±0.3）
ENC_BODY_DEPTH = 8.0;  // ★本体の奥行き（取付面〜背面。端子は含まない）
BUSH_D    = 7.0;   // ブッシュ径（データシート 7.0 +0/-0.05、ネジ山なし）
BUSH_LEN  = 5.0;   // ★ブッシュ長（取付面から）
ENC_PANEL_T = 2.0; // エンコーダ部分だけ壁をこの厚みに薄くする（ブッシュが確実に貫通するように）
BUSH_CLEAR  = 0.3; // ブッシュ穴の余裕（fit_test で決める）
BODY_CLEAR  = 0.3; // 受け台の内のりの余裕（片側ではなく合計）
CRADLE_WALL = 1.6; // 受け台の壁厚
CRADLE_DEPTH = 5;  // 受け台の深さ（本体の回り止め）

/* [エンコーダ用の小基板（ユニバーサル基板を切って使う）] */
PCB_T      = 1.6;  // 基板の厚み
POST_DZ    = 12.5; // 基板止めの柱：エンコーダ軸から上下にこの距離（基板にこの間隔で穴を開ける）
POST_D     = 6.5;  // 柱の太さ
POST_PILOT = 2.5;  // 柱の下穴（M3タッピング）

/* [ダイヤルの軸] ※長さはすべて「取付面」から測る */
OUTER_SHAFT_D   = 6.0;   // 外軸（大ダイヤル用、スリット入り）の直径（データシート 6.0 +0/-0.05）
OUTER_SHAFT_END = 11.7;  // ★外軸の先端までの長さ（候補 10.0 / 11.7 / 13.1。実測必須）
INNER_SHAFT_D   = 3.5;   // ★内軸（小ダイヤル用、金属Dカット）の直径
INNER_D_ACROSS  = 2.5;   // ★内軸のDカット部の「平面〜反対側」の寸法。丸軸なら INNER_SHAFT_D と同じ値に
INNER_SHAFT_END = 20.0;  // 内軸の先端までの長さ（データシート 20.0）
SHAFT_CLEAR     = 0.15;  // 軸穴の余裕（fit_test で決める）
KNOB_GAP        = 1.0;   // 大ダイヤルと本体外面のすき間
KNOB_GAP2       = 0.6;   // 大ダイヤルと小ダイヤルのすき間
SMALL_CAP       = 1.2;   // 小ダイヤル先端のふた（軸先が見えないように）

/* [ボタン（オムニプレーン ＋/−）] */
BTN_D = 7;            // ボタン穴径（12mmタクトスイッチのキャップ用）
BTN_X = 8;            // 前面での左右位置（右半分に入るよう正の値）
BTN_Z = [140, 162];   // 2つのボタンの高さ（下＝−、上＝＋）

/* [ケーブル・ネジ] */
CABLE_D = 12;                                   // 底のケーブル穴
BOSSES  = [[10, 10], [10, -10], [172, 14], [172, -14]]; // ネジボス [z, y]
BOSS_D  = 7;
PILOT_D = 2.5;   // 右半分の下穴（M3タッピング）
CLEAR_D = 3.4;   // 左半分の貫通穴
CBORE_D = 6.2;   // 左外側面のザグリ径
CBORE_H = 2.0;   // ザグリ深さ

$fn = 64;
ZTOP = STATIONS[len(STATIONS) - 1][0];

// ---------------------------------------------------------------------
// 派生寸法（ここは触らない）
// ---------------------------------------------------------------------
MS_X      = HW - ENC_PANEL_T;            // エンコーダ取付面の X 位置
BODY_BACK = MS_X - ENC_BODY_DEPTH;       // 本体背面 = 基板の表面
BUSH_OUT  = BUSH_LEN - ENC_PANEL_T;      // ブッシュが外面から出る長さ
OUTER_OUT = OUTER_SHAFT_END - ENC_PANEL_T; // 外軸が外面から出る長さ
BIG_T     = OUTER_OUT - KNOB_GAP;        // 大ダイヤルの厚み（上面＝外軸の先端）
BIG_CB    = max(BUSH_OUT - KNOB_GAP + 0.5, 0); // 大ダイヤル裏のブッシュ逃げ深さ
BIG_ENGAGE = BIG_T - BIG_CB;             // 外軸がダイヤルにかかる長さ
SMALL_ENGAGE = INNER_SHAFT_END - OUTER_SHAFT_END - KNOB_GAP2; // 内軸がかかる長さ
SMALL_T   = SMALL_ENGAGE + SMALL_CAP;    // 小ダイヤルの厚み
D_FLAT    = INNER_SHAFT_D - INNER_D_ACROSS;

echo(str("[PEC11D] 取付面 X=", MS_X, "  本体背面 X=", BODY_BACK, "（0 より大きければ右半分に収まる）"));
echo(str("[PEC11D] ブッシュ突出 ", BUSH_OUT, " mm / 大ダイヤル厚 ", BIG_T, " mm（外軸のかかり ", BIG_ENGAGE, " mm）"));
echo(str("[PEC11D] 小ダイヤル厚 ", SMALL_T, " mm（内軸のかかり ", SMALL_ENGAGE, " mm）"));
if (BUSH_OUT <= 0)    echo("<b>警告：ブッシュが壁を貫通しません。ENC_PANEL_T を小さくしてください</b>");
if (BIG_ENGAGE < 4)   echo("<b>警告：大ダイヤルの軸のかかりが 4mm 未満です。OUTER_SHAFT_END を実測してください</b>");
if (SMALL_ENGAGE < 4) echo("<b>警告：小ダイヤルの軸のかかりが 4mm 未満です</b>");
if (BODY_BACK - PCB_T < 0.5) echo("<b>警告：基板が左右の分割面に近すぎます</b>");

// ---------------------------------------------------------------------
// 本体
// ---------------------------------------------------------------------
module rr_slice(hw, hd, r) {
    linear_extrude(0.01) offset(r = r) square([2 * (hw - r), 2 * (hd - r)], center = true);
}
// 断面を直線補間でつないだ立体（off = 内側へのオフセット量）
module loft(st, off) {
    for (i = [0 : len(st) - 2]) hull() {
        translate([0, 0, st[i][0]])         rr_slice(HW - off, st[i][1] - off, max(RC - off, 0.5));
        translate([0, 0, st[i + 1][0] - 0.01]) rr_slice(HW - off, st[i + 1][1] - off, max(RC - off, 0.5));
    }
}
function inner_stations() =
    [for (i = [0 : len(STATIONS) - 1])
        [i == 0 ? WALL : (i == len(STATIONS) - 1 ? ZTOP - WALL : STATIONS[i][0]), STATIONS[i][1]]];

module body_solid() {
    difference() {
        loft(STATIONS, 0);
        loft(inner_stations(), WALL);
    }
    // ネジボス（外形からはみ出さないよう外形と交差）
    intersection() {
        loft(STATIONS, 0);
        for (b = BOSSES) translate([0, b[1], b[0]]) rotate([0, 90, 0]) cylinder(d = BOSS_D, h = 2 * HW + 2, center = true);
    }
}
module common_holes() {
    // ボタン穴（前面の壁だけを貫通。内側の柱・受け台は削らない）
    HEAD_HD = STATIONS[len(STATIONS) - 1][1];
    for (z = BTN_Z) translate([BTN_X, -(HEAD_HD - WALL - 0.5), z]) rotate([90, 0, 0]) cylinder(d = BTN_D, h = WALL + 3);
    // 底のケーブル穴
    translate([0, 0, -1]) cylinder(d = CABLE_D, h = WALL + 2);
}

// エンコーダの受け台（四角い筒）と基板止めの柱。右半分の内側に付く
CR_IN  = ENC_BODY + BODY_CLEAR;
CR_OUT = CR_IN + 2 * CRADLE_WALL;
module enc_mount_add() {
    // 受け台：本体の手前側 CRADLE_DEPTH を四方から囲む（回り止め）
    translate([MS_X - CRADLE_DEPTH, ENC_Y - CR_OUT / 2, ENC_Z - CR_OUT / 2])
        cube([HW - WALL - (MS_X - CRADLE_DEPTH) + 0.5, CR_OUT, CR_OUT]);
    // 基板止めの柱（上下2本）。先端が本体背面＝基板の表面
    for (s = [-1, 1]) translate([BODY_BACK, ENC_Y, ENC_Z + s * POST_DZ]) rotate([0, 90, 0])
        cylinder(d = POST_D, h = HW - WALL - BODY_BACK + 0.5);
}
module enc_mount_cut() {
    // 受け台の内側（壁の内側も ENC_PANEL_T まで掘り下げる）
    translate([MS_X - CRADLE_DEPTH - 1, ENC_Y - CR_IN / 2, ENC_Z - CR_IN / 2])
        cube([CRADLE_DEPTH + 1, CR_IN, CR_IN]);
    // ブッシュ穴
    translate([MS_X - 1, ENC_Y, ENC_Z]) rotate([0, 90, 0]) cylinder(d = BUSH_D + BUSH_CLEAR, h = ENC_PANEL_T + 3);
    // 柱の下穴
    for (s = [-1, 1]) translate([BODY_BACK - 1, ENC_Y, ENC_Z + s * POST_DZ]) rotate([0, 90, 0])
        cylinder(d = POST_PILOT, h = 10);
}

module right_half() {
    difference() {
        union() {
            intersection() { body_solid(); translate([0, -100, -10]) cube([100, 200, ZTOP + 20]); }
            enc_mount_add();
        }
        common_holes();
        enc_mount_cut();
        // 下穴（外壁は貫通しない）
        for (b = BOSSES) translate([-0.01, b[1], b[0]]) rotate([0, 90, 0]) cylinder(d = PILOT_D, h = HW - WALL + 0.01);
    }
}
module left_half() {
    difference() {
        intersection() { body_solid(); translate([-100, -100, -10]) cube([100, 200, ZTOP + 20]); }
        common_holes();
        for (b = BOSSES) {
            translate([0.01, b[1], b[0]]) rotate([0, -90, 0]) cylinder(d = CLEAR_D, h = HW + 2);
            translate([-HW + CBORE_H, b[1], b[0]]) rotate([0, -90, 0]) cylinder(d = CBORE_D, h = CBORE_H + 2);
        }
    }
}

// ---------------------------------------------------------------------
// ダイヤル（z=0 が本体側の面）
// ---------------------------------------------------------------------
module round_bore(d, h) { cylinder(d = d, h = h); }
// Dカット穴（d=軸径、flat=削り量、clr=余裕）
module d_bore(d, flat, clr, h) {
    difference() {
        cylinder(d = d + clr, h = h);
        if (flat > 0) translate([(d + clr) / 2 - flat, -d, -1]) cube([d, 2 * d, h + 2]);
    }
}
module scalloped_disk(D, t, n, rs) {
    difference() {
        cylinder(d = D, h = t);
        for (i = [0 : n - 1]) rotate([0, 0, i * 360 / n + 180 / n]) translate([D / 2, 0, -1]) cylinder(r = rs, h = t + 2);
    }
}
// 大ダイヤル：前屈/後屈。外軸に固定（スリット軸なので軽い圧入＋止めネジ）
module big_knob() {
    WT = min(9, BIG_T);
    difference() {
        union() {
            cylinder(d = 18, h = BIG_T);                          // ハブ
            translate([0, 0, BIG_T - WT]) scalloped_disk(64, WT, 8, 7); // 指を掛けるホイール
        }
        // ブッシュの逃げ（ブッシュは回らないので触れないように）
        translate([0, 0, -0.01]) cylinder(d = BUSH_D + 1.0, h = BIG_CB + 0.01);
        // 外軸の穴（貫通。上面が外軸の先端と面一）
        translate([0, 0, -0.01]) round_bore(OUTER_SHAFT_D + SHAFT_CLEAR, BIG_T + 1);
        // 止めネジ M3（外軸にかかる区間の中央）
        translate([0, 0, BIG_CB + BIG_ENGAGE / 2]) rotate([0, 90, 22.5]) cylinder(d = 2.6, h = 40);
        // 目印の溝（前屈方向）
        translate([25, -1.5, BIG_T - 1]) cube([8, 3, 2]);
    }
}
// 小ダイヤル：左屈/右屈。内軸（Dカット）に固定
module small_knob() {
    WT = min(8, SMALL_T);
    difference() {
        union() {
            cylinder(d = 12, h = SMALL_T);
            translate([0, 0, SMALL_T - WT]) scalloped_disk(42, WT, 6, 5);
        }
        translate([0, 0, -0.01]) d_bore(INNER_SHAFT_D, D_FLAT, SHAFT_CLEAR, SMALL_ENGAGE + 0.01);
        // 止めネジ M3：Dカットの平面に当たる向き（+X 側）
        translate([0, 0, SMALL_ENGAGE / 2]) rotate([0, 90, 0]) cylinder(d = 2.6, h = 30);
        translate([15, -1.2, SMALL_T - 1]) cube([6, 2.4, 2]);
    }
}

// ---------------------------------------------------------------------
// はめあい試験片：上段＝ブッシュ穴、中段＝外軸穴、下段＝内軸Dカット穴
// 左から余裕 0.1 / 0.2 / 0.3 / 0.4 mm。刻みの本数が左からの番号
// ---------------------------------------------------------------------
module fit_test() {
    CL = [0.1, 0.2, 0.3, 0.4];
    difference() {
        cube([56, 36, 4]);
        for (i = [0 : 3]) {
            x = 8 + i * 13;
            translate([x, 29, -1]) cylinder(d = BUSH_D + CL[i], h = 6);
            translate([x, 18, -1]) cylinder(d = OUTER_SHAFT_D + CL[i], h = 6);
            translate([x, 7, -1])  d_bore(INNER_SHAFT_D, D_FLAT, CL[i], 6);
            for (k = [0 : i]) translate([x - 3 + k * 2, 34.6, 3]) cube([0.8, 2, 2]); // 番号の刻み
        }
    }
}

// ---------------------------------------------------------------------
// 組立確認用の簡易エンコーダ（赤）
// ---------------------------------------------------------------------
module enc_ghost() {
    translate([BODY_BACK, ENC_Y - ENC_BODY / 2, ENC_Z - ENC_BODY / 2]) cube([ENC_BODY_DEPTH, ENC_BODY, ENC_BODY]);
    translate([MS_X, ENC_Y, ENC_Z]) rotate([0, 90, 0]) {
        cylinder(d = BUSH_D, h = BUSH_LEN);
        cylinder(d = OUTER_SHAFT_D, h = OUTER_SHAFT_END);
        cylinder(d = INNER_SHAFT_D, h = INNER_SHAFT_END);
    }
    // 小基板
    translate([BODY_BACK - PCB_T, ENC_Y - 10, ENC_Z - POST_DZ - 4]) cube([PCB_T, 20, 2 * POST_DZ + 8]);
}

// ---------------------------------------------------------------------
// 出力
// ---------------------------------------------------------------------
module place_print(rot) { if (PRINT_ORIENT) rotate(rot) children(); else children(); }

if (PART == "right")      place_print([0, 90, 0])  right_half();
else if (PART == "left")  place_print([0, -90, 0]) left_half();
else if (PART == "big_knob")   place_print([180, 0, 0]) big_knob();
else if (PART == "small_knob") place_print([180, 0, 0]) small_knob();
else if (PART == "fit_test")   fit_test();
else {
    color("SlateGray") right_half();
    color("DimGray") translate([-25, 0, 0]) left_half();   // 少し離して表示
    color("Red", 0.6) enc_ghost();
    color("Orange") translate([HW + KNOB_GAP, ENC_Y, ENC_Z]) rotate([0, 90, 0]) big_knob();
    color("Teal")   translate([HW + OUTER_OUT + KNOB_GAP2, ENC_Y, ENC_Z]) rotate([0, 90, 0]) small_knob();
}
