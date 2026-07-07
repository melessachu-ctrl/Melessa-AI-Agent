# 01｜Terminal 設定與安全起步

> 目的：讓你安全打開工作環境、看見自己的 folder、裝好三層安全網，知道哪些 terminal / AI action 要停一停再問人。  
> 你不是要學做工程師，而是要學識足夠的 setup 語言，安全管理你的第一位 AI 員工。

---

## 1. 為甚麼要先做這一步

開始用 AI agent 之前，大部分人心裏都有三個不安：

```text
1. 「AI 會不會把我的檔案刪掉？」
2. 「AI 會不會跑出一些我看不懂的危險指令？」
3. 「每次都彈確認框很煩，但我又不敢全部關掉……」
```

這三個不安全部有解。這一節會幫你裝好**三層安全網**，之後你可以放心讓 AI 做事，因為底層有系統接住。

同時，我們要先有一個共同 setup：

```text
我知道我的 agent files 放在哪裏。
我知道怎樣打開那個 folder。
我知道哪些 command 是安全的。
我知道哪些資料不可以貼給 AI。
我知道甚麼時候 AI 必須先問我，不能自己行動。
```

Terminal 不是這堂課的主角。它只是進入 agent 工作 folder 的入口。

這次 training，你的第一位 agent 會是 **Personal AI Assistant**。它的 folder 會放它的 profile、reference notes、memory、進度和 session logs。如果 folder 混亂，agent 也會混亂；如果邊界不清楚，agent 就容易做多了、做錯了，或者接觸不應該接觸的資料。

---

## 2. 這一節完成後，你會有甚麼

完成這一節後，你應該會有：

- 一個之後找得到的 training folder。
- 一個第一位 agent 的 folder：`Personal_AI_Assistant`。
- 一個用來放每日交接紀錄的 `sessions` folder。
- 一套裝好的**安全三件套**：垃圾桶保護 + 危險指令黑名單 + 你自己選的權限模式。
- 一份 safe command checklist。
- 一份 data boundary checklist。
- （可選）一個更好用的 terminal：畫面不閃、滾輪可以回看、兩個字啟動。
- 一段當你卡住時，可以直接貼給 AI assistant 的 prompt。

目標 folder structure：

```text
AI_Agent_Training/
└── Personal_AI_Assistant/
    └── sessions/
```

---

## 3. 最簡單的理解方法

你可以這樣理解 setup：

| 部分 | 白話意思 | 為甚麼重要 |
|---|---|---|
| Terminal | 用文字打開電腦工作區的入口 | 讓你知道自己在哪裏、建立 folder、檢查 files |
| Folder | Agent 的工作空間 | 把 profile、memory、logs 放在同一個地方 |
| Agent files | AI 員工手冊 | 告訴 AI 它是誰、做甚麼、語氣、邊界 |
| Memory files | 交接系統 | 讓 AI 下次可以接住做，不用每次由零開始 |
| Safety rules | 安全邊界 | 防止誤刪、覆蓋、敏感資料外洩、權限失控 |

### 整套安全設計背後的一個核心思路

```text
「教 AI 不要做」不夠——AI 會忘記。
真正可靠的是「讓 AI 做不到」。
```

寫在 files 入面的規則，AI 平常會照做，但長對話之後可能忘記、可能被沖淡。所以安全要分兩層：

| 層 | 是甚麼 | 特性 |
|---|---|---|
| **記憶層** | 寫給 AI 看的規則（agent files 入面的紅線） | AI 平常照做，但可能忘 |
| **攔截層** | 系統層面的設定（這一節的黑名單） | 每次必生效，AI 忘了也擋得住 |

記住一句：

```text
Memory 教 agent 你的偏好；攔截層負責擋住風險。
```

---

## 4. 認識你的 Terminal（含可選的舒適化設定）

### 4.1 先搞清楚自己用甚麼 shell

打開 terminal，輸入：

```bash
echo $SHELL
```

| 顯示結果 | 意思 | 你的設定檔 |
|---|---|---|
| `/bin/zsh` | Mac 2019 年後的預設 | `~/.zshrc` |
| `/bin/bash` | 較舊系統或自選 | `~/.bashrc` |

