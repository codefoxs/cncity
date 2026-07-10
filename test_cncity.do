* ==========================================================
* cncity 回归测试
* 用法：在本文件夹下运行  do test_cncity.do
* 全部通过时最后显示 ALL TESTS PASSED；任一 assert 失败即中断
* ==========================================================
clear all
adopath ++ "`c(pwd)'"

* ---------- 构造测试数据 ----------
input strL city
"北京海淀区"
"石家庄高新区"
"马鞍山经济开发区"
"鞍山铁东区"
"沈阳市和平区"
"云南芒市"
"茫崖冷湖镇"
"兴安"
"锡林浩特市"
"恩施州恩施市"
"香港中环"
"台北信义区"
"义乌小商品城"
"不存在的地名"
""
"阿勒泰地区"
end

* ---------- 1. 基本运行 ----------
cncity city

assert city_stname == "北京市"   & city_type == "直辖市" & city_prov == "北京市" in 1
assert city_stname == "石家庄市" & city_type == "地级市" & city_prov == "河北省" in 2
* 鞍山排除只作用于鞍山：马鞍山应匹配安徽马鞍山市
assert city_stname == "马鞍山市" & city_prov == "安徽省" in 3
assert city_stname == "鞍山市"   & city_prov == "辽宁省" in 4
assert city_stname == "沈阳市"   in 5
* 芒市两字匹配
assert city_stname == "芒市" & city_special == "德宏傣族景颇族自治州" in 6
* 茫崖不应误配芒市
assert city_stname == "茫崖市" & city_prov == "青海省" in 7
assert city_special == "兴安盟" & city_stname == "" in 8
* 原始字符串不含"地区/自治州/盟"字样时，城市名保留
assert city_special == "锡林郭勒盟" & city_stname == "锡林浩特市" in 9
assert city_special == "恩施土家族苗族自治州" & city_stname == "恩施市" in 10
assert city_stname == "香港特别行政区" in 11
assert city_stname == "台北市" & city_prov == "台湾省" in 12
assert city_stname == "义乌市" & city_prov == "浙江省" in 13
assert city_stname == "" & city_special == "" in 14
assert city_special == "阿勒泰地区" & city_prov == "新疆维吾尔自治区" in 16

di as res "TEST 1 PASSED: 基本匹配"

* ---------- 2. 重复运行：无 replace 应报错 110 ----------
capture noisily cncity city
assert _rc == 110
di as res "TEST 2 PASSED: 无 replace 重复运行报错 110"

* ---------- 3. 重复运行：有 replace 应成功 ----------
cncity city, replace
assert city_stname == "北京市" in 1
di as res "TEST 3 PASSED: replace 选项"

* ---------- 4. if 限定 ----------
cncity city if _n <= 5, replace
assert city_stname == "沈阳市" in 5
assert city_stname == "" in 6
assert city_stname == "" in 12
di as res "TEST 4 PASSED: if 限定"

* ---------- 5. 非字符串变量应报错 ----------
gen num = _n
capture cncity num, replace
assert _rc != 0
di as res "TEST 5 PASSED: 非字符串变量报错"

di as res "ALL TESTS PASSED"
