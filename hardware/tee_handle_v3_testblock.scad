// =====================================================================
//  TEE 模型ハンドル v3 試作ブロック（ボリューム＋歯車方式、滑らかなダイヤル）
//  2026-10-17 下書き
//
//  ダイヤル・同軸パイプ・歯車・ボリューム2個の部分だけを切り出した「試作ブロック」。
//  これで回り具合・歯車のかみ合わせ・重さを確かめてから、ハンドル本体に組み込む。
//
//  OpenSCAD で開き、PART を切り替えて F5（確認）/ F6 → F7（STL書き出し）
//  単位：mm   座標：+X = ダイヤル側（外）、-X = ハンドルの内側、ダイヤル軸 = X 軸
//
//  ★ の値は商品ページ・規格からの仮の値。部品が届いたらノギスで測って上書きする。
//     まず PART = "fit_test" を印刷して、はめあいの値（*_FIT, *_CLEAR）を決めるのがおすすめ。
//
//  組み立ての流れ（概略）
//   1) 枠の U 字の切り欠きに、ボリュームA（上）・B（下）を差し込み、付属ナットで留める
//   2) 外側パイプ(6mm)を、外から枠の穴に通す（Oリングを先に通しておく）
//   3) 枠の内側で、外側パイプに大ダイヤル用の歯車A を押し込む
//   4) 内側パイプ(5mm)を外側パイプに通し、内側の端に歯車B を押し込む
//   5) ボリュームの軸の先端に小歯車A・B を押し込む（ギザギザ軸に圧入）
//   6) 外で大ダイヤル・小ダイヤルを付け、M3イモネジ（中にM3ナット）で留める
// =====================================================================

/* [出力する部品] */
// assembly=組立確認, frame=枠, big_knob=大ダイヤル, small_knob=小ダイヤル, gear_a=歯車A(外側パイプ), pinion_a=小歯車A(ボリュームA), gear_b=歯車B(内側パイプ), pinion_b=小歯車B(ボリュームB), fit_test=はめあい試験片
PART = "assembly"; // [assembly, frame, big_knob, small_knob, gear_a, pinion_a, gear_b, pinion_b, fit_test]
// true で印刷向きに回転
PRINT_ORIENT = false;
// 組立図で、ボリューム・パイプ・ナットの簡易モデルを表示する
SHOW_PARTS = true;

/* [歯車（比率はここで決める）] */
MOD = 1.0;           // モジュール（歯の大きさ）。3Dプリントなら 1.0 が無難
Z_GEAR_A   = 16;     // 歯車A（大ダイヤル＝前屈/後屈、外側パイプ）の歯数
Z_PINION_A = 16;     // 小歯車A（ボリュームA）の歯数
Z_GEAR_B   = 14;     // 歯車B（小ダイヤル＝左右屈、内側パイプ）の歯数
Z_PINION_B = 14;     // 小歯車B（ボリュームB）の歯数
GEAR_W     = 5;      // 歯車の厚み
BACKLASH   = 0.15;   // 歯の厚みを減らす量（ガタ）。かみ合わせがきつければ増やす
CD_EXTRA   = 0.15;   // 中心距離に足す余裕。きつければ増やす
POT_RANGE  = 300;    // ボリュームの回転角（秋月 118292 は 300°）
DIAL_TRAVEL_A = 180; // ★実物の大ダイヤルの回転角（止めから止めまで）。大学で測る
DIAL_TRAVEL_B = 120; // ★実物の小ダイヤルの回転角。大学で測る

/* [パイプ] */
OUTER_TUBE_D = 6.0;  // 外側パイプ（K&S アルミ KS9805）外径
INNER_TUBE_D = 5.0;  // 内側パイプ（K&S 真鍮）外径
BORE_CLEAR   = 0.3;  // 枠の穴：パイプが回るための余裕
PRESS_FIT    = 0.0;  // ★歯車の穴：パイプに固定するための値（0＝ぴったり、マイナス＝きつい）。fit_test で決める
KNOB_FIT     = 0.15; // ダイヤルの穴：イモネジで留めるので少しゆるめ

