-- 建立「旅行清單」筆記到 Apple Notes
-- 用法：osascript add-travel-checklist-to-notes.applescript

set noteTitle to "旅行清單"

set noteBody to "<h1>旅行清單</h1>

<h2>證件與重要文件</h2>
<ul>
<li>旅遊證件</li>
<li>香港身份證 / 護照 / 回鄉卡</li>
<li>SIM 卡</li>
</ul>

<h2>衣物</h2>
<ul>
<li>T 恤 / 上衣 / Hoodies（衛衣）</li>
<li>短褲 / 長褲</li>
<li>外套 / 風褸</li>
<li>運動衫</li>
<li>Heat Tech（保暖內衣）</li>
<li>內衣 / 睡衣</li>
<li>襪</li>
<li>波鞋 / 皮鞋</li>
<li>拖鞋</li>
<li>泳衣</li>
<li>帽 / 手套</li>
<li>保暖口罩</li>
</ul>

<h2>個人護理</h2>
<ul>
<li>毛巾</li>
<li>沐浴露</li>
<li>洗頭水</li>
<li>護髮素</li>
<li>牙刷</li>
<li>牙膏</li>
<li>牙線</li>
<li>漱口水</li>
<li>化妝品（放入密封透明袋）</li>
<li>化妝袋、鏡</li>
</ul>

<h2>藥物與健康用品</h2>
<ul>
<li>鼻敏感藥</li>
<li>濕疹藥</li>
<li>傷風藥</li>
<li>尿道炎藥</li>
<li>消毒藥水</li>
<li>藥水膠布</li>
<li>保濕口罩</li>
<li>暖包</li>
<li>蚊怕水 / 蚊貼 / 蚊膏</li>
<li>M 巾</li>
</ul>

<h2>電子產品與配件</h2>
<ul>
<li>手提電話 + 充電器</li>
<li>手錶 + 手錶充電線</li>
<li>電話繩</li>
<li>旅行萬用插頭</li>
<li>自拍棍</li>
</ul>

<h2>日常用品</h2>
<ul>
<li>背囊 / 腰包</li>
<li>手袋</li>
<li>雨傘</li>
<li>太陽眼鏡</li>
<li>水樽</li>
<li>環保袋</li>
<li>紙巾</li>
<li>圓珠筆</li>
</ul>

<h2>金錢</h2>
<ul>
<li>當地貨幣</li>
<li>信用卡</li>
</ul>

<h2>零食</h2>
<ul>
<li>零食（可與別人一起分享）</li>
</ul>"

tell application "Notes"
	-- 刪除同名舊筆記（如有）
	repeat with acc in every account
		repeat with f in every folder of acc
			repeat with n in (every note of f whose name is noteTitle)
				delete n
			end repeat
		end repeat
	end repeat

	-- 優先寫入 iCloud，否則用預設帳戶
	set targetAccount to missing value
	repeat with acc in every account
		if name of acc is "iCloud" then
			set targetAccount to acc
			exit repeat
		end if
	end repeat

	if targetAccount is missing value then
		set targetAccount to first account
	end if

	tell targetAccount
		make new note at default folder with properties {name:noteTitle, body:noteBody}
	end tell
end tell

return "已建立 Notes 筆記：「" & noteTitle & "」"
