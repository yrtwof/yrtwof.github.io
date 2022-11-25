---
pagetitle: ざっぱな置き場
css: ../style.css
...

<header class = "header">
# RimworldでWidnowの作り方
#### MOD製作者でちょっとggったら出てくる話
<hr>
</header>

<div class = "content">
[ indexへ ](index.html)

## Rimworldにおける画面の描写
Rimworldの画面描写は、Window抽象クラスをoverrideしたクラス上で、```DoWindowContent```上に書いてある処理が毎フレーム(?)読み込まれることで実行される。

あとはだいたいWidgets上のメソッドを適当に呼び出すといい感じの画面ができる。

Windowの追加はFind.WindowStack.Add(window)でできて、Find.WindowStack.Remove()で取り除ける。

### ■Rect
UnityEngineで使ってる（と思う）。四角形の範囲を表し、x, y, width, height の４つのパラメータがある。

※ 実態は xの最小値(xMin)、yの最小値(yMin)と、幅(width)と高さ(height)だが、

* x : x座標。左上が0で、右(?)に行くほど値が増える。
* y : y座標。左上が0で、下(?)に行くほど値が増える。
* width : その範囲の幅を表す。
    * xMin : widthの左端。
    * xMax : widthの右端。
* height : その範囲の高さを表す。
    * yMin : heightの上端。
    * yMax : heightの下端。


### ■Window
だいたいこれをoverrideしていろいろ実装する。

#### InitialSize
Vector2型。画面の大きさ（幅と高さ）。
```
public override Vector2 InitialSize
{
    get {
      // float型の幅700と高さ500の Window を作る
        return new Vector2(700f, 500f);
    }
}
```

#### PreOpen, PostOpen
Windowを開くときのいろいろな処理はココに書く。
例えば、Window内で使用するリストをここで初期化するとか。

* PreOpen -> (windowが開く) -> PostOpen
だいたいはPreOpenに書けば問題ないはず。

#### PreClose, PostClose
Windowを閉じるときのいろいろな処理はココに書く。
例えば、Window内で使用したリストをメモリから解放するとか。

* PreClose -> (windowが閉じる) -> PostClose
だいたいPostCloseに書けば問題ないと思う。

#### DoWindowContents(Rect inRect)
InitialSizeのサイズのWindowを作ってinRect内に描写したいWindowの内容を書く。


#### 細かいあれこれ
ILSpyとかでWindowの中をみて変数名で実現したいのをtrueにしろ

* draggable : windowsがドラッグできるか
* soundApper/ soundClose : windowsが開いた/閉じた時の音
* onlyOneOfTypeAllowed : Windowを複数個開くことを許可するか
* resizeable : Windowサイズを可変にするか。可変にするともれなくDoWindowContentの中の処理を真面目に考えないといけない。
* doCloseX : trueにすると右上にX印ができて、これを押して画面が閉じれるようになる。
* doCloseButton : trueにするとWindowの下の方に閉じるボタンができてそれを押して画面を閉じれるようになる。
* closeOnClicledOutSide : trueにするとWindowの画面外をクリック時にWindowを閉じる

### ■Widgets
Rimworldでよく使う画面操作系のWindow周りをまとめたクラス。基本ここに実装してあるメソッドを書けば大体の画面は実装できる。

ILSpyとかを見て手を動かして確認しろ。

#### よく使える便利なメモ
* Label：ラベル。
    * 表示する文字が長いとはみ出すこともあるので、そのときはText.CalsSizeとかstring.Truncate(width)とかでlabelを省略するか、LabelFitを使う
* DrawMenuSection：それっぽい背景を作ってくれる
* DrawBox：四角□。中まで塗りつぶす場合はDrawBoxSolidを使う
* BeginScrollView, EndScrollView：スクロールできるエリアを作成する。outRectが外枠（つまりは操作していないときの通常の見える範囲）、viewRectはスクロールされる描写範囲。詳しくは自分で書いてみて
* DrawTextureFitted：できるだけRect枠にフィットするように画像を配置する。ただし色は自分でつける。
* Widgets.ThingIcon：ThingDefのiconやiconColorに従った画像を描写する
* RadioButton, CheckBox：名は体を表す
    * CheckboxLabeled：↑のCheckBoxのラベル付き



### ■Tab系
Tab作りたいときはこれ。ただRimworld準拠なので結構無駄が多そう。
タブの実装は、タブ本体(TabRecord)と、タブの描写(TabDrawer)を使って実装できる。

#### TabRecord(string label, Action clickedAction, bool selected)
* label : タブのところに表示するタブの名前
* clickedAction : タブクリック時に実行する処理。nowTabとかを別途作っておいて、この中にnowTabをclickしたのにする、みたいな処理を書くとタブ押すと別画面を表示とかできる
* selected : どの状態の場合にタブをアクティブにするか?よくわかってない

#### TabDrawer.DrawTabs(Rect baseRect, List<TabRecord> tabs, float maxTabWidth = 200f)
#### TabDrawer.DrawTabs(Rect baseRect, List<TabRecord> tabs, int rows)
* baseRect : タブを表示する場所
* tabs : 上で定義したタブ
* maxTabWidth : タブの横幅
* rows : タブを縦列に表示するかどうか。これが2以上の場合、重ねて表示されるようになる、ハズ。

#### まとめ
```
  private override void PreOpen(){
    tabList.Clear();

    tabList.Add(new TabRecord("タブA",
      ()=>{
        nowTab = myTab[0];
        nowTab.Init();
      },
      ()=> nowTab == myTab[0])
    );

    // 同じようにTabを追加する。
    ...
  }

  public override void DoWindowContents(Rect inRect) {
    ...
    TabDrawer.DrawTabs(rect, tabList, 26f * tabList.Count() );
    nowTab.Draw(rect2);
    ...
  }
```

### その他
* GUI.Color：色。基本値はColor.white。これを変えると↑の図形などに色をつけれる。alphaもあるので透明もできる。
* Text.Font：フォントサイズ。構造体なのでサイズを可変で～とかはしんどい
* Text.Anchor：描写内のテキストの配置。
* string.Truncate：stringがwidth以上になる場合はそこを「...」に書き換えてくれる
* string.Colorize：colorに応じて文字色を付けるが、たまにうまくいかない事がある。原理はstringの前後の`<color>`みたいなタグを挿入する。
* TooltipHandler.TipRegion：Rect内にマウスカーソルがあるときにちっちゃい説明ダイアログを表示する。
* Rect.ContractedBy：marginしたRectを返してくれる。ScrollViewとか作るときにとかBox内にコンテンツ表示させるときに、そのまま書くとイケてない感じになるのをいい感じにしてくれる



</div>

<footer class ="footer">
<hr>
<p align = "center"> [top](../index.html) </p>
</footer>