之後所有「寫入設定檔」的步驟，照這個對應就可以。本節以 zsh 示範；bash 用戶把 `.zshrc` 換成 `.bashrc`。

**Windows 用戶**：建議用 Windows Terminal（Win11 內建，多分頁、無需安裝）。Terminal 只是「視窗」，AI 工具的能力完全一樣。安全三件套部分見每段的 Windows 備註。

### 4.2 （可選）讓 terminal 更好用：不閃爍、可回看、兩個字啟動

新手用 terminal 最常見的三個煩惱：畫面一直閃、滾輪回不了頭、每次啟動要打全名 + 自己 `cd` 入 folder。一個環境變數加一個 alias 就解決。

可以把這段貼給 AI 幫你設定（以 Claude Code 為例）：

```text
請幫我做兩個 terminal 舒適化設定。每一步先解釋會改甚麼、等我確認才執行；
修改設定檔前先備份。

1. 啟用穩定渲染模式：設定環境變數 CLAUDE_CODE_NO_FLICKER=1，
   讓畫面不閃爍、滾輪可以回看、滑鼠拖選即複製。
2. 建立快速啟動 alias：我想打 `cc` 兩個字就自動進入我的 training folder 並啟動。
   我的 folder 路徑是：[你的 AI_Agent_Training 路徑]

完成後教我怎樣驗證（type cc），並告訴我改了哪個檔案、備份在哪裏。
```

AI 實際會寫入的內容（給 AI / 導師參考）：

```bash
# 寫入 ~/.zshrc（先備份）
cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d-%H%M%S)
echo "alias cc='cd ~/你的路徑/AI_Agent_Training && CLAUDE_CODE_NO_FLICKER=1 claude'" >> ~/.zshrc
source ~/.zshrc
type cc   # 顯示 alias 內容 = 成功
```

這步完全可選——不做不影響後面任何內容。但每天用超過半小時的話，值得花這兩分鐘。

---

## 5. 逐步設定 Folder

### Step 1｜先打開你要放 agent 的地方

你可以選其中一條路線。

**路線 A｜Finder / GUI 路線**

如果你對 terminal 不熟，直接用這條路線：

1. 打開 Finder。
2. 去一個你之後容易找回的位置，例如 `Documents` 或 `Desktop`。
3. 建立一個 folder，叫 `AI_Agent_Training`。
4. 打開這個 folder。
5. 在入面建立一個 folder，叫 `Personal_AI_Assistant`。
6. 打開這個 folder。
7. 在入面建立一個 folder，叫 `sessions`。

這條路線完全可以。目標不是證明你識打 command，而是建立一個乾淨、容易交接的 agent home。

**路線 B｜Terminal 路線**

如果你可以接受複製幾行簡單 command，可以用這條路線。

先檢查你現在在哪個位置：

```bash
pwd
```

再看看這個位置裏面有甚麼：

```bash
ls
```

建立 training folder、第一位 agent folder，以及 session log folder：

```bash
mkdir -p AI_Agent_Training/Personal_AI_Assistant/sessions
```

進入 training folder：

```bash
cd AI_Agent_Training
```

檢查 folder 是否已經存在：

```bash
ls
```

如果你用 Mac，可以選擇用 Finder 打開現在這個 folder：

```bash
open .
```

如果任何 command 出現 error，不需要緊張。複製 error message，問 trainer 或你的 AI assistant 用白話解釋發生甚麼事。

---

## 6. 可直接複製的 Prompt｜叫 AI 幫你檢查 setup

建立 folder 後，你可以問你的 AI assistant：

```text
我正在參加 AI Agent 入門培訓。

我的目標是為第一位 Personal AI Assistant 建立一個安全、清晰的 folder。

目標 folder structure：

AI_Agent_Training/
└── Personal_AI_Assistant/
    └── sessions/

請幫我檢查：
1. 我的 folder structure 是否清晰。
2. 下一步應該建立哪些 files。
3. 現在 setup 有沒有任何風險。

請不要要求我貼 password、API key、私人資料、薪酬資料、員工紀錄或客戶紀錄。
請不要建議 delete、force、admin permission 或 credential 相關 command。
如果你認為需要用 command，請先解釋那個 command 會做甚麼，然後問我是否確認。
```

