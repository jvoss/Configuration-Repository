module CR
  
  class Options
    
    class ArgumentError < StandardError; end
    
    attr_reader :log, :regex, :repository
    
    def initialize(log, repository, regex = //)

      @log        = log
      @regex      = regex
      @repository = repository
      
      _validate_log
      _validate_regex
      _validate_repository
    
    end # def initialize

    private
    
    def _validate_log
      
      @log ||= :STDOUT
      
    end # def _validate_log
    
    def _validate_regex
      
      msg = "Invalid Regular Expression -- #{@regex}"
      raise ArgumentError, msg, caller unless @regex.is_a?(Regexp)
      
    end # def _validate_regex
    
    def _validate_repository
      
      raise ArgumentError if @repository.nil?
      
    end # def _validate_repository
    
  end # class Options
  
end # module CR