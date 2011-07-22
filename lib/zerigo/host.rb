module Zerigo
  module Host

    attr_reader :id

    def initialize(*args)
      opts = args.extract_options!
      if (args.first.to_s =~ /^(\d+)$/)
        @id = $1
      else

			end
		end

	end
end # module Zerigo
