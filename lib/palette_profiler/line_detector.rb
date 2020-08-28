require 'objspace'

module PaletteProfiler
  class LineDetector
    def start
      GC.start
      GC.start
      GC.start

      @start_generation = GC.count
      ObjectSpace.trace_object_allocations_start
    end

    def stop
      GC.start
      GC.start
      GC.start

      @stop_generation = GC.count
      ObjectSpace.trace_object_allocations_stop
      @result = Result.new start_generation, stop_generation
      ObjectSpace.trace_object_allocations_clear
    end

    def output(path)
      File.open(path, 'w') do |file|
        # header
        file.puts (['GC Generation', 'Memory Size (bytes)']).join(',')
        @result.memsize_by_generation.to_a.sort_by {|arr| arr[0] }.each do |arr|
          file.puts arr.join(',')
        end

        file.puts ''

        # header
        file.puts (['Source Location', 'Memory Size (bytes)']).join(',')
        @result.memsize_by_line.to_a.sort_by {|arr| arr[1] }.reverse_each do |arr|
          file.puts arr.join(',')
        end
      end
    end

    private
      attr_reader :start_generation, :stop_generation

    class Result
      attr_reader :start_generation, :stop_generation
      # メモリサイズをオブジェクトの生成されたGC世代ごとに集計
      attr_reader :memsize_by_generation
      # メモリサイズをソースコードの行ごとに集計
      attr_reader :memsize_by_line

      def initialize(start_generation, stop_generation)
        @start_generation, @stop_generation = start_generation, stop_generation

        @memsize_by_generation = get_memsize_by_generation
        @memsize_by_line       = get_memsize_by_line
      end

      private
        def get_memsize_by_generation
          rvalue_size = GC::INTERNAL_CONSTANTS[:RVALUE_SIZE]
          result = Hash.new {|h, k| h[k] = 0 }

          ObjectSpace.each_object do |obj|
            alloc_gen = ObjectSpace.allocation_generation(obj) || 0
            next unless alloc_gen >= start_generation && alloc_gen < stop_generation

            memsize = ObjectSpace.memsize_of(obj)
            memsize = rvalue_size if memsize > 100_000_000_000

            result[alloc_gen] += memsize
          end

          result
        end

        def get_memsize_by_line
          rvalue_size = GC::INTERNAL_CONSTANTS[:RVALUE_SIZE]
          result = Hash.new {|h, k| h[k] = 0 }

          ObjectSpace.each_object do |obj|
            alloc_gen = ObjectSpace.allocation_generation(obj) || 0
            next unless alloc_gen >= start_generation && alloc_gen < stop_generation

            memsize = ObjectSpace.memsize_of(obj)
            memsize = rvalue_size if memsize > 100_000_000_000

            sourcefile = ObjectSpace.allocation_sourcefile(obj)
            sourceline = ObjectSpace.allocation_sourceline(obj)
            key = (sourcefile && sourceline) ? "#{sourcefile}:#{sourceline}" : 'unknown'

            result[key] += memsize
          end

          result
        end
    end
  end
end