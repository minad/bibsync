require 'bibsync'
require 'optparse'

module BibSync
  class Command
    def initialize(args)
      @args = args
      @options = {}
    end

    def run
      @opts = OptionParser.new(&method(:set_opts))
      @opts.parse!(@args)
      process
      exit 0
    rescue Exception => ex
      raise ex if Log.trace || SystemExit === ex
      $stderr.print "#{ex.class}: " if ex.class != RuntimeError
      $stderr.puts ex.message
      $stderr.puts '  Use --trace for backtrace.'
      exit 1
    end

    private

    def set_opts(opts)
      opts.banner = "Usage: #{$0} [options]"

      opts.on('-b', '--bib bibfile.bib', 'Set bibliography') do |bib|
        @options[:bib] = bib
      end

      opts.on('-d', '--dir directory', 'Set directory') do |dir|
        @options[:dir] = dir
      end

      opts.on('-v', '--check-versions', 'Check for updated arXiv papers') do
        @options[:check_versions] = true
      end

      opts.on('-u', '--update', 'Update arXiv papers') do
        @options[:update] = true
      end

      opts.on('-s', '--sync', 'Synchronize missing metadata') do
        @options[:sync] = true
      end

      opts.on('-r', '--resync', 'Force synchronization with arXiv and DOI') do
        @options[:resync] = true
      end

      opts.on('-m', '--citedbyme directory', 'Find my citations in my TeX files') do |dir|
        @options[:citedbyme] = dir
      end

      opts.on('-j', '--jabref', 'Format bibliography file with JabRef') do
        @options[:jabref] = true
      end

      opts.on('-f', '--fetch url', 'Fetch arXiv paper as PDF file') do |url|
        (@options[:fetch] ||= []) << url
      end

      opts.on('-V', '--verbose', 'Verbose output') do
        Log.level = :debug
      end

      opts.on('--trace', 'Show a full traceback on error') do
        Log.trace = true
      end

      opts.on('-h', '--help', 'Display this help') do
        puts opts
        exit
      end

      opts.on('--version', 'Display version information') do
        puts "BibSync Version #{BibSync::VERSION}"
        exit
      end
    end

    def process
      if @args.size != 0
        puts 'Too many arguments'
        puts @opts
        exit
      end

      if @options[:bib]
        bib = @options[:bib] = Bibliography.new(@options[:bib])
        bib.save_hook = Transformer.new
        at_exit { bib.save }
      end

      actions = []
      actions << :FetchFromArXiv if @options[:fetch]
      actions << :CheckArXivVersions if @options[:check_versions] || @options[:update]
      actions << :SynchronizeFiles << :DetermineArXivDOI << :SynchronizeMetadata if @options[:sync] || @options[:resync]
      actions << :FindMyCitations if @options[:citedbyme]
      actions << :Validate if @options[:bib]
      actions << :JabRefFormat if @options[:jabref]

      if actions.empty?
        puts "Please specify actions! See #{$0} --help"
        exit
      end

      actions.map {|a| Actions.const_get(a).new(@options) }.each {|a| a.run }
    end
  end
end