/* [ボリューム（秋月 118292 小型ボリューム 10KΩB）] */
POT_BODY_D  = 17.0;  // 本体の直径（仕様表 17mm）
POT_BODY_T  = 9.5;   // ★本体の厚み（取付面〜背面、端子を除く）
POT_BUSH_D  = 7.0;   // ★取付ネジ部（ブッシュ）の外径（M7 想定）
POT_BUSH_L  = 7.0;   // ★取付ネジ部の長さ（取付面から）
POT_SHAFT_L = 20.0;  // ★軸の長さ（取付面から先端まで。型番 L20 より）
POT_SHAFT_D = 6.0;   // 軸径
POT_NUT_AF  = 10.0;  // ★付属ナットの二面幅
POT_NUT_T   = 2.0;   // ★付属ナットの厚み
POT_HOLE_CLEAR = 0.4;// ブッシュを通す切り欠きの余裕
KNURL_FIT   = -0.2;  // ★小歯車の穴：ギザギザ軸に押し込むので軸径より小さく

/* [枠] */
FRONT_T = 4;     // 前板（ハンドルの側面の壁にあたる）の厚み
BOSS_L  = 8;     // 外側パイプを支える筒の長さ（前板を含む）
BOSS_D  = 12;    // 筒の外径
PLATE_T = 2.5;   // ボリュームを留める板の厚み
RAIL_T  = 3;     // 左右の側板の厚み
FRAME_HY = 14;   // 枠の半幅（Y）
FRAME_HZ = 27;   // 枠の半高さ（Z）
GAP     = 0.3;   // 回る部品どうしのすき間

/* [Oリング（大ダイヤルの重さ）] */
USE_ORING     = true;
ORING_CS      = 2.0;  // 太さ（benrii の 5×2mm を想定）
ORING_DEPTH   = 1.2;  // 前板の溝の深さ
ORING_SQUEEZE = 0.3;  // つぶし量。重くしたければ増やす

/* [ダイヤル] */
BIG_D   = 64;  BIG_T   = 10;  BIG_HUB_D   = 18;
SMALL_D = 42;  SMALL_T = 10;  SMALL_HUB_D = 14;
KNOB_GAP2 = 0.5;     // 大ダイヤルと小ダイヤルのすき間

/* [M3 ナット・イモネジ] */
NUT_AF  = 5.5;   // M3 ナット二面幅（購入品 5.5mm）
NUT_T   = 2.4;   // M3 ナット厚み（購入品 2.4mm）
NUT_CLR = 0.3;   // ナットを入れる穴の余裕
M3_HOLE = 3.2;   // イモネジ・六角レンチを通す穴

$fn = 64;

// ---------------------------------------------------------------------
// 派生寸法（ここは触らない）
// ---------------------------------------------------------------------
C_A = MOD * (Z_GEAR_A + Z_PINION_A) / 2 + CD_EXTRA;  // ダイヤル軸〜ボリュームAの距離（上 +Z）
C_B = MOD * (Z_GEAR_B + Z_PINION_B) / 2 + CD_EXTRA;  // ダイヤル軸〜ボリュームBの距離（下 -Z）
function tip_r(z) = MOD * z / 2 + MOD;

KNOB_GAP = USE_ORING ? ORING_CS - ORING_DEPTH - ORING_SQUEEZE : 0.5;
GA_X1 = -BOSS_L - GAP;   GA_X0 = GA_X1 - GEAR_W;   // 歯車A の X 範囲
GB_X1 = GA_X0 - GAP;     GB_X0 = GB_X1 - GEAR_W;   // 歯車B の X 範囲
TIP_A = GA_X1;  MOUNT_A = TIP_A - POT_SHAFT_L;     // ボリュームA：軸先端・取付面
TIP_B = GB_X1;  MOUNT_B = TIP_B - POT_SHAFT_L;     // ボリュームB：軸先端・取付面
POT_NUT_CORNER = POT_NUT_AF / 2 / cos(30);
PA_LOW  = -C_B + POT_BUSH_D / 2 + 1;               // 板A の下端
PB_HIGH =  C_A - POT_BODY_D / 2 - 1;               // 板B の上端
BIG_X   = KNOB_GAP;                                // 大ダイヤルの内側の面
SMALL_X = KNOB_GAP + BIG_T + KNOB_GAP2;            // 小ダイヤルの内側の面
OUTER_LEN = (KNOB_GAP + BIG_T) - GA_X0;            // 外側パイプを切る長さ
INNER_LEN = (SMALL_X + SMALL_T) - GB_X0;           // 内側パイプを切る長さ
RATIO_A = Z_GEAR_A / Z_PINION_A;
RATIO_B = Z_GEAR_B / Z_PINION_B;