---

## 7. 安全 Command 規則

在 beginner training 入面，我們只需要幾類低風險 command：

| 安全類型 | 例子 | 用途 |
|---|---|---|
| 我現在在哪裏？ | `pwd` | 顯示目前位置 |
| 這裏有甚麼？ | `ls` | 列出 files 和 folders |
| 建立 folder | `mkdir -p folder_name` | 建立 folder |
| 進入 folder | `cd folder_name` | 走入指定 folder |
| 打開 folder | `open .` | 在 Mac 用 Finder 打開目前 folder |
| 我用甚麼 shell？ | `echo $SHELL` | 確認設定檔位置 |

如果你見到超出這個範圍的 command，先停一停，問清楚它會改變甚麼。

---

## 8. 停一停清單｜見到這些要先問人

如果 AI、文章或同事叫你做以下任何一類事情，先停下來問 trainer：

| 停一停信號 | 為甚麼有風險 |
|---|---|
| `sudo` | 代表 admin-level permission，可能改動電腦重要設定 |
| `rm` 或 `rm -rf` | 可能永久刪除 files |
| `force`、`--force`、`-f` | 可能跳過保護機制 |
| `reset`，尤其 hard reset | 可能令已做的內容消失 |
| `push --force` | 可能覆蓋 shared history |
| `chmod 777` | 可能把權限開得太闊 |
| 安裝不明工具 | 可能改變電腦環境 |
| 貼 password / token / API key | 會暴露登入或系統憑證 |
| 貼員工 / 客戶 / 薪酬 / 合約資料 | 會暴露敏感資料 |
| delete、overwrite、replace existing files | 可能令 work 或 memory 消失 |

Training rule：

```text
不肯定時，先問：
「這一步會改變甚麼？如果做錯，可以還原嗎？」
```

---

## 9. 安全三件套｜垃圾桶 + 黑名單 + 權限模式

### 9.1 為甚麼一層不夠，要三層

三層安全網不是三件並列的事，而是一條因果鏈——每一層都是因為上一層擋不住某種風險才存在：

```text
第一層：垃圾桶保護
AI 跟人一樣會打錯字。`rm -rf node_modules /` 多了一個空格，
就由「刪一個 folder」變成「連系統根目錄一起刪」。
所以：把 rm 改成「移入垃圾桶」，誤刪可以還原。

但垃圾桶擋不住所有東西——有些指令根本不經 rm。

第二層：危險指令黑名單
`git reset --hard` 會直接清空你未存檔的改動，
`git push --force` 會覆蓋遠端紀錄——全部不經 rm，垃圾桶救不到。
所以：把「一執行就回不來」的 20 條指令列入黑名單，
AI 連問都不會問，直接被系統拒絕。

但黑名單以外，仍有大量日常操作要決定「AI 要不要先問你」。

第三層：權限模式
逐次彈確認框太煩，全部關掉太危險。
所以：由你自己選一個確認程度，前兩層永遠在底下保護你。
```

### 9.2 為甚麼 `rm -rf` 特別危險

`rm -rf` 是 terminal 入面一類非常高風險的刪除 command。簡單理解：

| 部分 | 白話意思 |
|---|---|
| `rm` | remove，即刪除 |
| `-r` | recursive，即連 folder 入面的東西一起處理 |
| `-f` | force，即盡量不要問你、直接做 |

所以 `rm -rf` 可以變成：

```text
不用再問我，直接連 folder 入面所有東西一起刪。
```

這對 beginner 很危險，因為你未必知道自己現在在哪個 folder，也未必知道 command 會影響哪些 files。

### 9.3 我們在 training 入面的規則

在這次 training，學員不要用 terminal 做永久刪除。

如果真的要移除 file 或 folder，優先用：

- Finder / GUI 手動移到 Bin / Trash。
- 先改名，例如加上 `_old`、`_archive`、`_backup`。
- 先移入 `archive/` folder。
- 先問 AI 列出「準備移除的內容」，由人確認。

學員版安全原則：

```text
不要永久刪。
先入 Bin。
先 archive。
先讓 AI propose。
最後由人確認。
```

