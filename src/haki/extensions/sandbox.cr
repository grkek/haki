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

    # Call the named property with the supplied arguments,
    # returning the value of the called property.
    #
    # This call will raise a `Duktape::Error` if the
    # last evaluated expression threw an error.
    #
    # The property string can include parent objects:
    #
    # ```
    # rt = Duktape::Runtime.new
    # rt.call("JSON.stringify", 123) # => "123"
    # ```
    #
    def call(prop : String, *args)
      call prop.split("."), *args
    end

    # Call the nested property that is supplied via an
    # array of strings with the supplied arguments.
    #
    # This call will raise a `Duktape::Error` if the
    # last evaluated expression threw an error.
    #
    # ```
    # rt = Duktape::Runtime.new
    # rt.call(["Math", "PI"]) # => 3.14159
    # ```
    #
    def call(props : Array(String), *args)
      return nil.as(JSPrimitive) if props.empty?
      prepare_nested_prop props
      perform_call args
      check_and_raise_error
      return_last_evaluated_value
    end

    # Evaluate the supplied source code on the underlying javascript
    # context and return the last value:
    #
    # ```
    # rt = Duktape::Runtime.new
    # rt.eval("1 + 1") => 2.0
    # ```
    #
    def eval(source : String)
      self.eval_mutex! source
      return_last_evaluated_value
    end

    # Execute the supplied source code on the underyling javascript
    # context without returning any value.
    #
    # ```
    # rt = Duktape::Runtime.new
    # rt.exec("1 + 1") # => nil
    # ```
    #
    def exec(source : String)
      self.eval_mutex! source
      reset_stack!
      nil
    end

    # :nodoc:
    private def check_and_raise_error
      if self.is_error?(-1)
        code = self.get_error_code -1
        self.raise_error code
      end
    end

    # :nodoc:
    private def invalid_type(index : LibDUK::Index)
      raise TypeError.new "invalid type at index #{index}"
    end

    # :nodoc:
    private def next_array_element(array : Array(JSPrimitive))
      while self.next -1, true
        array << stack_to_crystal -1
        self.pop_2
      end
    end

    # :nodoc:
    private def next_hash_element(hash : Hash(String, JSPrimitive))
      while self.next -1, true
        key = self.to_string -2
        hash[key] = stack_to_crystal -1
        self.pop_2
      end
    end

    # :nodoc:
    private def object_to_crystal(index : LibDUK::Index)
      if self.is_function index
        # TODO: can we do better than just get a string
        # when the object is a function?
        object_to_string index
      elsif self.is_array index
        Array(JSPrimitive).new.tap do |array|
          self.enum index, LibDUK::Enum::ArrayIndicesOnly
          next_array_element array
          self.pop
        end
      elsif self.is_object index
        Hash(String, JSPrimitive).new.tap do |hash|
          self.enum index, LibDUK::Enum::OwnPropertiesOnly
          next_hash_element hash
          self.pop
        end
      else
        invalid_type index
      end
    end

    # :nodoc:
    private def object_to_string(index : LibDUK::Index)
      self.safe_to_string index
    end

    # :nodoc:
    private def perform_call(args)
      push_args(args)

      obj_idx = -(args.size + 2)
      if args.size > 0
        self.call_prop(obj_idx, args.size)
      else
        self.get_prop(obj_idx)
        self.call(0) if self.is_callable(-1)
      end
    end

    # :nodoc:
    private def prepare_nested_prop(props : Array(String))
      self.push_global_object
      props.each_with_index do |prop, count|
        self << prop
        # Break after pushing the last property name
        # so that we are able to use `call_prop` method
        # on the last property name as a string.
        break if count == props.size - 1
        self.get_prop(-2).tap do |found|
          unless found
            raise Error.new "invalid property: #{prop}"
          end
        end
      end
    end

    # :nodoc:
    private def push_args(args)
      args.each { |arg| push_crystal_object arg }
    end

    # :nodoc:
    private def push_crystal_object(arg : Int::Signed)
      self.push_int arg
    end

    # :nodoc:
    private def push_crystal_object(arg : Int::Unsigned)
      self.push_uint arg
    end

    # :nodoc:
    private def push_crystal_object(arg : Float)
      self.push_number arg.to_f64
    end

    # :nodoc:
    private def push_crystal_object(arg : Bool)
      self.push_boolean arg
    end

    # :nodoc:
    private def push_crystal_object(arg : Symbol)
      self.push_string arg.to_s
    end

    # :nodoc:
    private def push_crystal_object(arg : String)
      self.push_string arg
    end

    # :nodoc:
    private def push_crystal_object(arg : Array)
      array_index = self.push_array
      arg.each_with_index do |object, index|
        push_crystal_object object
        self.put_prop_index array_index, index.to_u32
      end
    end

    # :nodoc:
    private def push_crystal_object(arg : Hash(String | Symbol, _))
      self.push_object
      arg.each do |key, value|
        self.push_string key.to_s
        push_crystal_object value
        self.put_prop -3
      end
    end

    # :nodoc:
    private def push_crystal_object(arg : NamedTuple)
      push_crystal_object(arg.to_h)
    end

    # :nodoc:
    private def push_crystal_object(arg)
      raise TypeError.new "unable to convert JS type"
    end

    # :nodoc:
    private def reset_stack!
      self.set_top(0) if self.get_top > 0
    end

    # :nodoc:
    private def return_last_evaluated_value
      (stack_to_crystal(-1).as(JSPrimitive)).tap do
        reset_stack!
      end
    end

    # :nodoc:
    private def stack_to_crystal(index : LibDUK::Index)
      case self.get_type(index)
      when :none, :undefined, :null
        nil
      when :boolean
        self.get_boolean index
      when :number
        self.get_number index
      when :string
        self.get_string index
      when :object
        object_to_crystal index
      when :buffer
        object_to_string index
      when :pointer
        object_to_string index
      when :lightfunc
        object_to_string index
      else
        invalid_type index
      end
    end
  end
end