echo(str("[v3] 中心距離 A=", C_A, "  B=", C_B, " mm"));
echo(str("[v3] 歯車比 A=", RATIO_A, "（ダイヤル", DIAL_TRAVEL_A, "° → ボリューム", DIAL_TRAVEL_A * RATIO_A, "°）"));
echo(str("[v3] 歯車比 B=", RATIO_B, "（ダイヤル", DIAL_TRAVEL_B, "° → ボリューム", DIAL_TRAVEL_B * RATIO_B, "°）"));
echo(str("[v3] パイプを切る長さ：外側(6mm) ", OUTER_LEN, " mm／内側(5mm) ", INNER_LEN, " mm"));
echo(str("[v3] 前板の外面からボリュームBの背面まで ", -(MOUNT_B - POT_BODY_T), " mm（ハンドル組込み時に必要な奥行き）"));

_chk = [
  [TIP_A - GEAR_W >= MOUNT_A + POT_BUSH_L, "小歯車Aがボリュームのネジ部にかかる（軸が短い）"],
  [TIP_B - GEAR_W >= MOUNT_B + POT_BUSH_L, "小歯車Bがボリュームのネジ部にかかる（軸が短い）"],
  [PLATE_T + POT_NUT_T <= POT_BUSH_L,      "ボリュームのナットが締まらない（板が厚い）"],
  [C_A - POT_SHAFT_D / 2 - 0.5 >= tip_r(Z_GEAR_B), "ボリュームAの軸が歯車Bに当たる"],
  [TIP_B <= GA_X0,                          "ボリュームBの軸先が歯車Aに当たる"],
  [PB_HIGH <= C_A - POT_BODY_D / 2 - 0.5,   "板BがボリュームAに当たる"],
  [(C_A - POT_BODY_D / 2) - (-C_B + POT_BODY_D / 2) >= 1, "ボリュームA・Bの本体どうしが当たる"],
  [C_A + max(POT_BODY_D / 2, tip_r(Z_PINION_A)) <= FRAME_HZ, "ボリュームA/小歯車Aが枠の上にはみ出す（FRAME_HZ を増やす）"],
  [C_B + max(POT_BODY_D / 2, tip_r(Z_PINION_B)) <= FRAME_HZ, "ボリュームB/小歯車Bが枠の下にはみ出す（FRAME_HZ を増やす）"],
  [max(POT_BODY_D / 2, tip_r(Z_GEAR_A), tip_r(Z_PINION_A)) <= FRAME_HY - RAIL_T - 0.5, "部品が側板に当たる（FRAME_HY を増やす）"],
  [TIP_A <= -BOSS_L && TIP_A <= -FRONT_T - 0.5, "小歯車Aが前板・筒に当たる"],
  [DIAL_TRAVEL_A * RATIO_A <= POT_RANGE - 20, "大ダイヤルを回しきる前にボリュームAが止まる（歯車比を下げる）"],
  [DIAL_TRAVEL_B * RATIO_B <= POT_RANGE - 20, "小ダイヤルを回しきる前にボリュームBが止まる（歯車比を下げる）"],
  [KNOB_GAP > 0, "Oリングの溝が深すぎて大ダイヤルが前板に当たる"],
];
for (c = _chk) if (!c[0]) echo(str("<b>警告：", c[1], "</b>"));
echo(str("[v3] チェック ", len([for (c = _chk) if (!c[0]) 1]) == 0 ? "すべて OK" : "に警告あり（上を見る）"));

