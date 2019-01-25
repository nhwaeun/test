#! ruby -Ks
#
# summarizer07.rb
# usage: ruby -Ks summarizer05.rb [-r 0.1~1.0] [-sen] < FILENAME.mcb.txt
# 2018.12.13 文の長さを測る追加 平均長より短ければ 1.2倍
require 'optparse' # オプションの解析
options = Hash.new
OptionParser.new{|opt|
  opt.on('-sen'){|v| options[:sen] = v}
  opt.on('-r ritsu'){|v| options[:ritsu] = v}
  opt.parse!(ARGV)
}
if (options[:ritsu]) then
  ritsu = options[:ritsu].to_f
else
  ritsu=0.3 #--デフォルトの要約率
end
#-----------------------------------------------------------------
terms = 0  # 総単語数を数えるための変数　（ 0で初期化）
tf=Hash.new  #tfという名前で個別の単語数を数えるためのハッシュ（連想配列）を準備する
tf.default = 0 # ハッシュ tf の 初期値を 0 にしておく 
linect=0 # ループ2回目用配列の添え字用 ---------------------(追加)
hyoso = Array.new # 表層形を保存するための配列 -------------(追加)
kihon = Array.new # 基本形を保存するための配列 -------------(追加)
hinshi= Array.new # 品詞を保存するための配列   -------------(追加)
sai1 = Array.new  # 品詞の細分類1を保存するための配列-------(追加)
sai2 = Array.new  # 品詞の細分類2を保存するための配列-------(追加)
sai3 = Array.new  # 品詞の細分類3を保存するための配列-------(追加)
#---------------------------------------------------------------------------
sc = 1 # 文番号を入れる変数 --------------------------------(追加)
sen = Array.new # 文本体を入れる変数------------------------(追加)
sen[sc] = ""    # 最初の文を空にして初期化 -----------------(追加)
textlength=0 #---- textの長さ
while line=STDIN.gets # whileループの開始 標準入力から1行受け取りlineに代入
  line.chomp! # 変数lineについている改行コードを除去する
  if line =="EOS" # lineの中身が 'EOS' だったら，以下を実行
    hyoso[linect]=line
    sc += 1 # 文番号を1つ増やす-----------------------------(追加)
    sen[sc] = "" # 新しい文を空にして初期化-----------------(追加)
  else
    a = line.split(/\t/) # MeCabの区切り子1 (line を tabでsplitして，配列aに結果を保存)
    b = a[1].split(/,/)  # MeCabの区切り子2 (a[1] を  , でsplitして，配列bに結果を保存)
    if b[6]=="*" # 例外
      b[6]=a[0]
    end
    tf[b[6]] +=1 # ハッシュtfの b[6] の部屋に値1を足して，上書き (b[6]が基本形)
    terms +=1  # 変数 terms に 1を足して，上書き
    hyoso[linect]= a[0] # linect番目の表層形を保存 ---------(追加)
    kihon[linect]= b[6] # linect番目の基本形を保存 ---------(追加)
    hinshi[linect]=b[0] # linect番目の品詞を保存 -----------(追加)
    sai1[linect] = b[1] # linect番目の品詞の細分類1を保存 --(追加)
    sai2[linect] = b[2] # linect番目の品詞の細分類2を保存 --(追加)
    sai3[linect] = b[3] # linect番目の品詞の細分類3を保存 --(追加)
    sen[sc] = sen[sc] + hyoso[linect] # --------------------(追加)

    textlength = textlength + 1 # 形態素単位の長さ
    #textlength = textlength + hyoso[linect].size # 文字数単位の長さ

  end #------- if文 終わり
  linect += 1 # ループ2回目用のカウント変数に1を足す -------(追加)
end #----- whileループ終わり

avelength = textlength / (sc-1) # --- 平均文長の計算
#
# types=0
# ハッシュtfから，1要素ずつ取り出し，添え字（部屋の名)をstrに，値をstrに代入
#tf.each {|str, value|  
#  printf "%s\t%d\n", str, value # valueを整数，strを文字列として表示
#  types+=1
#}
#printf "総単語数\t%d, 異なり単語数\t%d\n", terms, types # 総単語数と異なり語数を表示
sscr = Array.new # 文の得点を入れる配列 ------(summarizer02.rbで追加)
sc = 1 # 文番号 ------------------------------(summarizer02.rbで追加)
sscr[sc] = 0.0 # 文の得点を0.0で初期化 ----------------(summarizer05.rbで修正)
snum = Array.new  #文番号を入れる配列 -------------(summarizer03.rbで追加)
snum[sc] = sc # 文番号を記録 ----------------------(summarizer03.rbで追加)

senlength = 0 # --- 文の長さ

for i in 0..linect-1 # 0から始めて形態素データの終わりまで
  if hyoso[i] == "EOS" # 表層が EOS，1文が終わった処理
    # printf "SN: %d SCR: %d %s\n", sc, sscr[sc], sen[sc]

    if senlength > avelength   # 今の文の長さが平均長より長ければ
      sscr[sc]=sscr[sc]*1.5    # 文スコアを 1.2倍する
    end
    senlength = 0              # 次の文のために長さを 0で初期化

    sc += 1 # 次の文に進める
    sscr[sc] = 0 # 次の文の得点を0で初期化
    snum[sc] = sc # 文番号を記録 ------------------(summarizer03.rbで追加)
  else
    if hinshi[i] =~ /^名詞/ # この語の品詞が名詞だったら...
      sscr[sc] = sscr[sc] + tf[kihon[i]] # 表層形の出現頻度を文スコアに足す
    end

    senlength = senlength + 1             # 形態素単位の長さ
    #senlength = senlength + hyoso[i].size # 文字単位の長さ

  end #------------- if hyoso[i] == "EOS" 
end #-----------------------------------ここまで summarizer02.rbで追加-
#------------------------------ スコア順にソート summarizer03.rbで追加-
rank=Array.new # 各文の順位を入れる配列
for i in 1..sc-2
  for j in i+1..sc-1
    if sscr[i]<sscr[j]
      tmpscr = sscr[i]
      tmpnum = snum[i]
      sscr[i]= sscr[j]
      snum[i]= snum[j]
      sscr[j]= tmpscr
      snum[j]= tmpnum
    end
  end
  rank[snum[i]]=i # snum[i]の文が順位i位であることを記録する
end
rank[snum[sc-1]]=sc-1 # 最後の順位を記録
#------------------ 要約率分の出力文数の計算と並べ替え--summarizer04.rbで追加- 
outnum=((sc-1)*ritsu).round # 出力文の数を計算する
for i in 1..outnum-1
  for j in i+1..outnum
    if snum[i]>snum[j]
      tmpsnum = snum[i]
      tmpsscr = sscr[i]
      snum[i] = snum[j]
      sscr[i] = sscr[j]
      snum[j] = tmpsnum
      sscr[j] = tmpsscr
    end
  end
end
#------------------ 結果を表示する outnum文分だけ出力 summarizer05.rbで修正-
for i in 1..outnum
  if (options[:sen])
    printf "順位 %2d スコア %2f 文番号 %2d %s\n", 
          rank[snum[i]], sscr[i], snum[i], sen[snum[i]]
  else
    printf "順位 %2d スコア %2f 文番号 %d\n", 
          rank[snum[i]], sscr[i], snum[i]
  end
end
exit # プログラム終了
