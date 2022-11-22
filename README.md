# GTNH强冷核电 OC 解决方案

## 材料需求
0. 核电一套
1. OC 电脑一套（显示器、机箱、cpu、gpu、内存等）
2. 红石IO端口一个
3. 适配器一个
4. 转运器一个
5. 箱子两个
6. 抽屉一个（箱子也行）

## 配置 JSON 文件格式

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

## 推荐摆放图示
![Snipaste_2022-11-23_06-39-43](https://user-images.githubusercontent.com/49380228/203435807-548c7143-3195-4f62-96a8-7ca6d71113ed.png)