### 9.4 AI 應該怎樣處理 delete request

你可以把這段加到 agent 的安全指示：

```text
如果我要求你刪除、移除、清理或覆蓋任何 file：

1. 請先停下來，不要直接行動。
2. 請列出你認為要移除或改動的 files。
3. 請解釋每個 file 為甚麼可以移除。
4. 請優先建議 archive、rename 或移到 Bin / Trash，而不是永久刪除。
5. 請不要建議 `rm -rf`、force delete、hard reset 或任何不可還原的做法。
6. 等我明確確認後，才可以進入下一步。
```

### 9.5 如果 AI 建議 `rm -rf`，你應該怎樣回應

直接回覆：

```text
我不想使用 `rm -rf` 或任何不可還原的刪除方式。
請改用 beginner-safe 方法：
1. 先列出要處理的 files。
2. 建議 archive / rename / move to Bin 的做法。
3. 解釋如果做錯，怎樣還原。
```

### 9.6 課堂使用方式由 trainer 決定

完整 safe-delete setup 很有價值，可以有三種課堂用法：

| 用法 | 適合情況 |
|---|---|
| Trainer demo | 導師示範一次，學員理解三層安全網 |
| Student upload MD | 學員把這份 MD 上載給自己的 AI，叫 AI 逐步檢查和引導 |
| Guided setup | 如果時間和環境允許，學員在 trainer 陪同下完成設定 |

無論最後用哪一種，學員一定要先掌握：

```text
見到 delete / rm / rm -rf / force，就停。
真要移除，先用 Bin、archive、rename、backup。
```

### 9.7 Safe-delete Setup Prompt｜上載給 agent 跟進

你可以把以下 prompt 連同這份 MD 上載給 AI，請它用互動方式帶你設定安全三件套。

```text
請根據這份 MD 的「AI 執行區」，幫我設定安全三件套。

重要原則：
1. 全程用繁體中文和我互動。
2. 每一步都先解釋你準備做甚麼、會改動哪些 files，然後問我是否確認。
3. 如果偵測到我已有相關設定，請先告訴我現況，讓我選擇「保留 / 合併 / 跳過 / 覆蓋」。
4. 不要猜我的選擇；需要我決定時，請用清楚選項問我。
5. 完成後，用白話總結你做了甚麼、改了哪些 files、我可以怎樣驗證、備份在哪裏。

請按 Section A → B → C → D 順序執行。
```

### 9.8 AI 執行區｜安全三件套設定

以下內容不是叫你自己盲目複製。它是給 AI / trainer 讀的 setup 區（以 Claude Code 為例）。正確用法是：

```text
我把這份 MD 上載給 agent。
Agent 先解釋。
Agent 先檢查環境。
Agent 先備份。
Agent 問我確認。
我確認後，agent 才逐步執行。
```

#### Section A｜垃圾桶保護：`rm` 改成 Bin / Trash

目標：讓一般 `rm` 刪除變成「移到 Bin / Trash」，誤刪可還原。

**A-1｜先檢查是否已有 trash 工具**

```bash
type trash
```

如果顯示 `not found`，需要先安裝（需要 Homebrew）：

```bash
brew install trash
```

如果沒有 Homebrew，agent 不應該直接安裝，應先解釋 Homebrew 是甚麼（Mac 上最常用的軟件安裝工具）、會改動甚麼，再問使用者是否繼續。確認後：

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**A-2｜備份 shell 設定後，寫入 safe delete alias**

先確認 shell（見第 4.1 節），備份設定檔：

```bash
cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d-%H%M%S)
```

使用者確認後，把以下內容附加到設定檔：

```bash
cat >> ~/.zshrc << 'EOF'

# ═══════════════════════════════════════════
# 安全刪除 - rm 改用垃圾桶（可還原）
# ═══════════════════════════════════════════
alias rm='trash'
# 真的要永久刪除時用 rm! 或 /bin/rm
alias rm!='/bin/rm'
EOF
```

意思是：

| 設定 | 作用 |
|---|---|
| `alias rm='trash'` | 之後一般 `rm` 會改為移到 Bin / Trash |
| `alias rm!='/bin/rm'` | 如果真的要永久刪除，必須刻意用 `rm!` |

