#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
module Spec
  module Mocks

    class BaseExpectation
      attr_reader :sym
      attr_writer :expected_received_count, :method_block, :expected_from
      protected :expected_received_count=, :method_block=, :expected_from=
      attr_accessor :error_generator
      protected :error_generator, :error_generator=
      
      def initialize(error_generator, expectation_ordering, expected_from, sym, method_block, expected_received_count=1, opts={})
        @error_generator = error_generator
        @error_generator.opts = opts
        @expected_from = expected_from
        @sym = sym
        @method_block = method_block
        @return_block = nil
        @actual_received_count = 0
        @expected_received_count = expected_received_count
        @args_expectation = ArgumentExpectation.new([ArgumentConstraints::AnyArgsConstraint.new])
        @consecutive = false
        @exception_to_raise = nil
        @symbol_to_throw = nil
        @order_group = expectation_ordering
        @at_least = nil
        @at_most = nil
        @args_to_yield = []
      end
      
      def build_child(expected_from, method_block, expected_received_count, opts={})
        child = clone
        child.expected_from = expected_from
        child.method_block = method_block
        child.expected_received_count = expected_received_count
        new_gen = error_generator.clone
        new_gen.opts = opts
        child.error_generator = new_gen
        child.clone_args_to_yield @args_to_yield
        child
      end
      
      def expected_args
        @args_expectation.args
      end

      def and_return(*values, &return_block)
        Kernel::raise AmbiguousReturnError unless @method_block.nil?
        case values.size
          when 0 then value = nil
          when 1 then value = values[0]
        else
          value = values
          @consecutive = true
          @expected_received_count = values.size if !ignoring_args? &&
                                                    @expected_received_count < values.size
        end
        @return_block = block_given? ? return_block : lambda { value }
        # Ruby 1.9 - see where this is used below
        @ignore_args = !block_given?
      end
      
      # :call-seq:
      #   and_raise()
      #   and_raise(Exception) #any exception class
      #   and_raise(exception) #any exception object
      #
      # == Warning
      #
      # When you pass an exception class, the MessageExpectation will
      # raise an instance of it, creating it with +new+. If the exception
      # class initializer requires any parameters, you must pass in an
      # instance and not the class.
      def and_raise(exception=Exception)
        @exception_to_raise = exception
      end
      
      def and_throw(symbol)
        @symbol_to_throw = symbol
      end
      
      def and_yield(*args)
        if @args_to_yield_were_cloned
          @args_to_yield.clear
          @args_to_yield_were_cloned = false
        end
        
        @args_to_yield << args
        self
      end
  
      def matches(sym, args)
        @sym == sym and @args_expectation.args_match?(args)
      end
      
      def invoke(args, block)
        if @expected_received_count == 0
          @failed_fast = true
          @actual_received_count += 1
          @error_generator.raise_expectation_error @sym, @expected_received_count, @actual_received_count, *args
        end
        
        @order_group.handle_order_constraint self

        begin
          Kernel::raise @exception_to_raise unless @exception_to_raise.nil?
          Kernel::throw @symbol_to_throw unless @symbol_to_throw.nil?
          
          
          if !@method_block.nil?
            default_return_val = invoke_method_block(args)
          elsif @args_to_yield.size > 0
            default_return_val = invoke_with_yield(block)
          else
            default_return_val = nil
          end
          
          if @consecutive
            return invoke_consecutive_return_block(args, block)
          elsif @return_block
            return invoke_return_block(args, block)
          else
            return default_return_val
          end
        ensure
          @actual_received_count += 1
        end
      end

      def called_max_times?
        @expected_received_count != :any && @expected_received_count > 0 &&
          @actual_received_count >= @expected_received_count
      end
      
      protected

      def invoke_method_block(args)
        begin
          @method_block.call(*args)
        rescue => detail
          @error_generator.raise_block_failed_error @sym, detail.message
        end
      end
      
      def invoke_with_yield(block)
        if block.nil?
          @error_generator.raise_missing_block_error @args_to_yield
        end
        value = nil
        @args_to_yield.each do |args_to_yield_this_time|
          if block.arity > -1 && args_to_yield_this_time.length != block.arity
            @error_generator.raise_wrong_arity_error args_to_yield_this_time, block.arity
          end
          value = block.call(*args_to_yield_this_time)
        end
        value
      end
      
      def invoke_consecutive_return_block(args, block)
        args << block unless block.nil?
        value = @return_block.call(*args)
        
        index = [@actual_received_count, value.size-1].min
        value[index]
      end
      
      def invoke_return_block(args, block)
        args << block unless block.nil?
        # Ruby 1.9 - when we set @return_block to return values
        # regardless of arguments, any arguments will result in
        # a "wrong number of arguments" error
        if @ignore_args
          @return_block.call()
        else
          @return_block.call(*args)
        end
      end

      def clone_args_to_yield(args)
        @args_to_yield = args.clone
        @args_to_yield_were_cloned = true
      end
      
      def failed_fast?
        @failed_fast
      end
    end
    
    class MessageExpectation < BaseExpectation
      
      def matches_name_but_not_args(sym, args)
        @sym == sym and not @args_expectation.args_match?(args)
      end
       
      def verify_messages_received   
        return if expected_messages_received? || failed_fast?
    
        generate_error
      rescue Spec::Mocks::MockExpectationError => error
        error.backtrace.insert(0, @expected_from)
        Kernel::raise error
      end
      
      def expected_messages_received?
        ignoring_args? || matches_exact_count? ||
           matches_at_least_count? || matches_at_most_count?
      end
      
      def ignoring_args?
        @expected_received_count == :any
      end
      
      def matches_at_least_count?
        @at_least && @actual_received_count >= @expected_received_count
      end
      
      def matches_at_most_count?
        @at_most && @actual_received_count <= @expected_received_count
      end
      
      def matches_exact_count?
        @expected_received_count == @actual_received_count
      end
      
      def similar_messages
        @similar_messages ||= []
      end

      def advise(args, block)
        similar_messages << args
      end
      
      def generate_error
        if similar_messages.empty?
          @error_generator.raise_expectation_error(@sym, @expected_received_count, @actual_received_count, *@args_expectation.args)
        else
          @error_generator.raise_unexpected_message_args_error(self, *@similar_messages.first)
        end
      end

      def with(*args, &block)
        @args_expectation = ArgumentExpectation.new(args, &block)
        self
      end
      
      def exactly(n)
        set_expected_received_count :exactly, n
        self
      end
      
      def at_least(n)
        set_expected_received_count :at_least, n
        self
      end
      
      def at_most(n)
        set_expected_received_count :at_most, n
        self
      end

      def times(&block)
        @method_block = block if block
        self
      end
  
      def any_number_of_times(&block)
        @method_block = block if block
        @expected_received_count = :any
        self
      end
  
      def never
        @expected_received_count = 0
        self
      end
  
      def once(&block)
        @method_block = block if block
        @expected_received_count = 1
        self
      end
  
      def twice(&block)
        @method_block = block if block
        @expected_received_count = 2
        self
      end
  
      def ordered(&block)
        @method_block = block if block
        @order_group.register(self)
        @ordered = true
        self
      end
      
      def negative_expectation_for?(sym)
        return false
      end
      
      protected
        def set_expected_received_count(relativity, n)
          @at_least = (relativity == :at_least)
          @at_most = (relativity == :at_most)
          @expected_received_count = case n
            when Numeric
              n
            when :once
              1
            when :twice
              2
          end
        end
      
    end
    
    class NegativeMessageExpectation < MessageExpectation
      def initialize(message, expectation_ordering, expected_from, sym, method_block)
        super(message, expectation_ordering, expected_from, sym, method_block, 0)
      end
      
      def negative_expectation_for?(sym)
        return @sym == sym
      end
    end
    
  end
end
