# Vexapion

Vexapionは、仮想(暗号)通貨取引所のAPIを簡単に使えるようにしたAPIラッパーです。

現在ほぼ問題なく利用可能なのはCoincheck, Zaifのみです。

Bitflyer, Poloniexも一応利用可能ですが、マージン取引、特殊取引などに関連する関数はテストされていません。


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'vexapion'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install vexapion

## Usage

例:zaifの場合

クラスファイルを読み込みます。
```ruby
require 'vexapion/zaif'
```

クラスの初期化をします。
```ruby
zapi = Vexapion::Zaif.new(APIkey, secretkey)
```

扱いたいペアを指定します
```ruby
pair = 'btc_jpy'
```

tickerを取得します
```ruby
tick = zapi.ticker(pair)
ask = tick['ask'].to_i
bid = tick['bid'].to_i
last = tick['last'].to_i
```


(すぐ売買に利用可能な)残高を取得します
```ruby
res = zapi.getinfo2
balance = res['return']['funds']
jpy_available = balance['jpy']
btc_available = balance['btc']
```

 

売買します
```ruby
zapi.trade(pair, 'sell', rate, amount)
zapi.trade(pair, 'buy', rate, amount)
```

等のように使います。

各取引所クラスでメソッド名が異なるため、各取引所のAPIドキュメントをご覧ください。

また、各メソッドの返り値はAPIから返って来たものをHash化しただけになりますので、詳しくは http://vexapion.fuyuton.net にある各取引所のAPIドキュメントをご覧ください。


## 例外
各メソッドはHTTPを使って取引所と通信をします。そのため接続できなかった場合などにエラーが返ってくることがあります。

Vexapionには、4つの例外があります。

Vexapion::RetryException は、サーバー側にエラーが発生し、接続が出来ないまたは、リクエストが通ったかどうか定かでない状態になったときに発生します。

(当初Vexapion側で自動的に再接続処理をする予定で付けていた名残でRetryExceptionという名前になっています。将来的に変更される可能性があります)

Vexapion::Warning は、場合によってはアプリ側で無視出来るかもしれないエラーになります。

Vexapion::Error は、アプリ側(稀にVexapion自体)の修正が必要なエラーになります。

Vexapion::Fatal は、Vexapion自体の修正が必要なエラーになると思います。

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/fuyuton/vexapion.