**A-3｜載入設定並驗證**

```bash
source ~/.zshrc
type rm
# 應顯示：rm is an alias for trash
```

安全測試只可以用臨時測試 file，不可以用真實重要 file：

```bash
touch /tmp/test-safe-delete.txt
rm /tmp/test-safe-delete.txt
# 檔案應出現在垃圾桶，而非永久消失
```

完成後，agent 應用白話總結：

```text
✅ 第一層完成：一般 rm 會進 Bin / Trash。
如果誤刪，先去 Bin / Trash 找回。
真的要永久刪除，必須刻意使用 rm!。
```

#### Section B｜危險指令黑名單

目標：把 20 條「一執行就回不來」的 command 加入 deny list。寫入後，**不管權限模式開到多大，這些指令都會被系統直接擋掉**——這就是第 3 節講的「攔截層」。

**B-1｜先確保設定 file 存在 + 備份**

```bash
test -f ~/.claude/settings.json || echo '{}' > ~/.claude/settings.json
cp ~/.claude/settings.json ~/.claude/settings.json.backup.$(date +%Y%m%d-%H%M%S)
```

**B-2｜用 jq 合併 deny 規則（自動去重複）**

為甚麼用 jq？直接手改 JSON 很容易打錯逗號或括號；jq 保證格式正確，而且規則已存在就不會重複加。

```bash
# 檢查 jq 是否已安裝（未裝先解釋再問）
type jq > /dev/null || brew install jq

# 合併 20 條 deny 規則（會自動跳過已存在的）
jq '
  .permissions = (.permissions // {}) |
  .permissions.deny = (((.permissions.deny // []) + [
    "Bash(rm -rf *)",
    "Bash(rm -fr *)",
    "Bash(rm -r *)",
    "Bash(rm -R *)",
    "Bash(rm -f *)",
    "Bash(sudo *)",
    "Bash(dd *)",
    "Bash(mkfs*)",
    "Bash(diskutil erase*)",
    "Bash(chmod 777 *)",
    "Bash(chmod -R 777 *)",
    "Bash(git reset --hard*)",
    "Bash(git push --force*)",
    "Bash(git push -f *)",
    "Bash(git clean -f*)",
    "Bash(git branch -D*)",
    "Bash(shutdown*)",
    "Bash(reboot*)",
    "Bash(: >*)",
    "Bash(truncate *)"
  ]) | unique)
' ~/.claude/settings.json > /tmp/claude-settings.new.json && mv /tmp/claude-settings.new.json ~/.claude/settings.json
```

**B-3｜驗證**

```bash
jq '.permissions.deny' ~/.claude/settings.json
# 應該列出全部 deny 規則
```

**B-4｜用白話向使用者解釋裝了甚麼**

Agent 完成後，不應只貼技術結果，要用親切語氣解釋每類**為甚麼危險**：

> ✅ 第二層裝好了！我幫你把以下「危險操作」加入黑名單，之後 AI 連問都不會問，直接被拒絕：
>
> 1. **刪除類**——各種 `rm -rf` 遞迴強制刪除（5 條變體全部擋）。一個空格打錯就可能刪走整個 folder 甚至更多。
> 2. **權限提升**——`sudo` 任何指令。它等於用管理員身份改你部電腦的核心設定，新手在 AI 工作流入面不會需要它。
> 3. **砸硬碟類**——`dd`、`mkfs`、`diskutil erase`。這些是格式化磁碟、清空磁區的指令，一跑你的資料就回不來。
> 4. **權限全開**——`chmod 777`。把檔案變成「任何人都能讀寫執行」，是典型的安全漏洞。
> 5. **Git 毀壞類**——`git reset --hard`、`git push --force`、`git clean -f`、`git branch -D`。會清空你未存檔的工作，或覆蓋遠端紀錄令進度消失。
> 6. **系統關機**——`shutdown`、`reboot`。AI 沒有任何理由關你的電腦。
> 7. **檔案清空**——`truncate`、`: >`。一秒把檔案內容變成空白。
>
> 這些都是「一執行就回不來」的指令。你看不懂沒關係——反正你本來也不會需要它們。