// ---------------------------------------------------------------------
// インボリュート平歯車（2D）。歯は角度 0° の向きを中心に作る
// ---------------------------------------------------------------------
function inv_deg(t) = t * 180 / PI - atan(t);   // t はラジアン、戻り値は度
module gear2d(m, z, bl = 0.15, pa = 20) {
    r  = m * z / 2;
    rb = r * cos(pa);
    ra = r + m;
    rf = r - 1.25 * m;
    tmax = sqrt(pow(ra / rb, 2) - 1);
    ht   = 90 / z - (bl / 2) / r * 180 / PI;
    th0  = ht + inv_deg(tan(pa));
    n = 10;
    lower = [for (i = [0 : n]) let(t = tmax * i / n, rr = rb * sqrt(1 + t * t), a = -(th0 - inv_deg(t))) [rr * cos(a), rr * sin(a)]];
    upper = [for (i = [n : -1 : 0]) let(t = tmax * i / n, rr = rb * sqrt(1 + t * t), a = (th0 - inv_deg(t))) [rr * cos(a), rr * sin(a)]];
    rs = min(rf, rb);
    tooth = concat([[rs * cos(-th0), rs * sin(-th0)]], lower, upper, [[rs * cos(th0), rs * sin(th0)]]);
    union() {
        circle(r = rf + 0.05, $fn = z * 6);
        for (i = [0 : z - 1]) rotate(i * 360 / z) polygon(tooth);
    }
}
// 穴あき歯車（z=0 から GEAR_W の厚み）
module gear_part(z, bore) {
    difference() {
        linear_extrude(GEAR_W) gear2d(MOD, z, BACKLASH);
        translate([0, 0, -1]) cylinder(d = bore, h = GEAR_W + 2);
        // 面取り（穴の入口。押し込みやすくする）
        translate([0, 0, -0.01]) cylinder(d1 = bore + 1, d2 = bore, h = 0.5);
    }
}

// ---------------------------------------------------------------------
// 枠
// ---------------------------------------------------------------------
module frame() {
    slot_w = POT_BUSH_D + POT_HOLE_CLEAR;
    difference() {
        union() {
            // 前板
            translate([-FRONT_T, -FRAME_HY, -FRAME_HZ]) cube([FRONT_T, 2 * FRAME_HY, 2 * FRAME_HZ]);
            // 外側パイプを支える筒
            translate([-BOSS_L, 0, 0]) rotate([0, 90, 0]) cylinder(d = BOSS_D, h = BOSS_L);
            // 左右の側板
            for (s = [-1, 1]) translate([MOUNT_B, s > 0 ? FRAME_HY - RAIL_T : -FRAME_HY, -FRAME_HZ])
                cube([-FRONT_T - MOUNT_B + 0.01, RAIL_T, 2 * FRAME_HZ]);
            // 板A（ボリュームA、上）
            translate([MOUNT_A, -FRAME_HY, PA_LOW]) cube([PLATE_T, 2 * FRAME_HY, FRAME_HZ - PA_LOW]);
            // 板B（ボリュームB、下）
            translate([MOUNT_B, -FRAME_HY, -FRAME_HZ]) cube([PLATE_T, 2 * FRAME_HY, PB_HIGH + FRAME_HZ]);
        }
        // パイプの穴
        translate([-BOSS_L - 1, 0, 0]) rotate([0, 90, 0]) cylinder(d = OUTER_TUBE_D + BORE_CLEAR, h = BOSS_L + 2);
        // Oリングの溝（前板の外面）
        if (USE_ORING) translate([-ORING_DEPTH, 0, 0]) rotate([0, 90, 0])
            cylinder(d = OUTER_TUBE_D + 2 * ORING_CS + 0.6, h = ORING_DEPTH + 1);
        // ボリュームA の U 字切り欠き（上に開く）
        translate([MOUNT_A - 1, 0, C_A]) rotate([0, 90, 0]) cylinder(d = slot_w, h = PLATE_T + 2);
        translate([MOUNT_A - 1, -slot_w / 2, C_A]) cube([PLATE_T + 2, slot_w, FRAME_HZ]);
        // ボリュームB の U 字切り欠き（下に開く）
        translate([MOUNT_B - 1, 0, -C_B]) rotate([0, 90, 0]) cylinder(d = slot_w, h = PLATE_T + 2);
        translate([MOUNT_B - 1, -slot_w / 2, -FRAME_HZ - 1]) cube([PLATE_T + 2, slot_w, FRAME_HZ - C_B + 1]);
    }
}

