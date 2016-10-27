# EEW-notification
eew-ntf.sh　本体：1秒ごとeew-get.shをたたいて更新を確認する

eew-get.sh　新強震モニタを叩いてSignalNow形式っぽいものをはき出させる

eew-calc.sh　eew-ntf.shに叩かれて現地予測震度、到達予測時刻（UNIX時間）を任意のプログラムに投げる

# インストールしておくべきもの
bash
jq
sed
wget
bc
