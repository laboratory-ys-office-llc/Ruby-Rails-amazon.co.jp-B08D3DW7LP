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

## 2-2 モデルを扱う

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

### 2-2-3 モデルを通じてデータを更新する

`Book` オブジェクトを作成してデータベースに保存する例

```ruby
Book.create(
  name: "Rails Book",
  published_on: Time.parse("20230918").ago(2.months),
  price: 2980,
  publisher: Publisher.find(1)
)
```

バリデーションエラーを試す

```ruby
irb(main):047:0> book.name = "a" * 30
=> "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
irb(main):048:0> book.price = 1000
=> 1000
irb(main):049:0> book.publisher = Publisher.find(1)
  Publisher Load (0.3ms)  SELECT "publishers".* FROM "publishers" WHERE "publishers"."id" = ? LIMIT ?  [["id", 1], ["LIMIT", 1]]
=>
#<Publisher:0x00007f4bb9312c50
...
irb(main):050:0> book.save
=> false
irb(main):051:0> book.errors
=> #<ActiveModel::Errors [#<ActiveModel::Error attribute=name, type=too_long, options={:count=>25}>]>
```

[Active Record バリデーション](https://railsguides.jp/active_record_validations.html)

### 2-2-4 コールバックによる制御

コールバックの基本的な使い方

単体でのテスト

```ruby
irb(main):007:0> book.send(:add_lovely_to_cat)
irb(main):008:0> puts book.name
We Love lovely Cat
=> nil
```

レコードの作成実例

`before_validation` で文字列の変換

````ruby
irb(main):009:0>
irb(main):010:1* Book.create(
irb(main):011:1*   name: "We Love Cat",
irb(main):012:1*   price: 999,
irb(main):013:1*   publisher: Publisher.find(1),
irb(main):014:0> )
  Publisher Load (0.1ms)  SELECT "publishers".* FROM "publishers" WHERE "publishers"."id" = ? LIMIT ?  [["id", 1], ["LIMIT", 1]]
  TRANSACTION (0.0ms)  begin transaction
  Book Create (0.2ms)  INSERT INTO "books" ("name", "published_on", "price", "created_at", "updated_at", "publisher_id") VALUES (?, ?, ?, ?, ?, ?)  [["name", "We Love lovely Cat"], ["published_on", nil], ["price", 999], ["created_at", "2023-09-18 02:12:29.555663"], ["updated_at", "2023-09-18 02:12:29.555663"], ["publisher_id", 1]]
  TRANSACTION (9.5ms)  commit transaction
=>
#<Book:0x00007f602cd83748
 id: 6,
 name: "We Love lovely Cat",
 published_on: nil,
 price: 999,
 created_at: Mon, 18 Sep 2023 02:12:29.555663000 UTC +00:00,
 updated_at: Mon, 18 Sep 2023 02:12:29.555663000 UTC +00:00,
 publisher_id: 1>
irb(main):015:0> reload!
Reloading...
=> true

`after_destroy` コールバックで Rails ログを出力（ `ENV=development` ）

```ruby
irb(main):016:0> book = Book.last
  Book Load (0.1ms)  SELECT "books".* FROM "books" ORDER BY "books"."id" DESC LIMIT ?  [["LIMIT", 1]]
=>
#<Book:0x00007f6027ef04f0
...
irb(main):017:0> book.destroy
  TRANSACTION (0.1ms)  begin transaction
  Book Destroy (0.2ms)  DELETE FROM "books" WHERE "books"."id" = ?  [["id", 6]]
Book is deleted: {"id"=>6, "name"=>"We Love lovely Cat", "published_on"=>nil, "price"=>999, "created_at"=>Mon, 18 Sep 2023 02:12:29.555663000 UTC +00:00, "updated_at"=>Mon, 18 Sep 2023 02:12:29.555663000 UTC +00:00, "publisher_id"=>1}
  TRANSACTION (18.2ms)  commit transaction
=>
#<Book:0x00007f6027ef04f0
 id: 6,
 name: "We Love lovely Cat",
 published_on: nil,
 price: 999,
 created_at: Mon, 18 Sep 2023 02:12:29.555663000 UTC +00:00,
 updated_at: Mon, 18 Sep 2023 02:12:29.555663000 UTC +00:00,
 publisher_id: 1>
````

Development ログ
`tail -n10 log/development.log`

```ruby
Book Load (0.2ms)  SELECT "books".* FROM "books" WHERE "books"."id" = ? LIMIT ?  [["id", 5], ["LIMIT", 1]]
Publisher Load (0.1ms)  SELECT "publishers".* FROM "publishers" WHERE "publishers"."id" = ? LIMIT ?  [["id", 1], ["LIMIT", 1]]
TRANSACTION (0.0ms)  begin transaction
Book Create (0.2ms)  INSERT INTO "books" ("name", "published_on", "price", "created_at", "updated_at", "publisher_id") VALUES (?, ?, ?, ?, ?, ?)  [["name", "We Love lovely Cat"], ["published_on", nil], ["price", 999], ["created_at", "2023-09-18 02:12:29.555663"], ["updated_at", "2023-09-18 02:12:29.555663"], ["publisher_id", 1]]
TRANSACTION (9.5ms)  commit transaction
Book Load (0.1ms)  SELECT "books".* FROM "books" ORDER BY "books"."id" DESC LIMIT ?  [["LIMIT", 1]]
TRANSACTION (0.1ms)  begin transaction
Book Destroy (0.2ms)  DELETE FROM "books" WHERE "books"."id" = ?  [["id", 6]]
Book is deleted: {"id"=>6, "name"=>"We Love lovely Cat", "published_on"=>nil, "price"=>999, "created_at"=>Mon, 18 Sep 2023 02:12:29.555663000 UTC +00:00, "updated_at"=>Mon, 18 Sep 2023 02:12:29.555663000 UTC +00:00, "publisher_id"=>1}
TRANSACTION (18.2ms)  commit transaction
```

バリデーションされないメソッド例

| メソッド名          | 説明                                                                       |
| ------------------- | -------------------------------------------------------------------------- |
| `increment`         | 属性の値を増やす                                                           |
| `decrement`         | 属性の値を減らす                                                           |
| `increment_counter` | 指定されたカウンターを増やす                                               |
| `decrement_counter` | 指定されたカウンターを減らす                                               |
| `toggle`            | boolean 属性の値を反転させる                                               |
| `update_column`     | 一つの属性を更新し、バリデーションやコールバックをスキップする             |
| `update_columns`    | 複数の属性を一度に更新し、バリデーションやコールバックをスキップする       |
| `update_all`        | 一致する全てのレコードを更新し、バリデーションやコールバックをスキップする |
| `delete`            | レコードをデータベースから削除するが、`destroy`コールバックは実行されない  |
| `delete_all`        | 条件に一致するレコードをデータベースからすべて削除する                     |

### 2-2-5 ActiveRecord::Enum で列挙型を扱う

- ActiveRecord::Enum の導入

```shell
bin/rails g migration AddSalesStatusToBooks sales_status:integer
bin/rails db:migrate
```

```text
bin/rails db:migrate
      invoke  active_record
      create    db/migrate/20230918025045_add_sales_status_to_books.rb
== 20230918025045 AddSalesStatusToBooks: migrating ============================
-- add_column(:books, :sales_status, :integer)
   -> 0.0012s
== 20230918025045 AddSalesStatusToBooks: migrated (0.0012s) ===================
```

Enum を追加した実装例

```ruby
# 予約中の書籍を作成
Book.create(name: "Reservation Book", price: 1000, publisher: Publisher.find(1), sales_status: :reservation)

# 現在発売中の書籍を作成
Book.create(name: "On Sale Book", price: 1500, publisher: Publisher.find(1), sales_status: :now_on_sale)

# 絶版の書籍を作成
Book.create(name: "Out of Print Book", price: 500, publisher: Publisher.find(1), sales_status: :end_of_print)
```

Enum で定義された状態の確認例

```ruby
irb(main):010:0> book = Book.last
  Book Load (0.1ms)  SELECT "books".* FROM "books" ORDER BY "books"."id" DESC LIMIT ?  [["LIMIT", 1]]
=>
#<Book:0x00007f3c64c81f70
...
irb(main):011:0> book.now_on_sale?
=> false
irb(main):012:0> book.end_of_print?
=> true
```

データベースの実際の保存された値を確認する

```ruby
irb(main):013:0> book.sales_status_before_type_cast
=> 2
```

Enum の定義を確認する

```ruby
irb(main):015:0> Book.sales_statuses
=> {"reservation"=>0, "now_on_sale"=>1, "end_of_print"=>2}
```

[ActiveRecord::Enum と enumerize](https://github.com/brainspec/enumerize)
