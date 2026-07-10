*! version 0.3.0 11Jul2026 新增 city_code 行政区划代码；city_special/special_ctlist 默认隐藏，detail 选项输出
*! version 0.2.0 10Jul2026 重构：省份匹配抽成子程序；改用 ustrregexm；支持 if/in 与 replace 选项；修复重复运行报错、鞍山排除范围过大；芒市改为两字匹配；新增匹配统计
*! version 0.1.3 24Jan2026 Bug fixed Issue #1 @sammybaby233
*! version 0.1.2 18Jan2026 修复了一些特殊地区的匹配 bug
*! version 0.1.1 23Nov2025 公众号：凯恩斯学计量
capture program drop cncity
capture program drop cncity_match
program define cncity
    version 14
    syntax varname(string) [if] [in] [, replace Detail]

    local v "`varlist'"
    marksample touse, strok

    * 检查生成变量是否已存在：默认报错，指定 replace 选项才覆盖
    local newvars "city_stname city_type city_prov city_code city_special special_ctlist"
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
        cncity_match `v', touse(`touse') prov("北京市") type("直辖市") list("北京=110000")
        cncity_match `v', touse(`touse') prov("天津市") type("直辖市") list("天津=120000")
        cncity_match `v', touse(`touse') prov("上海市") type("直辖市") list("上海=310000")
        cncity_match `v', touse(`touse') prov("重庆市") type("直辖市") list("重庆=500000")

        * ==============================
        * 2. 省份/自治区 循环处理
        * ==============================
        * --- 河北省 ---
        cncity_match `v', touse(`touse') prov("河北省") type("地级市") ///
            list("石家庄=130100 唐山=130200 秦皇岛=130300 邯郸=130400 邢台=130500 保定=130600 张家口=130700 承德=130800 沧州=130900 廊坊=131000 衡水=131100")
        cncity_match `v', touse(`touse') prov("河北省") type("县级市") ///
            list("辛集=130181 晋州=130183 新乐=130184 遵化=130281 迁安=130283 滦州=130284 武安=130481 南宫=130581 沙河=130582 涿州=130681 定州=130682 安国=130683 高碑店=130684 平泉=130881 泊头=130981 任丘=130982 黄骅=130983 河间=130984 霸州=131081 三河=131082 深州=131182")

        * --- 山西省 ---
        cncity_match `v', touse(`touse') prov("山西省") type("地级市") ///
            list("太原=140100 大同=140200 阳泉=140300 长治=140400 晋城=140500 朔州=140600 晋中=140700 运城=140800 忻州=140900 临汾=141000 吕梁=141100")
        cncity_match `v', touse(`touse') prov("山西省") type("县级市") ///
            list("古交=140181 高平=140581 怀仁=140681 介休=140781 永济=140881 河津=140882 原平=140981 侯马=141081 霍州=141082 孝义=141181 汾阳=141182")

        * --- 内蒙古自治区 ---
        cncity_match `v', touse(`touse') prov("内蒙古自治区") type("地级市") ///
            list("呼和浩特=150100 包头=150200 乌海=150300 赤峰=150400 通辽=150500 鄂尔多斯=150600 呼伦贝尔=150700 巴彦淖尔=150800 乌兰察布=150900")
        cncity_match `v', touse(`touse') prov("内蒙古自治区") type("县级市") ///
            list("霍林郭勒=150581 满洲里=150781 牙克石=150782 扎兰屯=150783 额尔古纳=150784 根河=150785 丰镇=150981 乌兰浩特=152201 阿尔山=152202 二连浩特=152501 锡林浩特=152502")

        * --- 辽宁省 ---
        * issue #1: 鞍山单独处理，排除马鞍山，且排除条件只作用于鞍山本身
        replace city_stname = "鞍山市" if ustrregexm(`v', "鞍山") & !ustrregexm(`v', "马鞍山") & city_stname == "" & `touse'
        replace city_type   = "地级市" if city_stname == "鞍山市" & `touse'
        replace city_prov   = "辽宁省" if city_stname == "鞍山市" & `touse'
        replace city_code   = "210300" if city_stname == "鞍山市" & `touse'
        cncity_match `v', touse(`touse') prov("辽宁省") type("地级市") ///
            list("沈阳=210100 大连=210200 抚顺=210400 本溪=210500 丹东=210600 锦州=210700 营口=210800 阜新=210900 辽阳=211000 盘锦=211100 铁岭=211200 朝阳=211300 葫芦岛=211400")
        cncity_match `v', touse(`touse') prov("辽宁省") type("县级市") ///
            list("新民=210181 瓦房店=210281 庄河=210283 海城=210381 东港=210681 凤城=210682 凌海=210781 北镇=210782 盖州=210881 大石桥=210882 灯塔=211081 调兵山=211281 开原=211282 北票=211381 凌源=211382 兴城=211481")

        * --- 吉林省 ---
        cncity_match `v', touse(`touse') prov("吉林省") type("地级市") ///
            list("长春=220100 吉林=220200 四平=220300 辽源=220400 通化=220500 白山=220600 松原=220700 白城=220800")
        cncity_match `v', touse(`touse') prov("吉林省") type("县级市") ///
            list("榆树=220182 德惠=220183 公主岭=220184 蛟河=220281 桦甸=220282 舒兰=220283 磐石=220284 双辽=220382 梅河口=220581 集安=220582 临江=220681 扶余=220781 洮南=220881 大安=220882 延吉=222401 图们=222402 敦化=222403 珲春=222404 龙井=222405 和龙=222406")

        * --- 黑龙江省 ---
        cncity_match `v', touse(`touse') prov("黑龙江省") type("地级市") ///
            list("哈尔滨=230100 齐齐哈尔=230200 鸡西=230300 鹤岗=230400 双鸭山=230500 大庆=230600 伊春=230700 佳木斯=230800 七台河=230900 牡丹江=231000 黑河=231100 绥化=231200")
        cncity_match `v', touse(`touse') prov("黑龙江省") type("县级市") ///
            list("尚志=230183 五常=230184 讷河=230281 虎林=230381 密山=230382 铁力=230781 同江=230881 富锦=230882 抚远=230883 绥芬河=231081 海林=231083 宁安=231084 穆棱=231085 东宁=231086 北安=231181 五大连池=231182 嫩江=231183 安达=231281 肇东=231282 海伦=231283 漠河=232701")

        * --- 江苏省 ---
        cncity_match `v', touse(`touse') prov("江苏省") type("地级市") ///
            list("南京=320100 无锡=320200 徐州=320300 常州=320400 苏州=320500 南通=320600 连云港=320700 淮安=320800 盐城=320900 扬州=321000 镇江=321100 泰州=321200 宿迁=321300")
        cncity_match `v', touse(`touse') prov("江苏省") type("县级市") ///
            list("江阴=320281 宜兴=320282 新沂=320381 邳州=320382 溧阳=320481 常熟=320581 张家港=320582 昆山=320583 太仓=320585 启东=320681 如皋=320682 海安=320685 东台=320981 仪征=321081 高邮=321084 丹阳=321181 扬中=321182 句容=321183 兴化=321281 靖江=321282 泰兴=321283")

        * --- 浙江省 ---
        cncity_match `v', touse(`touse') prov("浙江省") type("地级市") ///
            list("杭州=330100 宁波=330200 温州=330300 嘉兴=330400 湖州=330500 绍兴=330600 金华=330700 衢州=330800 舟山=330900 台州=331000 丽水=331100")
        cncity_match `v', touse(`touse') prov("浙江省") type("县级市") ///
            list("建德=330182 余姚=330281 慈溪=330282 瑞安=330381 乐清=330382 龙港=330383 海宁=330481 平湖=330482 桐乡=330483 诸暨=330681 嵊州=330683 兰溪=330781 义乌=330782 东阳=330783 永康=330784 江山=330881 温岭=331081 临海=331082 玉环=331083 龙泉=331181")

        * --- 安徽省 ---
        cncity_match `v', touse(`touse') prov("安徽省") type("地级市") ///
            list("合肥=340100 芜湖=340200 蚌埠=340300 淮南=340400 马鞍山=340500 淮北=340600 铜陵=340700 安庆=340800 黄山=341000 滁州=341100 阜阳=341200 宿州=341300 六安=341500 亳州=341600 池州=341700 宣城=341800")
        cncity_match `v', touse(`touse') prov("安徽省") type("县级市") ///
            list("巢湖=340181 无为=340281 桐城=340881 潜山=340882 天长=341181 明光=341182 界首=341282 宁国=341881 广德=341882")

        * --- 福建省 ---
        cncity_match `v', touse(`touse') prov("福建省") type("地级市") ///
            list("福州=350100 厦门=350200 莆田=350300 三明=350400 泉州=350500 漳州=350600 南平=350700 龙岩=350800 宁德=350900")
        cncity_match `v', touse(`touse') prov("福建省") type("县级市") ///
            list("福清=350181 永安=350481 石狮=350581 晋江=350582 南安=350583 邵武=350781 武夷山=350782 建瓯=350783 漳平=350881 福安=350981 福鼎=350982")

        * --- 江西省 ---
        cncity_match `v', touse(`touse') prov("江西省") type("地级市") ///
            list("南昌=360100 景德镇=360200 萍乡=360300 九江=360400 新余=360500 鹰潭=360600 赣州=360700 吉安=360800 宜春=360900 抚州=361000 上饶=361100")
        cncity_match `v', touse(`touse') prov("江西省") type("县级市") ///
            list("乐平=360281 瑞昌=360481 共青城=360482 庐山=360483 贵溪=360681 瑞金=360781 龙南=360783 井冈山=360881 丰城=360981 樟树=360982 高安=360983 德兴=361181")

        * --- 山东省 ---
        cncity_match `v', touse(`touse') prov("山东省") type("地级市") ///
            list("济南=370100 青岛=370200 淄博=370300 枣庄=370400 东营=370500 烟台=370600 潍坊=370700 济宁=370800 泰安=370900 威海=371000 日照=371100 临沂=371300 德州=371400 聊城=371500 滨州=371600 菏泽=371700")
        cncity_match `v', touse(`touse') prov("山东省") type("县级市") ///
            list("胶州=370281 平度=370283 莱西=370285 滕州=370481 龙口=370681 莱阳=370682 莱州=370683 招远=370685 栖霞=370686 海阳=370687 青州=370781 诸城=370782 寿光=370783 安丘=370784 高密=370785 昌邑=370786 曲阜=370881 邹城=370883 新泰=370982 肥城=370983 荣成=371082 乳山=371083 乐陵=371481 禹城=371482 临清=371581 邹平=371681")

        * --- 河南省 ---
        cncity_match `v', touse(`touse') prov("河南省") type("地级市") ///
            list("郑州=410100 开封=410200 洛阳=410300 平顶山=410400 安阳=410500 鹤壁=410600 新乡=410700 焦作=410800 濮阳=410900 许昌=411000 漯河=411100 三门峡=411200 南阳=411300 商丘=411400 信阳=411500 周口=411600 驻马店=411700")
        cncity_match `v', touse(`touse') prov("河南省") type("县级市") ///
            list("巩义=410181 荥阳=410182 新密=410183 新郑=410184 登封=410185 舞钢=410481 汝州=410482 林州=410581 卫辉=410781 辉县=410782 长垣=410783 沁阳=410882 孟州=410883 禹州=411081 长葛=411082 义马=411281 灵宝=411282 邓州=411381 永城=411481 项城=411681 济源=419001")

        * --- 湖北省 ---
        cncity_match `v', touse(`touse') prov("湖北省") type("地级市") ///
            list("武汉=420100 黄石=420200 十堰=420300 宜昌=420500 襄阳=420600 鄂州=420700 荆门=420800 孝感=420900 荆州=421000 黄冈=421100 咸宁=421200 随州=421300")
        cncity_match `v', touse(`touse') prov("湖北省") type("县级市") ///
            list("大冶=420281 丹江口=420381 宜都=420581 当阳=420582 枝江=420583 老河口=420682 枣阳=420683 宜城=420684 钟祥=420881 京山=420882 应城=420981 安陆=420982 汉川=420984 石首=421081 洪湖=421083 松滋=421087 监利=421088 麻城=421181 武穴=421182 赤壁=421281 广水=421381 恩施=422801 利川=422802 仙桃=429004 潜江=429005 天门=429006")

        * --- 湖南省 ---
        cncity_match `v', touse(`touse') prov("湖南省") type("地级市") ///
            list("长沙=430100 株洲=430200 湘潭=430300 衡阳=430400 邵阳=430500 岳阳=430600 常德=430700 张家界=430800 益阳=430900 郴州=431000 永州=431100 怀化=431200 娄底=431300")
        cncity_match `v', touse(`touse') prov("湖南省") type("县级市") ///
            list("浏阳=430181 宁乡=430182 醴陵=430281 湘乡=430381 韶山=430382 耒阳=430481 常宁=430482 武冈=430581 邵东=430582 汨罗=430681 临湘=430682 津市=430781 沅江=430981 资兴=431081 祁阳=431181 洪江=431281 冷水江=431381 涟源=431382 吉首=433101")

        * --- 广东省 ---
        cncity_match `v', touse(`touse') prov("广东省") type("地级市") ///
            list("广州=440100 韶关=440200 深圳=440300 珠海=440400 汕头=440500 佛山=440600 江门=440700 湛江=440800 茂名=440900 肇庆=441200 惠州=441300 梅州=441400 汕尾=441500 河源=441600 阳江=441700 清远=441800 东莞=441900 中山=442000 潮州=445100 揭阳=445200 云浮=445300")
        cncity_match `v', touse(`touse') prov("广东省") type("县级市") ///
            list("乐昌=440281 南雄=440282 台山=440781 开平=440783 鹤山=440784 恩平=440785 廉江=440881 雷州=440882 吴川=440883 高州=440981 化州=440982 信宜=440983 四会=441284 兴宁=441481 陆丰=441581 阳春=441781 英德=441881 连州=441882 普宁=445281 罗定=445381")

        * --- 广西壮族自治区 ---
        cncity_match `v', touse(`touse') prov("广西壮族自治区") type("地级市") ///
            list("南宁=450100 柳州=450200 桂林=450300 梧州=450400 北海=450500 防城港=450600 钦州=450700 贵港=450800 玉林=450900 百色=451000 贺州=451100 河池=451200 来宾=451300 崇左=451400")
        cncity_match `v', touse(`touse') prov("广西壮族自治区") type("县级市") ///
            list("横州=450181 荔浦=450381 岑溪=450481 东兴=450681 桂平=450881 北流=450981 靖西=451081 平果=451082 合山=451381 凭祥=451481")

        * --- 海南省 ---
        cncity_match `v', touse(`touse') prov("海南省") type("地级市") ///
            list("海口=460100 三亚=460200 三沙=460300 儋州=460400")
        cncity_match `v', touse(`touse') prov("海南省") type("县级市") ///
            list("五指山=469001 琼海=469002 文昌=469005 万宁=469006 东方=469007")

        * --- 四川省 ---
        cncity_match `v', touse(`touse') prov("四川省") type("地级市") ///
            list("成都=510100 自贡=510300 攀枝花=510400 泸州=510500 德阳=510600 绵阳=510700 广元=510800 遂宁=510900 内江=511000 乐山=511100 南充=511300 眉山=511400 宜宾=511500 广安=511600 达州=511700 雅安=511800 巴中=511900 资阳=512000")
        cncity_match `v', touse(`touse') prov("四川省") type("县级市") ///
            list("都江堰=510181 彭州=510182 邛崃=510183 崇州=510184 简阳=510185 广汉=510681 什邡=510682 绵竹=510683 江油=510781 射洪=510981 隆昌=511083 峨眉山=511181 阆中=511381 华蓥=511681 万源=511781 马尔康=513201 康定=513301 西昌=513401 会理=513402")

        * --- 贵州省 ---
        cncity_match `v', touse(`touse') prov("贵州省") type("地级市") ///
            list("贵阳=520100 六盘水=520200 遵义=520300 安顺=520400 毕节=520500 铜仁=520600")
        cncity_match `v', touse(`touse') prov("贵州省") type("县级市") ///
            list("清镇=520181 盘州=520281 赤水=520381 仁怀=520382 黔西=520581 兴义=522301 兴仁=522302 凯里=522601 都匀=522701 福泉=522702")

        * --- 云南省 ---
        cncity_match `v', touse(`touse') prov("云南省") type("地级市") ///
            list("昆明=530100 曲靖=530300 玉溪=530400 保山=530500 昭通=530600 丽江=530700 普洱=530800 临沧=530900")
        * 芒市单独处理：用"芒市"两字匹配，避免单字"芒"误匹配
        replace city_stname = "芒市" if ustrregexm(`v', "芒市") & city_stname == "" & `touse'
        replace city_type   = "县级市" if city_stname == "芒市" & `touse'
        replace city_prov   = "云南省" if city_stname == "芒市" & `touse'
        replace city_code   = "533103" if city_stname == "芒市" & `touse'
        cncity_match `v', touse(`touse') prov("云南省") type("县级市") ///
            list("安宁=530181 宣威=530381 澄江=530481 腾冲=530581 水富=530681 楚雄=532301 禄丰=532302 个旧=532501 开远=532502 蒙自=532503 弥勒=532504 文山=532601 景洪=532801 大理=532901 瑞丽=533102 泸水=533301 香格里拉=533401")

        * --- 西藏自治区 ---
        cncity_match `v', touse(`touse') prov("西藏自治区") type("地级市") ///
            list("拉萨=540100 日喀则=540200 昌都=540300 林芝=540400 山南=540500 那曲=540600")
        cncity_match `v', touse(`touse') prov("西藏自治区") type("县级市") ///
            list("米林=540481 错那=540581")

        * --- 陕西省 ---
        cncity_match `v', touse(`touse') prov("陕西省") type("地级市") ///
            list("西安=610100 铜川=610200 宝鸡=610300 咸阳=610400 渭南=610500 延安=610600 汉中=610700 榆林=610800 安康=610900 商洛=611000")
        cncity_match `v', touse(`touse') prov("陕西省") type("县级市") ///
            list("兴平=610481 彬州=610482 韩城=610581 华阴=610582 子长=610681 神木=610881 旬阳=610981")

        * --- 甘肃省 ---
        cncity_match `v', touse(`touse') prov("甘肃省") type("地级市") ///
            list("兰州=620100 嘉峪关=620200 金昌=620300 白银=620400 天水=620500 武威=620600 张掖=620700 平凉=620800 酒泉=620900 庆阳=621000 定西=621100 陇南=621200")
        cncity_match `v', touse(`touse') prov("甘肃省") type("县级市") ///
            list("华亭=620881 玉门=620981 敦煌=620982 临夏=622901 合作=623001")

        * --- 青海省 ---
        cncity_match `v', touse(`touse') prov("青海省") type("地级市") ///
            list("西宁=630100 海东=630200")
        cncity_match `v', touse(`touse') prov("青海省") type("县级市") ///
            list("同仁=632301 玉树=632701 格尔木=632801 德令哈=632802 茫崖=632803")

        * --- 宁夏回族自治区 ---
        cncity_match `v', touse(`touse') prov("宁夏回族自治区") type("地级市") ///
            list("银川=640100 石嘴山=640200 吴忠=640300 固原=640400 中卫=640500")
        cncity_match `v', touse(`touse') prov("宁夏回族自治区") type("县级市") ///
            list("灵武=640181 青铜峡=640381")

        * --- 新疆维吾尔自治区 ---
        cncity_match `v', touse(`touse') prov("新疆维吾尔自治区") type("地级市") ///
            list("乌鲁木齐=650100 克拉玛依=650200 吐鲁番=650400 哈密=650500")
        cncity_match `v', touse(`touse') prov("新疆维吾尔自治区") type("县级市") ///
            list("昌吉=652301 阜康=652302 博乐=652701 阿拉山口=652702 库尔勒=652801 阿克苏=652901 库车=652902 阿图什=653001 喀什=653101 和田=653201 伊宁=654002 奎屯=654003 霍尔果斯=654004 塔城=654201 乌苏=654202 沙湾=654203 阿勒泰=654301 石河子=659001 阿拉尔=659002 图木舒克=659003 五家渠=659004 北屯=659005 铁门关=659006 双河=659007 可克达拉=659008 昆玉=659009 胡杨河=659010 新星=659011 白杨=659012")

        * --- 港澳台 ---
        replace city_stname = "香港特别行政区" if ustrregexm(`v', "香港") & city_stname == "" & `touse'
        replace city_type = "特别行政区" if city_stname == "香港特别行政区" & `touse'
        replace city_prov = "香港特别行政区" if city_stname == "香港特别行政区" & `touse'
        replace city_code = "810000" if city_stname == "香港特别行政区" & `touse'

        replace city_stname = "澳门特别行政区" if ustrregexm(`v', "澳门") & city_stname == "" & `touse'
        replace city_type = "特别行政区" if city_stname == "澳门特别行政区" & `touse'
        replace city_prov = "澳门特别行政区" if city_stname == "澳门特别行政区" & `touse'
        replace city_code = "820000" if city_stname == "澳门特别行政区" & `touse'

        * 台湾城市无 GB/T 2260 六位代码，city_code 留空
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
        replace city_code    = "" if ustrregexm(`v', "地区|自治州|盟") & `touse'

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

    * 未指定 detail 时不保留 city_special / special_ctlist（仅用于内部逻辑）
    if "`detail'" == "" {
        qui drop city_special special_ctlist
        local hint `"city_stname == """'
    }
    else {
        local hint `"city_stname == "" & city_special == """'
    }

    display as txt "{hline 45}"
    display as txt "处理观测数:" _col(38) as res %9.0fc `n_tot'
    display as txt "  匹配到城市 (city_stname):" _col(38) as res %9.0fc `n_city'
    display as txt "  仅匹配到地区/州/盟 (city_special):" _col(38) as res %9.0fc `n_spec'
    display as txt "  未匹配:" _col(38) as res %9.0fc `n_unmat'
    display as txt "{hline 45}"
    if `n_unmat' > 0 {
        display as txt `"提示: 可用 {stata list `v' if `hint':list `v' if `hint'} 查看未匹配观测"'
    }
    if `n_spec' > 0 & "`detail'" == "" {
        display as txt "提示: 指定 detail 选项可输出 city_special 与 special_ctlist"
    }
end

* 子程序：对一组城市名执行"包含即匹配、先到先得"的标准化
* list 中的元素格式为 名称=行政区划代码（如 石家庄=130100）；无代码时可只写名称
program define cncity_match
    version 14
    syntax varname(string), TOuse(varname) PROV(string) TYPE(string) LIST(string)
    foreach c of local list {
        local name "`c'"
        local code ""
        local eq = strpos("`c'", "=")
        if `eq' > 0 {
            local name = substr("`c'", 1, `eq' - 1)
            local code = substr("`c'", `eq' + 1, .)
        }
        replace city_stname = "`name'市" if ustrregexm(`varlist', "`name'") & city_stname == "" & `touse'
        replace city_type   = "`type'"  if city_stname == "`name'市" & `touse'
        replace city_prov   = "`prov'"  if city_stname == "`name'市" & `touse'
        replace city_code   = "`code'"  if city_stname == "`name'市" & `touse'
    }
end
