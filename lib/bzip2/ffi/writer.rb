require 'pathname'

module Bzip2
  module FFI
    class Writer < BzStreamIO
      OUT_BUFFER_SIZE = 4096      

      class << self
        public :new

        def open(io_or_path, options = {})
          if io_or_path.kind_of?(String) || io_or_path.kind_of?(Pathname)
            options = options.merge(autoclose: true)
            io = File.open(io_or_path.to_s, 'wb')

            # JRuby 1.7.18 doesn't have a File#advise method (in any mode).
            if io.respond_to?(:advise)
              io.advise(:sequential)
              io.advise(:noreuse)
            end

            super(io, options)
          else
            super
          end
        end

        private

        def finalize(stream)
          ->(id) do
            Libbz2::BZ2_bzCompressEnd(stream)
          end
        end
      end

      def initialize(io, options = {})    
        super
        raise ArgumentError, 'io must respond to write' unless io.respond_to?(:write)
        
        block_size = options[:block_size] || 1
        work_factor = options[:work_factor] || 0
        
        raise RangeError, 'block_size must be >= 1 and <= 9' if block_size < 1 || block_size > 9
        raise RangeError, 'work_factor must be >= 0 and <= 250' if work_factor < 0 || work_factor > 250
        
        check_error(Libbz2::BZ2_bzCompressInit(stream, block_size, 0, work_factor))

        ObjectSpace.define_finalizer(self, self.class.send(:finalize, stream))
      end

      def close
        s = stream
        s[:next_in] = nil
        s[:avail_in] = 0

        buffer = ::FFI::MemoryPointer.new(1, OUT_BUFFER_SIZE)
        begin
          loop do
            s[:next_out] = buffer
            s[:avail_out] = buffer.size

            res = Libbz2::BZ2_bzCompress(s, Libbz2::BZ_FINISH)
            check_error(res)

            count = buffer.size - s[:avail_out]
            io.write(buffer.read_string(count))

            break if res == Libbz2::BZ_STREAM_END
          end
        ensure
          buffer.free
          s[:next_out] = nil
        end

        res = Libbz2::BZ2_bzCompressEnd(s)
        ObjectSpace.undefine_finalizer(self)
        check_error(res)

        super
      end

      def write(string)
        string = string.to_s

        s = stream
        next_in = ::FFI::MemoryPointer.new(1, string.bytesize)
        buffer = ::FFI::MemoryPointer.new(1, OUT_BUFFER_SIZE)
        begin
          next_in.write_bytes(string)
          s[:next_in] = next_in        
          s[:avail_in] = next_in.size

          while s[:avail_in] > 0
            s[:next_out] = buffer
            s[:avail_out] = buffer.size

            check_error(Libbz2::BZ2_bzCompress(s, Libbz2::BZ_RUN))

            count = buffer.size - s[:avail_out]
            io.write(buffer.read_string(count))
          end
        ensure
          next_in.free
          buffer.free
          s[:next_in] = nil
          s[:next_out] = nil
        end

        string.bytesize
      end     
    end
  end
end