#### Section C｜權限模式由使用者選

目標：讓使用者自己選擇 AI 可以有多主動，不由 trainer 或 agent 替他決定。

Agent 應用互動選項框（如環境支援）提出問題，並在問題裏加一句安撫：

```text
權限模式決定 AI 每次做事前會不會先問你。你希望它有多主動？
（放心：不管你選哪個模式，前面裝好的垃圾桶和黑名單會一直在底下保護你，
最嚴重的指令永遠不會被執行。）
```

四個選項（**不替你決定，但附起步建議**）：

| 模式 | 行為 | 適合誰 |
|---|---|---|
| **Default** | AI 每個動作都先問你，確認框會很多 | 剛接觸、想先觀察 AI 到底在做甚麼的人。缺點：煩 |
| **Accept Edits** | 改檔案、寫內容不再問；跑 terminal command（安裝、刪除、連網）仍會問 | 想有效率但保留關鍵煞車的人——多數新手由這裏起步較順 |
| **Plan** | AI 先畫出完整計劃，你看完確認才動手 | 要做大改動、想先看全貌的人。提示：對話中按 `Shift+Tab` 隨時可以切入這個模式，不一定要設做預設 |
| **Bypass** | 黑名單以外甚麼都不問直接執行 | 對 AI 信任度很高、底下有完整護欄和備份的人。選這個會有額外確認步驟 |

> 給學員的一句建議（最終仍由你自己選）：如果不知道怎樣選，**Accept Edits** 是常見的起步點——改檔案不煩你，但每個 terminal command 仍有煞車；用一兩星期摸熟了，再按自己節奏調整。想最謹慎就選 Default，完全沒問題。

**C-1｜根據使用者選擇執行對應設定**

選 **Default**：

```bash
jq '.permissions = (.permissions // {}) | .permissions.defaultMode = "default"' \
  ~/.claude/settings.json > /tmp/claude-settings.new.json && \
  mv /tmp/claude-settings.new.json ~/.claude/settings.json
```

> 跟進話術：「✅ 設好了，模式是 Default。AI 做任何事都會先問你。確認框會多，但這是熟悉 AI 最快的方式——你很快會分得出『哪些問題直接同意就好』，之後想升級隨時可以改。」

選 **Accept Edits**：

```bash
jq '.permissions = (.permissions // {}) | .permissions.defaultMode = "acceptEdits"' \
  ~/.claude/settings.json > /tmp/claude-settings.new.json && \
  mv /tmp/claude-settings.new.json ~/.claude/settings.json
```

> 跟進話術：「✅ 設好了，模式是 Accept Edits。AI 改檔案、寫內容會直接做，但要跑 terminal command（裝東西、刪東西、連外網）時仍會問你一次。」

選 **Plan**：

```bash
jq '.permissions = (.permissions // {}) | .permissions.defaultMode = "plan"' \
  ~/.claude/settings.json > /tmp/claude-settings.new.json && \
  mv /tmp/claude-settings.new.json ~/.claude/settings.json
```

> 跟進話術：「✅ 設好了，模式是 Plan。AI 只會先規劃、不會動手，等你看完計劃確認才執行。提示：對話中按 `Shift+Tab` 隨時可以切換模式。」

選 **Bypass** → **必須再確認一次**（不是嚇人，是讓使用者真正理解）：

```text
選 Bypass 的話，AI 除了黑名單那 20 條指令之外，其他都會自己判斷直接執行，
不再彈任何確認框。垃圾桶 + 黑名單會幫你擋住最嚴重的事情，
但 AI 在它們範圍以外做的每一個動作（改檔案、裝套件、發請求……）你都不會事先看到。
你還是要選這個嗎？

1. 確定，我要 Bypass（我理解風險）
2. 還是改用 Accept Edits（我再想想）
```

二次確認仍選 Bypass 才執行：

```bash
jq '.permissions = (.permissions // {}) | .permissions.defaultMode = "bypassPermissions"' \
  ~/.claude/settings.json > /tmp/claude-settings.new.json && \
  mv /tmp/claude-settings.new.json ~/.claude/settings.json
```

