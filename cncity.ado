*! version 0.2.0 10Jul2026 重构：省份匹配抽成子程序；改用 ustrregexm；支持 if/in 与 replace 选项；修复重复运行报错、鞍山排除范围过大；芒市改为两字匹配；新增匹配统计
*! version 0.1.3 24Jan2026 Bug fixed Issue #1 @sammybaby233
*! version 0.1.2 18Jan2026 修复了一些特殊地区的匹配 bug
*! version 0.1.1 23Nov2025 公众号：凯恩斯学计量
capture program drop cncity
capture program drop cncity_match
program define cncity
    version 14
    syntax varname(string) [if] [in] [, replace]

    local v "`varlist'"
    marksample touse, strok

    * 检查生成变量是否已存在：默认报错，指定 replace 选项才覆盖
    local newvars "city_stname city_type city_prov city_special special_ctlist"
    foreach nv of local newvars {
        capture confirm new variable `nv'
        if _rc {
            if "`replace'" == "" {
                display as error "变量 `nv' 已存在；如需覆盖请指定 replace 选项，如：cncity `v', replace"
                exit 110
            }
            drop `nv'
        }
    }
    quietly foreach nv of local newvars {
        gen `nv' = ""
    }

    dis as res "正在标准化城市名称，请稍候..."

    qui{
        * ==============================
        * 1. 直辖市
        * ==============================
        foreach c in 北京 天津 上海 重庆 {
            cncity_match `v', touse(`touse') prov("`c'市") type("直辖市") list("`c'")
        }

        * ==============================
        * 2. 省份/自治区 循环处理
        * ==============================
        * --- 河北省 ---
        cncity_match `v', touse(`touse') prov("河北省") type("地级市") ///
            list("石家庄 唐山 秦皇岛 邯郸 邢台 保定 张家口 承德 沧州 廊坊 衡水")
        cncity_match `v', touse(`touse') prov("河北省") type("县级市") ///
            list("辛集 晋州 新乐 遵化 迁安 滦州 武安 南宫 沙河 涿州 定州 安国 高碑店 平泉 泊头 任丘 黄骅 河间 霸州 三河 深州")

        * --- 山西省 ---
        cncity_match `v', touse(`touse') prov("山西省") type("地级市") ///
            list("太原 大同 阳泉 长治 晋城 朔州 晋中 运城 忻州 临汾 吕梁")
        cncity_match `v', touse(`touse') prov("山西省") type("县级市") ///
            list("古交 高平 怀仁 介休 永济 河津 原平 侯马 霍州 孝义 汾阳")

        * --- 内蒙古自治区 ---
        cncity_match `v', touse(`touse') prov("内蒙古自治区") type("地级市") ///
            list("呼和浩特 包头 乌海 赤峰 通辽 鄂尔多斯 呼伦贝尔 巴彦淖尔 乌兰察布")
        cncity_match `v', touse(`touse') prov("内蒙古自治区") type("县级市") ///
            list("霍林郭勒 满洲里 牙克石 扎兰屯 额尔古纳 根河 丰镇 乌兰浩特 阿尔山 二连浩特 锡林浩特")

        * --- 辽宁省 ---
        * issue #1: 鞍山单独处理，排除马鞍山，且排除条件只作用于鞍山本身
        replace city_stname = "鞍山市" if ustrregexm(`v', "鞍山") & !ustrregexm(`v', "马鞍山") & city_stname == "" & `touse'
        replace city_type   = "地级市" if city_stname == "鞍山市" & `touse'
        replace city_prov   = "辽宁省" if city_stname == "鞍山市" & `touse'
        cncity_match `v', touse(`touse') prov("辽宁省") type("地级市") ///
            list("沈阳 大连 抚顺 本溪 丹东 锦州 营口 阜新 辽阳 盘锦 铁岭 朝阳 葫芦岛")
        cncity_match `v', touse(`touse') prov("辽宁省") type("县级市") ///
            list("新民 瓦房店 庄河 海城 东港 凤城 凌海 北镇 盖州 大石桥 灯塔 调兵山 开原 北票 凌源 兴城")

        * --- 吉林省 ---
        cncity_match `v', touse(`touse') prov("吉林省") type("地级市") ///
            list("长春 吉林 四平 辽源 通化 白山 松原 白城")
        cncity_match `v', touse(`touse') prov("吉林省") type("县级市") ///
            list("榆树 德惠 公主岭 蛟河 桦甸 舒兰 磐石 双辽 梅河口 集安 临江 扶余 洮南 大安 延吉 图们 敦化 珲春 龙井 和龙")

        * --- 黑龙江省 ---
        cncity_match `v', touse(`touse') prov("黑龙江省") type("地级市") ///
            list("哈尔滨 齐齐哈尔 鸡西 鹤岗 双鸭山 大庆 伊春 佳木斯 七台河 牡丹江 黑河 绥化")
        cncity_match `v', touse(`touse') prov("黑龙江省") type("县级市") ///
            list("尚志 五常 讷河 虎林 密山 铁力 同江 富锦 抚远 绥芬河 海林 宁安 穆棱 东宁 北安 五大连池 嫩江 安达 肇东 海伦 漠河")

        * --- 江苏省 ---
        cncity_match `v', touse(`touse') prov("江苏省") type("地级市") ///
            list("南京 无锡 徐州 常州 苏州 南通 连云港 淮安 盐城 扬州 镇江 泰州 宿迁")
        cncity_match `v', touse(`touse') prov("江苏省") type("县级市") ///
            list("江阴 宜兴 新沂 邳州 溧阳 常熟 张家港 昆山 太仓 启东 如皋 海安 东台 仪征 高邮 丹阳 扬中 句容 兴化 靖江 泰兴")

        * --- 浙江省 ---
        cncity_match `v', touse(`touse') prov("浙江省") type("地级市") ///
            list("杭州 宁波 温州 嘉兴 湖州 绍兴 金华 衢州 舟山 台州 丽水")
        cncity_match `v', touse(`touse') prov("浙江省") type("县级市") ///
            list("建德 余姚 慈溪 瑞安 乐清 龙港 海宁 平湖 桐乡 诸暨 嵊州 兰溪 义乌 东阳 永康 江山 温岭 临海 玉环 龙泉")

        * --- 安徽省 ---
        cncity_match `v', touse(`touse') prov("安徽省") type("地级市") ///
            list("合肥 芜湖 蚌埠 淮南 马鞍山 淮北 铜陵 安庆 黄山 滁州 阜阳 宿州 六安 亳州 池州 宣城")
        cncity_match `v', touse(`touse') prov("安徽省") type("县级市") ///
            list("巢湖 无为 桐城 潜山 天长 明光 界首 宁国 广德")

        * --- 福建省 ---
        cncity_match `v', touse(`touse') prov("福建省") type("地级市") ///
            list("福州 厦门 莆田 三明 泉州 漳州 南平 龙岩 宁德")
        cncity_match `v', touse(`touse') prov("福建省") type("县级市") ///
            list("福清 永安 石狮 晋江 南安 邵武 武夷山 建瓯 漳平 福安 福鼎")

        * --- 江西省 ---
        cncity_match `v', touse(`touse') prov("江西省") type("地级市") ///
            list("南昌 景德镇 萍乡 九江 新余 鹰潭 赣州 吉安 宜春 抚州 上饶")
        cncity_match `v', touse(`touse') prov("江西省") type("县级市") ///
            list("乐平 瑞昌 共青城 庐山 贵溪 瑞金 龙南 井冈山 丰城 樟树 高安 德兴")

        * --- 山东省 ---
        cncity_match `v', touse(`touse') prov("山东省") type("地级市") ///
            list("济南 青岛 淄博 枣庄 东营 烟台 潍坊 济宁 泰安 威海 日照 临沂 德州 聊城 滨州 菏泽")
        cncity_match `v', touse(`touse') prov("山东省") type("县级市") ///
            list("胶州 平度 莱西 滕州 龙口 莱阳 莱州 招远 栖霞 海阳 青州 诸城 寿光 安丘 高密 昌邑 曲阜 邹城 新泰 肥城 荣成 乳山 乐陵 禹城 临清 邹平")

        * --- 河南省 ---
        cncity_match `v', touse(`touse') prov("河南省") type("地级市") ///
            list("郑州 开封 洛阳 平顶山 安阳 鹤壁 新乡 焦作 濮阳 许昌 漯河 三门峡 南阳 商丘 信阳 周口 驻马店")
        cncity_match `v', touse(`touse') prov("河南省") type("县级市") ///
            list("巩义 荥阳 新密 新郑 登封 舞钢 汝州 林州 卫辉 辉县 长垣 沁阳 孟州 禹州 长葛 义马 灵宝 邓州 永城 项城 济源")

        * --- 湖北省 ---
        cncity_match `v', touse(`touse') prov("湖北省") type("地级市") ///
            list("武汉 黄石 十堰 宜昌 襄阳 鄂州 荆门 孝感 荆州 黄冈 咸宁 随州")
        cncity_match `v', touse(`touse') prov("湖北省") type("县级市") ///
            list("大冶 丹江口 宜都 当阳 枝江 老河口 枣阳 宜城 钟祥 京山 应城 安陆 汉川 石首 洪湖 松滋 监利 麻城 武穴 赤壁 广水 恩施 利川 仙桃 潜江 天门")

        * --- 湖南省 ---
        cncity_match `v', touse(`touse') prov("湖南省") type("地级市") ///
            list("长沙 株洲 湘潭 衡阳 邵阳 岳阳 常德 张家界 益阳 郴州 永州 怀化 娄底")
        cncity_match `v', touse(`touse') prov("湖南省") type("县级市") ///
            list("浏阳 宁乡 醴陵 湘乡 韶山 耒阳 常宁 武冈 邵东 汨罗 临湘 津市 沅江 资兴 祁阳 洪江 冷水江 涟源 吉首")

        * --- 广东省 ---
        cncity_match `v', touse(`touse') prov("广东省") type("地级市") ///
            list("广州 韶关 深圳 珠海 汕头 佛山 江门 湛江 茂名 肇庆 惠州 梅州 汕尾 河源 阳江 清远 东莞 中山 潮州 揭阳 云浮")
        cncity_match `v', touse(`touse') prov("广东省") type("县级市") ///
            list("乐昌 南雄 台山 开平 鹤山 恩平 廉江 雷州 吴川 高州 化州 信宜 四会 兴宁 陆丰 阳春 英德 连州 普宁 罗定")

        * --- 广西壮族自治区 ---
        cncity_match `v', touse(`touse') prov("广西壮族自治区") type("地级市") ///
            list("南宁 柳州 桂林 梧州 北海 防城港 钦州 贵港 玉林 百色 贺州 河池 来宾 崇左")
        cncity_match `v', touse(`touse') prov("广西壮族自治区") type("县级市") ///
            list("横州 荔浦 岑溪 东兴 桂平 北流 靖西 平果 合山 凭祥")

        * --- 海南省 ---
        cncity_match `v', touse(`touse') prov("海南省") type("地级市") ///
            list("海口 三亚 三沙 儋州")
        cncity_match `v', touse(`touse') prov("海南省") type("县级市") ///
            list("五指山 琼海 文昌 万宁 东方")

        * --- 四川省 ---
        cncity_match `v', touse(`touse') prov("四川省") type("地级市") ///
            list("成都 自贡 攀枝花 泸州 德阳 绵阳 广元 遂宁 内江 乐山 南充 眉山 宜宾 广安 达州 雅安 巴中 资阳")
        cncity_match `v', touse(`touse') prov("四川省") type("县级市") ///
            list("都江堰 彭州 邛崃 崇州 简阳 广汉 什邡 绵竹 江油 射洪 隆昌 峨眉山 阆中 华蓥 万源 马尔康 康定 西昌 会理")

        * --- 贵州省 ---
        cncity_match `v', touse(`touse') prov("贵州省") type("地级市") ///
            list("贵阳 六盘水 遵义 安顺 毕节 铜仁")
        cncity_match `v', touse(`touse') prov("贵州省") type("县级市") ///
            list("清镇 盘州 赤水 仁怀 黔西 兴义 兴仁 凯里 都匀 福泉")

        * --- 云南省 ---
        cncity_match `v', touse(`touse') prov("云南省") type("地级市") ///
            list("昆明 曲靖 玉溪 保山 昭通 丽江 普洱 临沧")
        * 芒市使用"芒=芒市"两字匹配，避免单字"芒"误匹配
        cncity_match `v', touse(`touse') prov("云南省") type("县级市") ///
            list("安宁 宣威 澄江 腾冲 水富 楚雄 禄丰 个旧 开远 蒙自 弥勒 文山 景洪 大理 瑞丽 芒=芒市 泸水 香格里拉")

        * --- 西藏自治区 ---
        cncity_match `v', touse(`touse') prov("西藏自治区") type("地级市") ///
            list("拉萨 日喀则 昌都 林芝 山南 那曲")
        cncity_match `v', touse(`touse') prov("西藏自治区") type("县级市") ///
            list("米林 错那")

        * --- 陕西省 ---
        cncity_match `v', touse(`touse') prov("陕西省") type("地级市") ///
            list("西安 铜川 宝鸡 咸阳 渭南 延安 汉中 榆林 安康 商洛")
        cncity_match `v', touse(`touse') prov("陕西省") type("县级市") ///
            list("兴平 彬州 韩城 华阴 子长 神木 旬阳")

        * --- 甘肃省 ---
        cncity_match `v', touse(`touse') prov("甘肃省") type("地级市") ///
            list("兰州 嘉峪关 金昌 白银 天水 武威 张掖 平凉 酒泉 庆阳 定西 陇南")
        cncity_match `v', touse(`touse') prov("甘肃省") type("县级市") ///
            list("华亭 玉门 敦煌 临夏 合作")

        * --- 青海省 ---
        cncity_match `v', touse(`touse') prov("青海省") type("地级市") ///
            list("西宁 海东")
        cncity_match `v', touse(`touse') prov("青海省") type("县级市") ///
            list("同仁 玉树 格尔木 德令哈 茫崖")

        * --- 宁夏回族自治区 ---
        cncity_match `v', touse(`touse') prov("宁夏回族自治区") type("地级市") ///
            list("银川 石嘴山 吴忠 固原 中卫")
        cncity_match `v', touse(`touse') prov("宁夏回族自治区") type("县级市") ///
            list("灵武 青铜峡")

        * --- 新疆维吾尔自治区 ---
        cncity_match `v', touse(`touse') prov("新疆维吾尔自治区") type("地级市") ///
            list("乌鲁木齐 克拉玛依 吐鲁番 哈密")
        cncity_match `v', touse(`touse') prov("新疆维吾尔自治区") type("县级市") ///
            list("昌吉 阜康 博乐 阿拉山口 库尔勒 阿克苏 库车 阿图什 喀什 和田 伊宁 奎屯 霍尔果斯 塔城 乌苏 沙湾 阿勒泰 石河子 阿拉尔 图木舒克 五家渠 北屯 铁门关 双河 可克达拉 昆玉 胡杨河 新星 白杨")

        * --- 港澳台 ---
        replace city_stname = "香港特别行政区" if ustrregexm(`v', "香港") & city_stname == "" & `touse'
        replace city_type = "特别行政区" if city_stname == "香港特别行政区" & `touse'
        replace city_prov = "香港特别行政区" if city_stname == "香港特别行政区" & `touse'

        replace city_stname = "澳门特别行政区" if ustrregexm(`v', "澳门") & city_stname == "" & `touse'
        replace city_type = "特别行政区" if city_stname == "澳门特别行政区" & `touse'
        replace city_prov = "澳门特别行政区" if city_stname == "澳门特别行政区" & `touse'

        cncity_match `v', touse(`touse') prov("台湾省") type("行政院直辖市") ///
            list("台北 新北 桃园 台中 台南 高雄")
        cncity_match `v', touse(`touse') prov("台湾省") type("县辖市") ///
            list("基隆 新竹 嘉义")

        * --- 地区、州、盟 ---
        replace city_special = "大兴安岭地区" if ustrregexm(`v', "漠河|大兴安岭") & `touse'
        replace city_special = "阿里地区" if ustrregexm(`v', "阿里") & `touse'
        replace city_special = "塔城地区" if ustrregexm(`v', "塔城|乌苏|沙湾") & `touse'
        replace city_special = "阿勒泰地区" if ustrregexm(`v', "阿勒泰") & `touse'
        replace city_special = "喀什地区" if ustrregexm(`v', "喀什") & `touse'
        replace city_special = "和田地区" if ustrregexm(`v', "和田") & `touse'
        replace city_special = "阿克苏地区" if ustrregexm(`v', "阿克苏|库车") & `touse'

        replace city_special = "延边朝鲜族自治州" if ustrregexm(`v', "延吉|图们|敦化|珲春|龙井|和龙|延边") & `touse'
        replace city_special = "恩施土家族苗族自治州" if ustrregexm(`v', "恩施|利川") & `touse'
        replace city_special = "湘西土家族苗族自治州" if ustrregexm(`v', "吉首|湘西") & `touse'
        replace city_special = "阿坝藏族羌族自治州" if ustrregexm(`v', "马尔康|阿坝") & `touse'
        replace city_special = "甘孜藏族自治州" if ustrregexm(`v', "康定|甘孜") & `touse'
        replace city_special = "凉山彝族自治州" if ustrregexm(`v', "西昌|凉山") & `touse'
        replace city_special = "黔东南苗族侗族自治州" if ustrregexm(`v', "凯里|黔东南") & `touse'
        replace city_special = "黔南布依族苗族自治州" if ustrregexm(`v', "都匀|福泉|黔南") & `touse'
        replace city_special = "黔西南布依族苗族自治州" if ustrregexm(`v', "兴义|兴仁|黔西南") & `touse'
        replace city_special = "楚雄彝族自治州" if ustrregexm(`v', "楚雄|禄丰") & `touse'
        replace city_special = "大理白族自治州" if ustrregexm(`v', "大理") & `touse'
        replace city_special = "德宏傣族景颇族自治州" if ustrregexm(`v', "瑞丽|芒市|德宏") & `touse'
        replace city_special = "迪庆藏族自治州" if ustrregexm(`v', "香格里拉|迪庆") & `touse'
        replace city_special = "红河哈尼族彝族自治州" if ustrregexm(`v', "个旧|开远|蒙自|弥勒|红河") & `touse'
        replace city_special = "怒江傈僳族自治州" if ustrregexm(`v', "泸水|怒江") & `touse'
        replace city_special = "文山壮族苗族自治州" if ustrregexm(`v', "文山") & `touse'
        replace city_special = "西双版纳傣族自治州" if ustrregexm(`v', "景洪|西双版纳") & `touse'
        replace city_special = "甘南藏族自治州" if ustrregexm(`v', "合作|甘南") & `touse'
        replace city_special = "临夏回族自治州" if ustrregexm(`v', "临夏") & `touse'
        replace city_special = "海西蒙古族藏族自治州" if ustrregexm(`v', "德令哈|格尔木|茫崖|海西蒙古") & `touse'
        replace city_special = "海南藏族自治州" if ustrregexm(`v', "海南藏族") & `touse'
        replace city_special = "海北藏族自治州" if ustrregexm(`v', "海北藏族") & `touse'
        replace city_special = "黄南藏族自治州" if ustrregexm(`v', "黄南藏族") & `touse'
        replace city_special = "果洛藏族自治州" if ustrregexm(`v', "果洛藏族") & `touse'
        replace city_special = "玉树藏族自治州" if ustrregexm(`v', "玉树") & `touse'
        replace city_special = "巴音郭楞蒙古自治州" if ustrregexm(`v', "库尔勒|巴音郭楞") & `touse'
        replace city_special = "博尔塔拉蒙古自治州" if ustrregexm(`v', "博乐|阿拉山口|博尔塔拉") & `touse'
        replace city_special = "昌吉回族自治州" if ustrregexm(`v', "昌吉|阜康") & `touse'
        replace city_special = "克孜勒苏柯尔克孜自治州" if ustrregexm(`v', "阿图什|克孜勒苏柯尔克孜") & `touse'
        replace city_special = "伊犁哈萨克自治州" if ustrregexm(`v', "伊宁|奎屯|霍尔果斯|伊犁") & `touse'

        replace city_special = "兴安盟" if (ustrregexm(`v', "乌兰浩特|阿尔山|兴安盟") | `v' == "兴安") & `touse'
        replace city_special = "锡林郭勒盟" if ustrregexm(`v', "锡林浩特|二连浩特|锡林") & `touse'
        replace city_special = "阿拉善盟" if ustrregexm(`v', "阿拉善") & `touse'

        // 去除错误将地区、州、盟命名为城市的观测
        replace city_stname  = "" if ustrregexm(`v', "地区|自治州|盟") & `touse'
        replace city_type    = "" if ustrregexm(`v', "地区|自治州|盟") & `touse'

        // 匹配省份名称
        replace city_prov = "黑龙江省" if city_special == "大兴安岭地区" & mi(city_prov)
        replace city_prov = "西藏自治区" if city_special == "阿里地区" & mi(city_prov)
        replace city_prov = "新疆维吾尔自治区" if city_special == "塔城地区" & mi(city_prov)
        replace city_prov = "新疆维吾尔自治区" if city_special == "阿勒泰地区" & mi(city_prov)
        replace city_prov = "新疆维吾尔自治区" if city_special == "喀什地区" & mi(city_prov)
        replace city_prov = "新疆维吾尔自治区" if city_special == "和田地区" & mi(city_prov)
        replace city_prov = "新疆维吾尔自治区" if city_special == "阿克苏地区" & mi(city_prov)
        replace city_prov = "新疆维吾尔自治区" if city_special == "巴音郭楞蒙古自治州" & mi(city_prov)
        replace city_prov = "新疆维吾尔自治区" if city_special == "博尔塔拉蒙古自治州" & mi(city_prov)
        replace city_prov = "新疆维吾尔自治区" if city_special == "昌吉回族自治州" & mi(city_prov)
        replace city_prov = "新疆维吾尔自治区" if city_special == "克孜勒苏柯尔克孜自治州" & mi(city_prov)
        replace city_prov = "新疆维吾尔自治区" if city_special == "伊犁哈萨克自治州" & mi(city_prov)
        replace city_prov = "吉林省" if city_special == "延边朝鲜族自治州" & mi(city_prov)
        replace city_prov = "湖北省" if city_special == "恩施土家族苗族自治州" & mi(city_prov)
        replace city_prov = "湖南省" if city_special == "湘西土家族苗族自治州" & mi(city_prov)
        replace city_prov = "四川省" if city_special == "阿坝藏族羌族自治州" & mi(city_prov)
        replace city_prov = "四川省" if city_special == "甘孜藏族自治州" & mi(city_prov)
        replace city_prov = "四川省" if city_special == "凉山彝族自治州" & mi(city_prov)
        replace city_prov = "贵州省" if city_special == "黔东南苗族侗族自治州" & mi(city_prov)
        replace city_prov = "贵州省" if city_special == "黔南布依族苗族自治州" & mi(city_prov)
        replace city_prov = "贵州省" if city_special == "黔西南布依族苗族自治州" & mi(city_prov)
        replace city_prov = "云南省" if city_special == "楚雄彝族自治州" & mi(city_prov)
        replace city_prov = "云南省" if city_special == "大理白族自治州" & mi(city_prov)
        replace city_prov = "云南省" if city_special == "德宏傣族景颇族自治州" & mi(city_prov)
        replace city_prov = "云南省" if city_special == "迪庆藏族自治州" & mi(city_prov)
        replace city_prov = "云南省" if city_special == "红河哈尼族彝族自治州" & mi(city_prov)
        replace city_prov = "云南省" if city_special == "怒江傈僳族自治州" & mi(city_prov)
        replace city_prov = "云南省" if city_special == "文山壮族苗族自治州" & mi(city_prov)
        replace city_prov = "云南省" if city_special == "西双版纳傣族自治州" & mi(city_prov)
        replace city_prov = "甘肃省" if city_special == "甘南藏族自治州" & mi(city_prov)
        replace city_prov = "甘肃省" if city_special == "临夏回族自治州" & mi(city_prov)
        replace city_prov = "青海省" if city_special == "海西蒙古族藏族自治州" & mi(city_prov)
        replace city_prov = "青海省" if city_special == "海南藏族自治州" & mi(city_prov)
        replace city_prov = "青海省" if city_special == "海北藏族自治州" & mi(city_prov)
        replace city_prov = "青海省" if city_special == "黄南藏族自治州" & mi(city_prov)
        replace city_prov = "青海省" if city_special == "果洛藏族自治州" & mi(city_prov)
        replace city_prov = "青海省" if city_special == "玉树藏族自治州" & mi(city_prov)
        replace city_prov = "内蒙古自治区" if city_special == "兴安盟" & mi(city_prov)
        replace city_prov = "内蒙古自治区" if city_special == "锡林郭勒盟" & mi(city_prov)
        replace city_prov = "内蒙古自治区" if city_special == "阿拉善盟" & mi(city_prov)

        // 特殊地区城市名单
        replace special_ctlist = "漠河市" if city_special == "大兴安岭地区"
        replace special_ctlist = "塔城市,乌苏市,沙湾市" if city_special == "塔城地区"
        replace special_ctlist = "阿勒泰市" if city_special == "阿勒泰地区"
        replace special_ctlist = "喀什市" if city_special == "喀什地区"
        replace special_ctlist = "和田市" if city_special == "和田地区"
        replace special_ctlist = "阿克苏市,库车市" if city_special == "阿克苏地区"
        replace special_ctlist = "库尔勒市" if city_special == "巴音郭楞蒙古自治州"
        replace special_ctlist = "博乐市,阿拉山口市" if city_special == "博尔塔拉蒙古自治州"
        replace special_ctlist = "昌吉市,阜康市" if city_special == "昌吉回族自治州"
        replace special_ctlist = "阿图什市" if city_special == "克孜勒苏柯尔克孜自治州"
        replace special_ctlist = "伊宁市,奎屯市,霍尔果斯市" if city_special == "伊犁哈萨克自治州"
        replace special_ctlist = "延吉市,图们市,敦化市,珲春市,龙井市,和龙市" if city_special == "延边朝鲜族自治州"
        replace special_ctlist = "恩施市,利川市" if city_special == "恩施土家族苗族自治州"
        replace special_ctlist = "吉首市" if city_special == "湘西土家族苗族自治州"
        replace special_ctlist = "马尔康市" if city_special == "阿坝藏族羌族自治州"
        replace special_ctlist = "康定市" if city_special == "甘孜藏族自治州"
        replace special_ctlist = "西昌市" if city_special == "凉山彝族自治州"
        replace special_ctlist = "凯里市" if city_special == "黔东南苗族侗族自治州"
        replace special_ctlist = "都匀市,福泉市" if city_special == "黔南布依族苗族自治州"
        replace special_ctlist = "兴义市,兴仁市" if city_special == "黔西南布依族苗族自治州"
        replace special_ctlist = "楚雄市,禄丰市" if city_special == "楚雄彝族自治州"
        replace special_ctlist = "大理市" if city_special == "大理白族自治州"
        replace special_ctlist = "瑞丽市,芒市" if city_special == "德宏傣族景颇族自治州"
        replace special_ctlist = "香格里拉市" if city_special == "迪庆藏族自治州"
        replace special_ctlist = "个旧市,开远市,蒙自市,弥勒市" if city_special == "红河哈尼族彝族自治州"
        replace special_ctlist = "泸水市" if city_special == "怒江傈僳族自治州"
        replace special_ctlist = "文山市" if city_special == "文山壮族苗族自治州"
        replace special_ctlist = "景洪市" if city_special == "西双版纳傣族自治州"
        replace special_ctlist = "合作市" if city_special == "甘南藏族自治州"
        replace special_ctlist = "临夏市" if city_special == "临夏回族自治州"
        replace special_ctlist = "德令哈市,格尔木市,茫崖市" if city_special == "海西蒙古族藏族自治州"
        replace special_ctlist = "玉树市" if city_special == "玉树藏族自治州"
        replace special_ctlist = "乌兰浩特市,阿尔山市" if city_special == "兴安盟"
        replace special_ctlist = "锡林浩特市,二连浩特市" if city_special == "锡林郭勒盟"
    }
    display as res "标准化完成。"

    * ==============================
    * 3. 匹配统计
    * ==============================
    quietly {
        count if `touse'
        local n_tot = r(N)
        count if city_stname != "" & `touse'
        local n_city = r(N)
        count if city_stname == "" & city_special != "" & `touse'
        local n_spec = r(N)
        count if city_stname == "" & city_special == "" & `touse'
        local n_unmat = r(N)
    }
    display as txt "{hline 45}"
    display as txt "处理观测数:" _col(38) as res %9.0fc `n_tot'
    display as txt "  匹配到城市 (city_stname):" _col(38) as res %9.0fc `n_city'
    display as txt "  仅匹配到地区/州/盟 (city_special):" _col(38) as res %9.0fc `n_spec'
    display as txt "  未匹配:" _col(38) as res %9.0fc `n_unmat'
    display as txt "{hline 45}"
    if `n_unmat' > 0 {
        display as txt `"提示: 可用 {stata list `v' if city_stname == "" & city_special == "":list `v' if city_stname == "" & city_special == ""} 查看未匹配观测"'
    }
end

* 子程序：对一组城市名执行"包含即匹配、先到先得"的标准化
* list 中的元素默认"名称即匹配串"；形如 名称=匹配串 时二者分离（如 芒=芒市）
program define cncity_match
    version 14
    syntax varname(string), TOuse(varname) PROV(string) TYPE(string) LIST(string)
    foreach c of local list {
        local name "`c'"
        local pat  "`c'"
        local eq = strpos("`c'", "=")
        if `eq' > 0 {
            local name = substr("`c'", 1, `eq' - 1)
            local pat  = substr("`c'", `eq' + 1, .)
        }
        replace city_stname = "`name'市" if ustrregexm(`varlist', "`pat'") & city_stname == "" & `touse'
        replace city_type   = "`type'"  if city_stname == "`name'市" & `touse'
        replace city_prov   = "`prov'"  if city_stname == "`name'市" & `touse'
    }
end
