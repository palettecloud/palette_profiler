# PaletteProfiler

Rubyのアプリケーションコード用プロファイラ詰め合わせです。

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'palette_profiler'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install palette_profiler

## Usage

- [ObjectCounter](https://github.com/palettecloud/palette_profiler#objectcounter)
- [LineDetector](https://github.com/palettecloud/palette_profiler#linedetector)

### ObjectCounter

オブジェクト数の変化をクラスごとに集計します。メモリリーク調査の取っ掛かりに便利です。
オブジェクト数の集計前に毎回GCが実行されるため、GCで回収できないオブジェクトのみ計上されます。

```ruby
arr = []

object_counter = PaletteProfiler::ObjectCounter.new

GC.start
GC.start
GC.start

5.times do |i|
  arr << {}
  object_counter.record "iter-#{i}"
end

object_counter.output 'object_counts.csv'

```

結果はCSV形式で出力されます。

```csv
,iter-0,iter-1,iter-2,iter-3,iter-4
String,20998,20982,20982,20982,20984
Regexp,333,333,333,333,333
Hash,264,265,266,267,268
...,...,...,...,...,...

```

### LineDetector

以下の2つの機能が含まれています。


| 機能名 | 説明 |
|:-:|:--|
| 利用メモリサイズ集計（GC世代ごと）   | メモリサイズを、オブジェクトが生成された際のGC実行回数ごとに計算します |
| 利用メモリサイズ集計（コード行ごと） | メモリサイズを、オブジェクトが生成されたコード行ごとに計算します       |

「GC世代ごと」の結果を見ることでメモリリークが発生しているかどうかが判定できます。
「コード行ごと」の結果は、原因特定に役立ちます。
どちらもオブジェクト数の集計前に毎回GCが実行されるため、GCで回収できないオブジェクトのみ計上されます。

```ruby
line_detector = PaletteProfiler::LineDetector.new

line_detector.start

str1 = 'a' * 5000
GC.start
str2 = 'a' * 5000
GC.start
str3 = 'a' * 5000

line_detector.stop

line_detector.output 'memsize_by_line.csv'
```

結果はCSV形式で出力されます。

```csv
GC Generation,Memory Size (bytes)
24,5161
25,5121
26,6089

Source Location,Memory Size (bytes)
(irb):5,5041
(irb):7,5041
(irb):9,5041
...,...
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. ~~To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).~~ →あとでタグ打ち用のスクリプト用意する

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/palette_profiler.
