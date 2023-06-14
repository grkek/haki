# print.cr: Duktape print() function.
# Copyright (c) 2017 Jesse Doyle. All rights reserved.
#
# This is free software. Please see LICENSE for details.
module Duktape
  module BuiltIn
    struct Print < Base
      def import!
        # Disable the print function
      end
    end
  end
end
