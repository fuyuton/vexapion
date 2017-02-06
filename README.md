# Vexapion

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/vexapion`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

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

まず、クラスの初期化をします。

zapi = Vexapion::API::Zaif.new(API鍵, 秘密鍵)

扱いたいペアを指定します

pair = 'btc_jpy'

tickerを取得します

tick = zapi.ticker(pair)

ask = tick['ask']

bid = tick['bid']


残高を取得します

res = zapi.balance

balance = res['return']['funds']

jpy_available = balance['jpy']

btc_available = balance['btc']



売買します

puts zapi.sell(pair, bid, amount)

puts zapi.buy(pair, ask, amount)

等のように使います。

各取引所クラスでメソッド名が異なるため、各取引所のAPIドキュメントをご覧ください。

また、各メソッドの返り値はAPIから返って来たものをHash化しただけになりますので、詳しくは各取引所のAPIドキュメントをご覧ください。


例外。
各メソッドはHTTPを使って取引所と通信をします。そのため接続できなかった場合などにエラーが返ってくることがあります。

Vexapionでは、その際のHTTPステータスなどを使っていくつかのランクに分けた例外が発生します。


大まかに分けて6つの例外があります。

Vexapion::API::RequestFailed は、APIリクエストが失敗したことが明らかな場合に発生します。

Vexapion::API::SocketError は、HTTPでの接続が出来ないときに発生します。

Vexapion::API::RetryException は、サーバー側にエラーが発生し、リクエストが通ったかどうか定かでない状態になったときに発生します。

当初Vexapion側で自動的に再接続処理をする予定で付けていた名残でこの名前になっています。将来的に変更される可能性があります。

Vexapion::API::Warning は、場合によってはアプリ側で無視出来るかもしれないエラーになります。

Vexapion::API::Error は、アプリ側で修正が必要なエラーになります。

Vexapion::API::Fatal は、Vexapion自体の修正が必要なエラーになると思います。

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/vexapion.