> 跟進話術：「✅ 設好了，模式是 Bypass。記住：20 條黑名單會一直守住，但其他操作 AI 會自己決定。之後覺得太進取，隨時可以改回其他模式。」

#### Section D｜完成後總結 + 兩件最重要的事

三層都裝好後，agent 必須回報：

```text
🎉 安全三件套設定結果：

1. 垃圾桶保護：完成 / 未完成（原因）—— rm 已改為入 Bin / Trash
2. 危險指令黑名單：完成 / 未完成 —— 已加入 20 條「回不來」指令
3. 權限模式：使用者選擇了 [模式]
4. 改動了哪些設定 files
5. 備份 files 在哪裏（~/.zshrc.backup.* / ~/.claude/settings.json.backup.*）
```

然後一定要講以下兩課：

> **第一：請重新開一個新對話，設定才會生效。** 現在這個對話不會變，下次開啟就按新規則跑。
>
> **第二：之後遇到確認框，想「一勞永逸」應該點做？** 確認框通常有「Yes, and don't ask again」這個選項。按下去等於告訴系統：「這類指令以後可以自己決定，不用問我。」這就是你的**個人白名單**——用得越久，AI 越懂你，確認框自然越來越少。
>
> **你不需要為了躲確認框就跳去 Bypass。讓白名單慢慢長大，才是正確的練功方式。**
>
> 如果之後想改設定：直接編輯 `~/.claude/settings.json`，或叫 AI 幫你改。改壞了就用備份檔還原（`~/.claude/settings.json.backup.*`）。

---

## 10. 三層安全網（工作習慣版）

上一節的三件套是**系統層**的保護。每次 AI 幫你處理 files 或 setup，還有三層**習慣層**的保護：

### Layer 1｜先保留、再更新

在 replace 任何內容之前：

- 先保留原本版本。
- 優先新增一個 section，而不是直接覆蓋。
- 有需要時，用日期標記新紀錄。
- 要求 AI 先提出修改建議，不要直接改。

安全說法：

```text
請先提出更新建議，不要覆蓋原文。
如果有內容需要修改，請同時列出原本版本和建議版本。
```

### Layer 2｜危險動作先停

Agent 不應該把 delete、force、admin、credential、sensitive data 當成普通 beginner step。

安全說法：

```text
如果你的建議涉及刪除、覆蓋、credential、admin permission 或敏感資料，請先停下來問我。
```

### Layer 3｜人類確認權

不是所有 action 都應該交給 AI 自己做。

| 權限等級 | AI 可以做嗎？ | 例子 |
|---|---|---|
| Green | 可以 draft 或 suggest | 解釋 folder structure、草擬 profile、整理 notes |
| Yellow | 先 propose，再等人確認 | 更新 memory、重整 folder、修改 profile、調整 checklist |
| Red | 必須由人決定 | 刪除 files、發送訊息、批准政策、處理薪酬 / 法律 / 紀律 / credential 資料 |

實用規則：

```text
AI 可以準備；人類負責確認；高風險 action 要等。
```

---

## 11. Credential 鐵律

這條規則由今日開始用到永遠：

```text
Password、API key、token——永遠不貼入對話。
```

| 規則 | 原因 |
|---|---|
| 不貼 key 入對話 | 對話會留紀錄，貼一次等於永久寫入，刪不到 |
| AI 要求你貼 key → 拒絕 | 正確做法是 key 放在指定設定檔，AI 只引用 key 的**名稱**，不引用值 |
| key 不寫入任何 .md / 筆記 / commit | files 同對話一樣會留底 |
| 外部服務登入授權由你親手操作 | 登入過程不經 AI，密碼不離開你手 |

---

## 12. Data Boundary Checklist｜哪些資料可以用，哪些不可以貼

這次 training 只用 fake、sample 或 anonymized data。

### 可以使用

- 假的 FAQ examples。
- 公開公司資料。
- 已批准可分享的 SOP text。
- 已匿名化的 examples，例如移除姓名、email、薪酬、身份資料。
- 你自己創作的 sample cases。
- 沒有個人身份資料的情境摘要。

### 不要貼上

