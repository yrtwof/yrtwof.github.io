---
pagetitle: ざっぱな置き場
css: ../style.css
...

<header class = "header">
# Rimworldでのデータの保存と読み込み
#### MOD製作者ならほぼ全ての人が熟知しているであろうRimworldにおけるデータの保存と読み込みについての話。
<hr>
</header>

<div class = "content">
[ indexへ ](index.html)

参考：
 * [https://spdskatr.github.io/RWModdingResources/saving-guide.html](https://spdskatr.github.io/RWModdingResources/saving-guide.html)


## ■Rimworldでのデータの保存
MODつくるとセーブしたデータがロードすると反映されていなくてにゃーんとなることがままあるが、それらはだいたい保存をしていないからである。

なのでRimwroldにおいてはデータセーブとロードは必須なのだが、解説記事があんまりないしピンと来ないものなので書く。

## ■大前提の話
RimworldではIExposableに実装されているExposeDataがSave・Load時に読まれて、その中の```Scribeほにゃ.Look```で値の保存・読み込みが実行され、セーブデータやModSettingに保存されている値を反映させられる。

なお、MOD導入時などの値が見つからない場合は初期値(場合によってはnull)か defaultValue の値が読み込まれる。


### ExposeData
IExposableというインターフェイスのメソッド。

Rimworldでは、セーブとロード時にこのメソッドが呼ばれるので、IExposableを継承して、このメソッド内にデータを保存する処理を書けばいい。

```
    public override void ExposeData()
      {
        //ここの保存処理を書く
      }
```

### Scribeを用いたデータの保存
前節で保存処理を書く場所は書いたので、実際に値を保存する方法を書く。

Rimworldでは、
保存したいデータの種類に対応した ```Scribe_ほにゃ``` クラスの、void Look(...)メソッドを使用して保存・読み込みをする。

* Scribe_Vaues
    * 基本データ構造(int,float,bool,double...)、列挙体、文字列、UnityEngineで使えそうなやつ(Vector2,Rect,Color,Rot4...)
    * Scribe_Vaues.Look(ref target, label, defaultValue = null, forceSave = false )
        * target : 保存&読み込みする変数
        * label : 保存&読み込み時にこの名前で検索する
        * defaultValue : labelで検索して見つからなかった場合に読み込む値。
        * forceSave : 値に変更がない場合でも保存するかどうか。trueにするとsavedataの容量が増えるが、元からめちゃ多いからそんなに気にしなくていいと思う。

* Scribe_Defs
    * **Def系(ThingDef,JobDef,Defを継承したもの)
    * Scribe_Defs.Look(ref target, label)

* Scribe_Deep
    * 上記のIExposableを継承したクラス
    * Scribe_Deep.Look(ref target, saveDestroyedThings = false, label, params)
        * saveDestroyedThings : 保存する対象がDestroyed状態の場合に保存するかどうか。
        * params : targetの初期化に利用する値。
    * target内のExposeDataが呼び出されるので、target内で上記のScribe_VauesとかDefsとかを使うのが基本

* Scribe_Collections
    * Collection(Array,List,HashSet,Dictionary...)の保存に使う。Dictionaryの場合はちょっとめんどくさい。
    * Scribe_Collections.Look(list, label, lookMode, param)
        * list : リスト。仮にT型とする。
        * lookMode : リストに保存&読み込みするデータの種類を指定する列挙体。
            * TがintとかならValues, ThingDefとかならDef,自作IExposable継承クラスならDeep
    * Scribe_Collections.Look(dict, label, keyLookMode, valueLookMode)
    * Scribe_Collections.Look(dict, label, keyLookMode, valueLookMode, ref keysWorkingList, valueWorkingList)
        * dict : 保存したい辞書型。借りにキーをK型、値をV型とする
        * keyLookMode : キーの保存&読み込みの種類。前節のlookModeと同じ。
        * valueLookMode : 値の保存&読み込みの種類。
        * keysWorkingList、valueWorkingList :
            * dictを読み込むときに使用する一時リスト。一時的にしか使用しない(ハズ)なので、基本は↑のScribe_Collections.Look(dict, label, keyLookMode, valueLookMode)でいい。

* Scribe_References
    * 使ったことない。なんか参照を保存するらしい。
    * MapやWorld内のThingを管理したいなど、すでにあるObjectへの参照はこれを使用する。

* Scribe_TargetInfo
    * 使ったことない。ものとか場所とかWorldObjectを指すらしい。JobWorkerとかで使えそう


#### lookModeについて
Scribe_Collectionsなどでkeyやvalueを保存する際に、引数として〇〇LookModeというのがある。これは保存するデータによってそれぞれ指定するlookmodeの値が異なる。

* LookMode.
    * Value：intやfloat, stringなどの定数値
    * Deep：IExposableを継承したなんらかのクラス
    * Reference：他のThingなどへの参照
    * Def：ThingDefなどのDef系
    * その他：使うときに調べて

### 保存時・読み込み時特有の処理
保存・読み込んだときにだけやりたい処理がある場合とかは、Scribe.modeの値をみて処理を変える。

保存時にはLoadSaveMode.Savingが1度だけ実行される。
読み込み時は、複数回ExposeDataが以下の順序で呼ばれる。

1. LoadingVars：値の読み込み。
2. ResolvingCrossRefs：参照の読み込み。1.で読み込んだ値を使用して読み込む
3. PostLoadInit：事後処理

* Scribe.mode ==
    * LoadSaveMode.Inactive : わからん
    * LoadSaveMode.Saving : 保存中
    * LoadSaveMode.LoadingVars : 値の読込（intやstringなどの値の読み込み）
    * LoadSaveMode.ResolvingCrossRefs : 参照の読み込み
    * LoadSaveMode.PostLoadInit : 読込後の事後処理



### 上記をまとめた使い方例
```
  public override ExposeData(){
    if(Scribe.mode == LoadSaveMode.Saving){
        //保存時に不要なデータをlistから削除しておく
        DeleteNonePawn(list);
    }
    else if(Scribe.mode == LoadSaveMode.LoadingVars){
        // 読み込み時にこのクラスで使用する変数を初期化する
        // 読み込みとかは下のScribe_ほにゃ.Lookですること。あくまでLookで読み込めない/読み込む必要がない値の初期化。
        // Lookの引数で指定もできるので無理に書く必要はない
        tmp = new List<Pawn>();
    }

    // saveDataにPawnCountという名前で保存し、
    // saveDataからPawnCountの値を探し、見つかればそれで、見つからなかったら0で count を初期化する。
    Scribe_Values.Look(ref count, "PawnCount", 0);

    Scribe_Collections.Look(ref pawnList, "PawnList", LookMode.Def, tmp);
  }
```

みたいな感じで。


## ■保存するデータの単位
どこでデータを保存するかの話。
全然調べていないけど、多分 下の２つくらいしか使わないと思う。

* セーブデータ単位：別のセーブデータを読み込んだ際には別のデータが読み込まれる
* ゲーム単位：セーブデータに関わらず読み込む

### セーブデータ単位
要は、別のセーブデータを読み込んだ際に別のデータを読み込むかどうかの話。
下のWorldComponentとかMapComponentをOverrideしたのをプロジェクトに追加しておいて、ExposeDataで保存・読み込みしておけば問題ない。

* WorldComponent：
    * 世界（コロニー、山、道とか）単位でデータを保存する。実質セーブデータ単位で保存するに等しいと思ってる。
* MapComponent
    * マップ（動物、Pawn、建物とか）単位でデータを保存する。


### ゲーム単位
セーブデータに関わらず読み込みたい、例えばConfigのMod設定とかでいじれる値とか。
下のModSettingsをOverrideしたのを以下略。

* ModSettings：ゲーム開始時に読み込みされる。
    * 補足：強制的に保存させたい場合は、Mod.WriteSettingsをPreCloseの際に呼び出せば保存できる。


### 上記をまとめた使い方例
```
  public classs TestModSetting : ModSettings
  {
    // なんかMOD独特の設定。
    private float count;

    public override void ExposeData(){
        //上と同じく読み書き。
        Scribe_Values.Look(ref count, "count", 0);
    }

  }

```


</div>

<footer class ="footer">
<hr>
<p align = "center"> [top](../index.html) </p>
</footer>
