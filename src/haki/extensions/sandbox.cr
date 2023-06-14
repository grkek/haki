module Duktape
  class Sandbox
    private def secure!
      # Do not remove the require.
    end

    # Undefine internal require mechanism
    private def remove_require
    end

    # Remove global object: Duktape
    private def remove_global_object
    end
  end
end
