use Rack::Static, urls: [''], root: 'website', index: 'index.html'
run lambda {|env|}