- Passwords。
- API keys。
- Login links。
- Private tokens。
- 完整員工紀錄。
- 有姓名和聯絡資料的 candidate resumes。
- 薪酬、bonus、payroll、MPF、銀行、稅務或身份證資料。
- 法律、紀律、grievance、medical 或 investigation details。
- 客戶個人資料。
- 從 HRIS、CRM、ERP、payroll 或 email system 直接 export 出來的 raw data。

如果你想用真實例子，先把它改成安全 sample。

例子：

```text
不安全：
「Chan Tai Man，Senior Sales Manager，月薪 HKD...，收到 warning letter...」

比較安全：
「一位 senior sales employee 在收到 performance warning 後，查詢 annual leave rules。請只根據已批准的 leave policy 回答。」
```

---

## 13. 將這份 MD 上載給你的 agent

之後當你的 Personal AI Assistant 建立好，你可以上載這份 file，然後問它：

```text
請閱讀這份 Terminal Setup & Safe Start guide。

你的任務是協助我安全建立 AI agent folder。

請你：
1. 用 beginner-friendly 的語言解釋 setup。
2. 幫我檢查 folder 是否正確。
3. 在任何 risky command 或 sensitive data request 前提醒我。
4. 在建議 overwrite、delete、force、credential 或 admin action 前，先問我確認。
5. 如果我卡住，請提供 Finder / GUI fallback。

不要把這件事變成工程課。請保持 practical、清晰、安全。
```

---

## 14. 常見問題

**Q：裝了三件套，會影響 AI 正常做事嗎？**
不會。AI 執行的 `rm` 會變成移到垃圾桶——這正是我們想要的。黑名單只擋「一執行就回不來」的指令，正常工作完全不受影響。

**Q：我用 bash，不是 zsh？**
把 `~/.zshrc` 換成 `~/.bashrc`，其他一樣。`~/.claude/settings.json` 的路徑不變。

**Q：我用 Windows？**
PowerShell 的刪除指令（`Remove-Item`）行為不同，垃圾桶 alias 那部分不適用。兩個選擇：① 用 WSL（Windows Subsystem for Linux）再照本節設定；② 至少完成 Section B 黑名單 + Section C 權限模式（這兩部分跨平台一樣）。Terminal 建議用 Windows Terminal（Win11 內建）。

**Q：裝完之後想改設定怎麼辦？**
直接編輯 `~/.claude/settings.json`，或叫 AI 幫你改。改壞了用備份檔還原：`~/.claude/settings.json.backup.*`。

**Q：確認框太多很煩，可以全部關掉嗎？**
不要急着跳去 Bypass。用「Yes, and don't ask again」逐個養大你的個人白名單——既省時，又不會失去保護。

---

## 15. 完成 Checklist

進入下一節之前，先確認：

- [ ] 我找得到自己的 `AI_Agent_Training` folder。
- [ ] 我有一個 `Personal_AI_Assistant` folder，入面有 `sessions` folder。
- [ ] 我知道自己用 zsh 還是 bash、設定檔在哪裏。
- [ ] 我知道安全 command：`pwd`、`ls`、`mkdir -p`、`cd`、`open .`。
- [ ] 我知道 stop signals：admin、delete、force、reset、credential、sensitive data。
- [ ] 安全三件套已裝好：垃圾桶保護、20 條黑名單、我自己選的權限模式。
- [ ] 我講得出三層因果鏈：垃圾桶擋誤刪 → 黑名單擋不經 rm 的毀滅指令 → 權限模式管日常確認。
- [ ] 我知道「教 AI 不要做」會忘，「讓 AI 做不到」（攔截層）才可靠。
- [ ] 我知道遇到確認框用「don't ask again」養白名單，不跳 Bypass。
- [ ] 我知道不要用 `rm -rf`；要移除內容，先用 Bin、archive、rename 或 backup。
- [ ] 我知道 credential 鐵律：key 永遠不貼入對話、不寫入 files。
- [ ] 我知道 AI 可以 draft，但高風險 action 要人類確認。
- [ ] 我知道 training example 不應該貼真實私人或公司敏感資料。

全部完成後，就可以進入下一節（Step 2）：建立 AI Agent Training Home，正式為你的第一位 agent 設置 workspace。