// ---------------------------------------------------------------------
// ダイヤル（z=0 が本体側の面、+z が外向き）
// ---------------------------------------------------------------------
module scalloped_disk(D, t, n, rs) {
    difference() {
        cylinder(d = D, h = t);
        for (i = [0 : n - 1]) rotate([0, 0, i * 360 / n + 180 / n]) translate([D / 2, 0, -1]) cylinder(r = rs, h = t + 2);
    }
}
// M3 ナットを埋め込み、イモネジで軸を押さえる仕組み（外向きの面からナットを落とし込む）
module set_screw_cut(bore_d, zc, h_total, reach) {
    r_nut = bore_d / 2 + 0.8 + (NUT_T + NUT_CLR) / 2;
    // ナットの穴（六角、角が ±z を向く）
    translate([r_nut, 0, zc]) rotate([0, 90, 0]) cylinder(d = (NUT_AF + NUT_CLR) / cos(30), h = NUT_T + NUT_CLR, center = true, $fn = 6);
    // ナットを落とし込む溝（外向きの面まで）
    translate([r_nut - (NUT_T + NUT_CLR) / 2, -(NUT_AF + NUT_CLR) / 2, zc]) cube([NUT_T + NUT_CLR, NUT_AF + NUT_CLR, h_total]);
    // イモネジ・レンチの穴（軸から外周まで）
    translate([0, 0, zc]) rotate([0, 90, 0]) cylinder(d = M3_HOLE, h = reach);
}
module big_knob() {
    WT = min(8, BIG_T);
    difference() {
        union() {
            cylinder(d = BIG_HUB_D, h = BIG_T);
            translate([0, 0, BIG_T - WT]) scalloped_disk(BIG_D, WT, 8, 7);
        }
        translate([0, 0, -1]) cylinder(d = OUTER_TUBE_D + KNOB_FIT, h = BIG_T + 2);
        set_screw_cut(OUTER_TUBE_D + KNOB_FIT, BIG_T / 2, BIG_T, BIG_D);
        // 目印の溝（前屈方向）
        translate([25, -1.5, BIG_T - 1]) cube([8, 3, 2]);
    }
}
module small_knob() {
    WT = min(8, SMALL_T);
    difference() {
        union() {
            cylinder(d = SMALL_HUB_D, h = SMALL_T);
            translate([0, 0, SMALL_T - WT]) scalloped_disk(SMALL_D, WT, 6, 5);
        }
        translate([0, 0, -1]) cylinder(d = INNER_TUBE_D + KNOB_FIT, h = SMALL_T + 2);
        set_screw_cut(INNER_TUBE_D + KNOB_FIT, SMALL_T / 2, SMALL_T, SMALL_D);
        translate([15, -1.2, SMALL_T - 1]) cube([6, 2.4, 2]);
    }
}

// ---------------------------------------------------------------------
// はめあい試験片（厚み5mm）
//  1段目（上）：外側パイプが回る穴    余裕 +0.2 / +0.3 / +0.4
//  2段目      ：外側パイプを固定する穴 -0.1 / 0 / +0.1
//  3段目      ：内側パイプを固定する穴 -0.1 / 0 / +0.1
//  4段目      ：ボリュームの軸（ギザギザ）を押し込む穴 -0.3 / -0.2 / -0.1
//  5段目      ：ボリュームのネジ部の穴 +0.2 / +0.4 / +0.6、右端に M3 ナットの穴
//  左からの順番は、上辺の刻みの本数（1〜3本）
// ---------------------------------------------------------------------
module fit_test() {
    cols = 3; dx = 13; dy = 12;
    rows = [
        [OUTER_TUBE_D, [0.2, 0.3, 0.4]],
        [OUTER_TUBE_D, [-0.1, 0, 0.1]],
        [INNER_TUBE_D, [-0.1, 0, 0.1]],
        [POT_SHAFT_D,  [-0.3, -0.2, -0.1]],
        [POT_BUSH_D,   [0.2, 0.4, 0.6]],
    ];
    W = cols * dx + 14; H = len(rows) * dy + 4;
    difference() {
        cube([W, H, 5]);
        for (j = [0 : len(rows) - 1]) for (i = [0 : cols - 1])
            translate([7 + i * dx, H - 8 - j * dy, -1]) cylinder(d = rows[j][0] + rows[j][1][i], h = 7);
        // M3 ナット
        translate([7 + cols * dx, 8, 5 - NUT_T - NUT_CLR]) cylinder(d = (NUT_AF + NUT_CLR) / cos(30), h = 5, $fn = 6);
        translate([7 + cols * dx, 8, -1]) cylinder(d = M3_HOLE, h = 7);
        // 列番号の刻み
        for (i = [0 : cols - 1]) for (k = [0 : i]) translate([7 + i * dx - 2 + k * 1.6, H - 1.5, 4]) cube([0.7, 2, 2]);
    }
}

