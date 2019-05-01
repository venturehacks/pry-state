require 'delegate'

# This is for super-high-level integration testing.
class ReplTester
  class Input
    def initialize(tester_mailbox)
      @tester_mailbox = tester_mailbox
    end

    def readline(prompt)
      @tester_mailbox.push prompt
      mailbox.pop
    end

    def mailbox
      Thread.current[:mailbox]
    end
  end

  class Output < SimpleDelegator
    def clear
      __setobj__(StringIO.new)
    end
  end

  def self.start(out: nil, options: {}, &block)
    Thread.current[:mailbox] = Queue.new
    instance = nil
    input    = Input.new(Thread.current[:mailbox])
    output   = Output.new( out || StringIO.new)

      instance = new(options)
    redirect_pry_io input, output do
      instance.instance_eval(&block)
    end
      instance.ensure_exit
  ensure
    puts "in ensure"
    instance.thread.kill if instance && instance.thread && instance.thread.alive?
  end

  attr_accessor :thread, :mailbox, :last_prompt

  def initialize(options = {})
    @pry     = Pry.new(options)
    @repl    = Pry::REPL.new(@pry)
    @mailbox = Thread.current[:mailbox]

    @thread  = Thread.new do
      begin
        Thread.current[:mailbox] = Queue.new
        @repl.start
      ensure
        Thread.current[:session_ended] = true
        mailbox.push nil
      end
    end

    @should_exit_naturally = false

    wait # wait until the instance reaches its first readline
  end

  # Accept a line of input, as if entered by a user.
  def input(input)
    puts "in input #{input}"
    #reset_output
    repl_mailbox.push input
    wait
    @pry.output.string
  end

  # Assert that the current prompt matches the given string or regex.
  def prompt(match)
    match.should === last_prompt # rubocop:disable Style/CaseEquality
  end

# This conflicts with the RSpec output matcher.
#   Assert that the most recent output (since the last time input was called)
#   matches the given string or regex.
  def output
    @pry.output.string
  end

  # Assert that the Pry session ended naturally after the last input.
  def assert_exited
    @should_exit_naturally = true
  end

  # @private
  def ensure_exit
    puts "in ensure_exit"
    if @should_exit_naturally
      raise "Session was not ended!" unless @thread[:session_ended].equal?(true)
    else
      input "exit-all"
      raise "REPL didn't die" unless @thread[:session_ended]
    end
  end

  private

  def reset_output
    @pry.output.clear
  end

  def repl_mailbox
    @thread[:mailbox]
  end

  def wait
    @last_prompt = mailbox.pop
  end
end
