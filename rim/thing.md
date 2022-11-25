---
pagetitle: ざっぱな置き場
css: ../style.css
...

<header class = "header">
# Rimworldの物体・建物などの構造
#### ggってもあまり出てこない基本的な話
<hr>
</header>

<div class = "content">
[ indexへ ](index.html)

## Rimworldにおける存在
Rimworldでの物体の表現方法を知ると、実現したいものに対するアプローチがやりやすくなり、xmlに何を記載するべきかがわかりやすくなる。

でも、そういう、物体とか動物とかの構造を解説している記事は見たことない。
なので、私が知ってる限りの情報を記載する。

本ページで扱うもの：
・物体（テーブルや建造物、動物、Pawn…）
つまりは、ThingDefとPawnKindDef、ThingとPawnなどとの関係
また、それらにMod独自設定や追加を行うための基礎知識


## ThingDef：モノの定義
ThingDefは、Rimworldでの物体を表す構造のこと。C\#上にはもっと親の構造があるが、正直ThingDefとその子さえ知っていればほぼ問題ない。

ThingDefは、表したいモノの「定義」を表す。コロニー内の動物、植物、入植者(Pawn)、鉱石、建造物、生産物、食べ物などは、この、ThingDefを元に作成される。

ここで、注意したいのが、ThingDefはあくまで定義である。
ThingDefは骨格や特性に近く、実際にゲーム内で処理が行われる単位ではないことに注意したい。
つまり、C\#などでThingDefに手を加えると、それを参照するすべてのモノに影響を与える可能性がある。


## Thing：実際に処理が行われるモノの単位
ThingDefで述べたように、実際のゲーム内で処理が行われる単位は、Thingである。「処理」とは、動かしたり、ダメージを受けてHPを減らしたり、保存されたりを指す。

ゲーム内のモノは、大体ThingおよびThingを継承したクラスで動かされる。
例えば以下などがある。

* 人や動物：Pawn
* 植物：Plant
* 装備：Apparel
* 建造物：Building
* 発射物（弓矢とか銃の玉とか）：Projectile、Bullet
* 爆発：Explotion
* 死体：Corpse

など

それぞれ、そのモノの特性に応じたThing派生クラスが定義されている。


## ThingDefと動物・植物・建造物
先程、「モノの特性に応じたThing」と言ったが、実際のxmlを見るとThingDef一つ内に表したいモノに応じた記述をすることになる。

では、ThingDefで動物、植物、建造物を区別するために何を記載する必要があるかというと、それぞれのモノの特性に合わせたPropertiesが実は定義されている。例えば、

* 人や動物：`RaceProperties race`
* 植物：`PlantProperties plant`
* 建造物：`BuildingProperties building`

xmlで、動物のThingDefに記載している `<race>` などはこの `RaceProperties` の情報である。

このように、それぞれ表現したいモノに合わせて表現したい部分に記載する必要があり、
逆に、共通的な特性部分、例えば `<size>`や`<category>` などはこの`<race>`などには記載してはいけない。

### ■ 動物：PawnKindDef と ThingDef と race
Rimworldにおける動物は、

* ThingDef：モノとしての特性
  * race：動物としての特性
* PawnKindDef：動物の種族的特性

の３つを記載する必要がある。






</div>

<footer class ="footer">
<hr>
<p align = "center"> [top](../index.html) </p>
</footer>