// ---------------------------------------------------------------------
// 組立確認用の簡易モデル
// ---------------------------------------------------------------------
module pot_ghost(mount_x, tip_x) {
    // 本体
    translate([mount_x - POT_BODY_T, 0, 0]) rotate([0, 90, 0]) cylinder(d = POT_BODY_D, h = POT_BODY_T);
    // ネジ部
    translate([mount_x, 0, 0]) rotate([0, 90, 0]) cylinder(d = POT_BUSH_D, h = POT_BUSH_L);
    // ナット
    translate([mount_x + PLATE_T, 0, 0]) rotate([0, 90, 0]) cylinder(d = POT_NUT_AF / cos(30), h = POT_NUT_T, $fn = 6);
    // 軸
    translate([mount_x, 0, 0]) rotate([0, 90, 0]) cylinder(d = POT_SHAFT_D, h = tip_x - mount_x);
}
// 歯車を X 軸向きに置く（gx0 = 歯車の -X 側の面）
module place_gear(gx0, cz, rot) {
    translate([gx0, 0, cz]) rotate([0, 90, 0]) rotate([0, 0, rot]) children();
}

module assembly() {
    color("SlateGray") frame();
    // 歯車A・小歯車A（ボリュームAは +Z 側。歯車のローカル座標では -X 方向＝180°）
    color("Orange")     place_gear(GA_X0, 0, 180) gear_part(Z_GEAR_A, OUTER_TUBE_D + PRESS_FIT);
    color("DarkOrange") place_gear(GA_X0, C_A, 180 / Z_PINION_A) gear_part(Z_PINION_A, POT_SHAFT_D + KNURL_FIT);
    // 歯車B・小歯車B（ボリュームBは -Z 側＝ローカル 0°）
    color("Teal")       place_gear(GB_X0, 0, 0) gear_part(Z_GEAR_B, INNER_TUBE_D + PRESS_FIT);
    color("DarkCyan")   place_gear(GB_X0, -C_B, 180 + 180 / Z_PINION_B) gear_part(Z_PINION_B, POT_SHAFT_D + KNURL_FIT);
    // ダイヤル
    color("Orange") translate([BIG_X, 0, 0]) rotate([0, 90, 0]) big_knob();
    color("Teal")   translate([SMALL_X, 0, 0]) rotate([0, 90, 0]) small_knob();
    if (SHOW_PARTS) {
        // ボリューム
        color("SaddleBrown", 0.8) translate([0, 0, C_A]) pot_ghost(MOUNT_A, TIP_A);
        color("SaddleBrown", 0.8) translate([0, 0, -C_B]) pot_ghost(MOUNT_B, TIP_B);
        // パイプ
        color("Silver", 0.6) translate([GA_X0, 0, 0]) rotate([0, 90, 0]) difference() {
            cylinder(d = OUTER_TUBE_D, h = OUTER_LEN); translate([0, 0, -1]) cylinder(d = OUTER_TUBE_D - 0.9, h = OUTER_LEN + 2); }
        color("Gold", 0.8) translate([GB_X0, 0, 0]) rotate([0, 90, 0]) cylinder(d = INNER_TUBE_D, h = INNER_LEN);
        // Oリング
        if (USE_ORING) color("Black") translate([KNOB_GAP - ORING_CS / 2 + ORING_SQUEEZE / 2, 0, 0]) rotate([0, 90, 0])
            rotate_extrude() translate([OUTER_TUBE_D / 2 + ORING_CS / 2, 0]) circle(d = ORING_CS - ORING_SQUEEZE, $fn = 16);
    }
}

// ---------------------------------------------------------------------
// 出力
// ---------------------------------------------------------------------
module place_print(rot) { if (PRINT_ORIENT) rotate(rot) children(); else children(); }

if      (PART == "frame")      place_print([90, 0, 0])  frame();          // 側板を下にして印刷
else if (PART == "big_knob")   place_print([180, 0, 0]) big_knob();       // 外向きの面を下に
else if (PART == "small_knob") place_print([180, 0, 0]) small_knob();
else if (PART == "gear_a")     gear_part(Z_GEAR_A,   OUTER_TUBE_D + PRESS_FIT);
else if (PART == "pinion_a")   gear_part(Z_PINION_A, POT_SHAFT_D + KNURL_FIT);
else if (PART == "gear_b")     gear_part(Z_GEAR_B,   INNER_TUBE_D + PRESS_FIT);
else if (PART == "pinion_b")   gear_part(Z_PINION_B, POT_SHAFT_D + KNURL_FIT);
else if (PART == "fit_test")   fit_test();
else assembly();
