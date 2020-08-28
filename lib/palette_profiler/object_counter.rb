require 'tempfile'
require 'json'

module PaletteProfiler
  class ObjectCounter
    def initialize
      create_tmpfile
    end

    def record(tag)
      # @todo verbose option
      STDOUT.puts "count objects: tag=#{tag}"

      # GCできなかったオブジェクトのみをカウントする
      GC.start
      GC.start
      GC.start
      objects_count = ObjectSpace.each_object.each_with_object(Hash.new {|hash, key| hash[key] = 0 }) {|x, h| h[x.class.to_s] += 1 }
      tmpfile.puts "TAG(#{tag}):COUNT(#{objects_count.to_json})"
    end

    def output(path)
      tags = []
      objects_counts = []
      tmpfile.rewind
      tmpfile.readlines(chomp: true).each do |line|
        next if line.nil? || line == ''
        t, c = /^TAG\((.*)\):COUNT\((.*)\)$/.match(line).to_a.values_at(1, 2)
        tags << t
        objects_counts << JSON.parse(c)
      end

      File.open(path, 'w') do |file|
        file.puts ([''] + tags).join(',')

        result = Hash.new {|hash, key| hash[key] = [] }
        objects_counts.each do |objects_count|
          (result.keys | objects_count.keys).each do |k|
            result[k] << objects_count[k]
          end
        end

        result.to_a.each do |arr|
          file.puts arr.flatten.join(',')
        end
      end

      # tmpfile閉じる
      tmpfile.close
    end

    private
      attr_reader :tmpfile

      def create_tmpfile
        @tmpfile = Tempfile.new('object-counter')
        @tmpfile.unlink
        @tmpfile
      end
  end
end