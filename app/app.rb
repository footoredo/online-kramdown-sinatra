module OnlineKramdown
  class App < Sinatra::Base

    # Configure reloading.
    configure do
      register Sinatra::Reloader if development?
    end

    # Configure logging.
    configure do
      STDOUT.sync = true
      enable :logging unless test?
    end

    # Enable static serving.
    configure do
      set :public_folder, 'public'
      enable :static
    end

    get '/' do
      erb :index
    end
    
    post '/updateCSS' do
      filename = params[:filename] || ''
      source   = params[:source]   || ''
      
      file = File.open(File.join('public', File.join('temp-files',filename+".css") ), "w")
      file.puts source
      
      file.close()
    end

    post '/transform' do
      filename = params[:filename] || ''
      source   = params[:source]   || ''
      options  = params[:options]  || {}
      options  = process_options(options)
      logger.info options
      
      file = File.open(File.join('public', File.join('temp-files',filename+".html") ), "w")
      
      file.puts '<!DOCTYPE html>'
      file.puts '<html>'
      file.puts '  <head>'
      file.puts '    <meta charset="utf-8"/>'
      file.puts '    <meta content="width=device-width, initial-scale=1.0" name="viewport"/>'
      file.puts '    <link rel="stylesheet" type="text/css" href="' + filename + '.css" />'
      file.puts '    <script type="text/javascript" src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML"></script>'
      file.puts '    <link rel="stylesheet" type="text/css" media="all" href="/style.css" />'
      file.puts '    <link rel="stylesheet" type="text/css" media="all" href="/syntax.css" />'
      file.puts '  </head>'
      
      file.puts '  <body>'
      file.puts '    <div class="preview-box">'
      file.puts '      <div class="lotus-post">'
      file.puts Kramdown::Document.new(source, options).to_html
      file.puts '      </div>'
      file.puts '    </div>'
      file.puts '  </body>'
      
      file.close()
    end

    private

    def process_options(opts)
      Hash[opts.map {|k, v| [k.to_sym, v === 'true' ? true : v === 'false' ? false : v]}]
    end

  end
end
