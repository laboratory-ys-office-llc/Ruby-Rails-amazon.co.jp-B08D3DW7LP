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

- 多対多のリレーションを実現する

中間モデルを作成する

```bash
bin/rails g model BookAuthor book:references author:references
bin/rails db:migrate
```

操作実例

```ruby
$ bin/rails c
Loading development environment (Rails 7.0.7.2)
irb(main):001:0> matz = Author.create(name: "Matsumoto Yukihiro", penname: "Matz")
  TRANSACTION (0.0ms)  begin transaction
  Author Create (0.2ms)  INSERT INTO "authors" ("name", "penname", "created_at", "updated_at") VALUES (?, ?, ?, ?)  [["name", "Matsumoto Yukihiro"], ["penname", "Matz"], ["created_at", "2023-08-26 08:32:15.945977"], ["updated_at", "2023-08-26 08:32:15.945977"]]
  TRANSACTION (18.3ms)  commit transaction
=>
#<Author:0x00007f4679796d98
...
irb(main):002:0> dhh = Author.create(name: "David Heinemeir Hansson", penname: "DHH")
  TRANSACTION (0.1ms)  begin transaction
  Author Create (0.5ms)  INSERT INTO "authors" ("name", "penname", "created_at", "updated_at") VALUES (?, ?, ?, ?)  [["name", "David Heinemeir Hansson"], ["penname", "DHH"], ["created_at", "2023-08-26 08:32:50.703370"], ["updated_at", "2023-08-26 08:32:50.703370"]]
  TRANSACTION (19.0ms)  commit transaction
=>
#<Author:0x00007f4678ba66c8
...
irb(main):003:0> matz.books << Book.find(1)
  Book Load (0.1ms)  SELECT "books".* FROM "books" WHERE "books"."id" = ? LIMIT ?  [["id", 1], ["LIMIT", 1]]
  TRANSACTION (0.0ms)  begin transaction
  BookAuthor Create (0.2ms)  INSERT INTO "book_authors" ("book_id", "author_id", "created_at", "updated_at") VALUES (?, ?, ?, ?)  [["book_id", 1], ["author_id", 1], ["created_at", "2023-08-26 08:33:13.433370"], ["updated_at", "2023-08-26 08:33:13.433370"]]
  TRANSACTION (9.8ms)  commit transaction
  Book Load (0.1ms)  SELECT "books".* FROM "books" INNER JOIN "book_authors" ON "books"."id" = "book_authors"."book_id" WHERE "book_authors"."author_id" = ?  [["author_id", 1]]
=>
[#<Book:0x00007f467978e170
  id: 1,
  name: "Book 1",
  published_on: Sat, 26 Aug 2023,
  price: 1000,
  created_at: Sat, 26 Aug 2023 08:06:39.290568000 UTC +00:00,
  updated_at: Sat, 26 Aug 2023 08:06:39.290568000 UTC +00:00,
  publisher_id: 1>]
irb(main):004:0> matz.books << Book.find(2)
  Book Load (0.2ms)  SELECT "books".* FROM "books" WHERE "books"."id" = ? LIMIT ?  [["id", 2], ["LIMIT", 1]]
  TRANSACTION (0.1ms)  begin transaction
  BookAuthor Create (0.5ms)  INSERT INTO "book_authors" ("book_id", "author_id", "created_at", "updated_at") VALUES (?, ?, ?, ?)  [["book_id", 2], ["author_id", 1], ["created_at", "2023-08-26 08:33:24.469546"], ["updated_at", "2023-08-26 08:33:24.469546"]]
  TRANSACTION (18.6ms)  commit transaction
=>
[#<Book:0x00007f467978e170
  id: 1,
  name: "Book 1",
  published_on: Sat, 26 Aug 2023,
  price: 1000,
  created_at: Sat, 26 Aug 2023 08:06:39.290568000 UTC +00:00,
  updated_at: Sat, 26 Aug 2023 08:06:39.290568000 UTC +00:00,
  publisher_id: 1>,
 #<Book:0x00007f4679620518
  id: 2,
  name: "Book 2",
  published_on: Sat, 26 Aug 2023,
  price: 2000,
  created_at: Sat, 26 Aug 2023 08:07:14.746037000 UTC +00:00,
  updated_at: Sat, 26 Aug 2023 08:07:14.746037000 UTC +00:00,
  publisher_id: 1>]
irb(main):005:0> matz.reload.books.count
  Author Load (0.3ms)  SELECT "authors".* FROM "authors" WHERE "authors"."id" = ? LIMIT ?  [["id", 1], ["LIMIT", 1]]
  Book Count (0.1ms)  SELECT COUNT(*) FROM "books" INNER JOIN "book_authors" ON "books"."id" = "book_authors"."book_id" WHERE "book_authors"."author_id" = ?  [["author_id", 1]]
=> 2
irb(main):006:0> book = Book.find(1)
  Book Load (0.2ms)  SELECT "books".* FROM "books" WHERE "books"."id" = ? LIMIT ?  [["id", 1], ["LIMIT", 1]]
=>
#<Book:0x00007f4678065cc8
...
irb(main):008:0> book.authors << dhh
  TRANSACTION (0.0ms)  begin transaction
  BookAuthor Create (0.2ms)  INSERT INTO "book_authors" ("book_id", "author_id", "created_at", "updated_at") VALUES (?, ?, ?, ?)  [["book_id", 1], ["author_id", 2], ["created_at", "2023-08-26 08:35:07.616127"], ["updated_at", "2023-08-26 08:35:07.616127"]]
  TRANSACTION (18.4ms)  commit transaction
  Author Load (0.1ms)  SELECT "authors".* FROM "authors" INNER JOIN "book_authors" ON "authors"."id" = "book_authors"."author_id" WHERE "book_authors"."book_id" = ?  [["book_id", 1]]
=>
[#<Author:0x00007f467813cc50
  id: 1,
  name: "Matsumoto Yukihiro",
  penname: "Matz",
  created_at: Sat, 26 Aug 2023 08:32:15.945977000 UTC +00:00,
  updated_at: Sat, 26 Aug 2023 08:32:15.945977000 UTC +00:00>,
 #<Author:0x00007f4678ba66c8
  id: 2,
  name: "David Heinemeir Hansson",
  penname: "DHH",
  created_at: Sat, 26 Aug 2023 08:32:50.703370000 UTC +00:00,
  updated_at: Sat, 26 Aug 2023 08:32:50.703370000 UTC +00:00>]
irb(main):009:0> book.reload.authors.pluck(:name)
  Book Load (0.2ms)  SELECT "books".* FROM "books" WHERE "books"."id" = ? LIMIT ?  [["id", 1], ["LIMIT", 1]]
  Author Pluck (0.7ms)  SELECT "authors"."name" FROM "authors" INNER JOIN "book_authors" ON "authors"."id" = "book_authors"."author_id" WHERE "book_authors"."book_id" = ?  [["book_id", 1]]
=> ["Matsumoto Yukihiro", "David Heinemeir Hansson"]
```

### 2-2-2 モデル同士のリレーション
