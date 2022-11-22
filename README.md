# GTNH-SevereColdNuclearPower
## GTNH强冷核电 OC 解决方案

# 配置 JSON 文件格式

```(json)
{
    "siLianYouBang": [
        {
            "name": "gregtech:gt.360k_Helium_Coolantcell",
            "changeName":-1,   // 如果不是燃料棒，一般填 -1
            "dmg": 90,         //冷却剂到dmg多少被替换
            "count": 14,      // 初始摆核电仓需要的数量
            "slot": [3,6,9,10,15,22,26,29,33,40,45,46,49,52]        //核电仓中的摆放顺序
        },
        {
            "name": "gregtech:gt.reactorUraniumQuad",
            "changeName":"IC2:reactorUraniumQuaddepleted",    // 燃料棒枯竭后的名字
            "dmg":-1,         // 如果不是冷却剂，一般填 -1
            "count": 40,
            "slot": []
        }
    ]
    ……
}
```



