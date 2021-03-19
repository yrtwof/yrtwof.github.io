---
pagetitle: ざっぱな置き場
css: ../style.css
...

<header class = "header">
# 動物の近接戦闘時の平均DPSの算出方法とか戦闘時の選択
#### 明日使えないRimworldでの平均DPSとか戦闘時に使用する部位の話です。
<hr>
</header>

<div class = "content">

[ indexへ ](index.html)

Rimpedia([これ](https://steamcommunity.com/sharedfiles/filedetails/?id=2145524536))作成時に、どうにかして動物の戦闘時の平均DPSを出そうとしたけど、どうやらそう単純な話ではなかったという話。
だいぶ昔に調べた話で、だいぶ忘れているので違うことを平気で語る、かも。

### ● まず動物が戦闘時にどの値を参照するかの話
動物が戦闘時に使用する部位は、ThingDef内の\<tools\>内に書いてある値を参照する。

#### ・\<tools\>の説明
toolsとはそもそもtoolのList。
ユーザが xml で書いた tools 内の li の中身がxml解析時にtoolとして読み取られ、値が格納される。今回の解説で使う値は以下。

* power : そのままの意味。つまりダメージ。高いほど強い。
* cooldownTime : そのtoolを使ったときに次に使用するまでの時間。短いほど連打できる。
* chanceFactor : 選択率？みたいな感じ。値が高いほど優先して使用するが、1でも絶対に使うわけではない、という話をこれからする。
* alwaysTreatAsWeapon : 戦闘部位かどうかの判定。falseの場合、その部位のダメージが0.3倍になる。

話がややこしくなるので、以下が前提条件。

* 怪我していない：linkedBodyPartsGroupで特定部位とLinkできるが、その部位の耐久値によってダメージが変動するため。
* surpriseAttackではない：なんか非戦闘時にはダメージボーナスが出るみたいだけどめんどくさいので。
* 攻撃者の装備はなし。
* 被攻撃者の全部位の耐性は無視。つまりtoolのarmorPenetrationは無視。
* 遠距離攻撃とか、距離や範囲で威力が増減するのは無視。：作者がよく分かってないので。

### ● DPSがどういうふうに算出されるかの話
普通のDPSだとpowerをcooldownTimeで割って～とかなんだけど、Rimworldではどうやら **最もダメージを出す郡のtoolを優先して使う** みたい。
詳しくは VerbProperties やStatWorker_MeleeAverageDPS などを参照。

#### DPS 算出するときの工程
大まかな工程は以下の3つからなる。

1. 各toolのみを使用した場合のDPSを算出し、最大のDPSのtoolを記録する
2. 最大のDPSをもとに、各toolをそれぞれ以下に分類する
    * *best* : 最大DPS * 0.95以上
    * *mid* : 最大DPS * 0.25より上
    * *poor* : 最大DPS * 0.25以下
3. 2.で分類の個数と自身の分類により重み付けする

#### 1.各toolのDPSの算出
おおまかな計算式は以下。

単体DPS = chanceFactor * (ダメージ) * (アーマー貫通率) / cooldownTime

#### ダメージ
(ダメージ) = (power * (装備のダメージ係数 * 素材係数)) * (部位効率) * (成長効率)

部位効率部分は *よくわからん* 計算をしてるのでよくわかってない。
成長効率はpawnのcurLifeStageのmeleeDamageFactorのこと


#### アーマー貫通率

* toolsにarmorPenetrationが記述してあれば**その値**に、
* 記述がない場合は**ダメージ\*0.015**

</div>


<footer class ="footer">
<hr>
<p align = "center"> [top](../index.html) </p>
</footer>
