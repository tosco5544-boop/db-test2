# 全国マーケティング旅

都道府県の地図で「行った（赤）」「次に行く（青）」を見せるLPです。
色は Cloudflare D1 のデータベースに保存され、編集ページで県をタップすると切り替わります。

## フォルダの中身

```
marketing-trip/
├─ wrangler.toml            … Cloudflare の設定（要編集）
├─ package.json
├─ src/index.js             … Worker（色の読み込み・切り替えのAPI）
├─ migrations/              … データベースの作成SQL
└─ public/
   ├─ index.html            … LP
   ├─ admin/index.html      … 編集ページ（/admin）
   ├─ css/style.css
   ├─ js/map.js             … 地図の描画（県名つき）
   ├─ js/data.js            … 色データの読み込み
   ├─ js/lp.js              … LPの動き
   ├─ js/admin.js           … 編集ページの動き
   └─ data/checked.js       … APIにつながらないときの予備データ
```

## 初めて動かすまで

### 1. wrangler.toml を書き換える
- `name` … ダッシュボードにある Worker の名前
- `database_id` … D1 のデータベース画面に出ている ID

### 2. 編集できる人を登録する
D1 の「Console」で、自分のメールアドレスを登録します（複数人なら1人ずつ）。

```sql
INSERT INTO editors (name, email) VALUES ('自分の名前', 'メールアドレス');
```

### 3. 編集ページを Cloudflare Access で守る
1. Cloudflare の「Zero Trust」→「Access」→「Applications」→「Add an application」→「Self-hosted」
2. サイトのドメインで、パス `admin` と `api/admin` の2つを登録する
3. ポリシーで「Emails」に、手順2で登録したメールアドレスを入れる
4. 作成後に表示される「Application Audience (AUD) Tag」を `wrangler.toml` の `ACCESS_AUD` に入れる
5. Zero Trust の設定画面にあるチーム名を `ACCESS_TEAM_DOMAIN` に入れる（例：`https://myteam.cloudflareaccess.com`）

workers.dev のURLで使う場合は、Worker の設定で workers.dev に Cloudflare Access を有効にしてください。

### 4. GitHub に push する
push すると自動でデプロイされます。

- LP：`https://（サイトのURL）/`
- 編集ページ：`https://（サイトのURL）/admin`

## 色の切り替え方
1. 編集ページを開くと、Access のログイン画面が出ます。登録したメールアドレスでログインします
2. 上の「行った／次に行く／まだ」から塗る色を選びます
3. 地図か一覧の県をタップすると、すぐ保存されてLPに反映されます
   （同じ色の県をもう一度タップすると「まだ」に戻ります）

色そのもの（赤・青）を変えたいときは、D1 の Console で次のように実行します。

```sql
UPDATE statuses SET color = '#e60033' WHERE code = 'visited';
```

## データベースについて
- テーブルはすでに D1 の Console で作成済みなら、`migrations` を適用する必要はありません
- 新しく作るときは `npx wrangler d1 migrations apply marketing-trip --remote`
- 切り替えた記録は `state_history` テーブルに残ります
