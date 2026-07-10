* ==========================================================
* cncity 回归测试
* 用法：在本文件夹下运行  do test_cncity.do
* 全部通过时最后显示 ALL TESTS PASSED；任一 assert 失败即中断
* ==========================================================
clear all

* ---------- 构造测试数据 ----------
input strL city
"北京"
"石家庄市"
"马鞍山"
"鞍山市"
"沈阳"
"芒市"
"茫崖市"
"兴安"
"锡林浩特市"
"恩施"
"香港"
"台北市"
"义乌"
"不存在的地名"
""
"阿勒泰地区"
end

* ---------- 1. 默认运行（不带 detail） ----------
run "D:\Code\Github\cncity\cncity.ado"
cncity city

* 默认不生成 city_special / special_ctlist
capture confirm variable city_special
assert _rc != 0
capture confirm variable special_ctlist
assert _rc != 0
* 特殊地区的省份回填在无 detail 时也应生效
assert city_stname == "" & city_prov == "内蒙古自治区" in 8

cncity city, d replace

assert city_stname == "北京市"   & city_type == "直辖市" & city_prov == "北京市" & city_code == "110000" in 1
assert city_stname == "石家庄市" & city_type == "地级市" & city_prov == "河北省" & city_code == "130100" in 2
* 鞍山排除只作用于鞍山：马鞍山应匹配安徽马鞍山市
assert city_stname == "马鞍山市" & city_prov == "安徽省" & city_code == "340500" in 3
assert city_stname == "鞍山市"   & city_prov == "辽宁省" & city_code == "210300" in 4
assert city_stname == "沈阳市"   & city_code == "210100" in 5
* 芒市两字匹配
assert city_stname == "芒市" & city_prov == "云南省" & city_code == "533103" in 6
* 茫崖不应误配芒市
assert city_stname == "茫崖市" & city_prov == "青海省" & city_code == "632803" in 7
assert city_stname == "" & city_prov == "内蒙古自治区" in 8
assert city_stname == "锡林浩特市" & city_code == "152502" in 9
assert city_stname == "恩施市" & city_prov == "湖北省" & city_code == "422801" in 10
assert city_stname == "香港特别行政区" & city_code == "810000" in 11
assert city_stname == "台北市" & city_prov == "台湾省" & city_code == "" in 12
assert city_stname == "义乌市" & city_prov == "浙江省" & city_code == "330782" in 13
assert city_stname == "" & city_code == "" in 14
assert city_stname == "" & city_prov == "新疆维吾尔自治区" & city_code == "" in 16

di as res "TEST 1 PASSED: 默认运行（含 city_code，无 special 变量）"

* ---------- 2. detail 选项（缩写 d） ----------
cncity city, replace d

confirm variable city_special
confirm variable special_ctlist
assert city_special == "德宏傣族景颇族自治州" in 6
assert city_special == "兴安盟" in 8
assert city_special == "锡林郭勒盟" & city_stname == "锡林浩特市" in 9
assert city_special == "恩施土家族苗族自治州" & city_stname == "恩施市" in 10
assert city_special == "阿勒泰地区" & special_ctlist == "阿勒泰市" in 16

di as res "TEST 2 PASSED: detail 选项"

* ---------- 3. 重复运行：无 replace 应报错 110 ----------
capture noisily cncity city
assert _rc == 110
di as res "TEST 3 PASSED: 无 replace 重复运行报错 110"

* ---------- 4. detail 后再无 detail 重跑：replace 应清掉 special 变量 ----------
cncity city, replace
capture confirm variable city_special
assert _rc != 0
assert city_stname == "北京市" in 1
di as res "TEST 4 PASSED: replace 选项"

* ---------- 5. if 限定 ----------
cncity city if _n <= 5, replace
assert city_stname == "沈阳市" in 5
assert city_stname == "" & city_code == "" in 6
assert city_stname == "" in 12
di as res "TEST 5 PASSED: if 限定"

* ---------- 6. 非字符串变量应报错 ----------
gen num = _n
capture cncity num, replace
assert _rc != 0
di as res "TEST 6 PASSED: 非字符串变量报错"

di as res "ALL TESTS PASSED"
