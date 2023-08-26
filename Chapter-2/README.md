# 2 章 - Ruby on Rails と MVC

## 2-1 MVC アーキテクチャ

### 2-1-1 題材とするアプリケーションを準備する

本屋さんの書籍管理を行う Web アプリケーション

#### 実行コマンド

```bash
rails new book_admin \
  --skip-action-mailer \
  --skip-action-mailbox \
  --skip-action-text \
  --skip-active-storage \
  --skip-action-cable
```

#### Rails アプリケーションの生成に関するオプションの説明

| オプション              | 説明                                                                 |
| :---------------------- | :------------------------------------------------------------------- |
| `rails new book_admin`  | 新しい Rails アプリケーション「book_admin」を生成いたします。        |
| `--skip-action-mailer`  | ActionMailer に関連するファイルや設定を生成しないようにいたします。  |
| `--skip-action-mailbox` | ActionMailbox に関連するファイルや設定を生成しないようにいたします。 |
| `--skip-action-text`    | ActionText に関連するファイルや設定を生成しないようにいたします。    |
| `--skip-active-storage` | ActiveStorage に関連するファイルや設定を生成しないようにいたします。 |
| `--skip-action-cable`   | ActionCable に関連するファイルや設定を生成しないようにいたします。   |

これらのオプションを使用することで、特定の機能に関連するファイルや設定をスキップして、Rails アプリケーションを生成することができます。

### 2-1-2 モデルの基礎と考え方

- ActiveRecord でモデルを実装する

```bash
bin/rails g model Book \
name:string \
published_on:date \
price:integer
```

- マイグレーション

```bash
bin/rails db:create
bin/rails db:migrate
```

### 2-2-2 モデル同士のリレーション

- モデルに対してリレーションを作成する

```bash
bin/rails g model Publisher name:string address:text
bin/rails g model Author name:string penname:string
bin/rails db:migrate
```

- モデル同士のリレーションを作成する

```bash
bin/rails g migration AddPublisherIdToBooks publisher:references
```
