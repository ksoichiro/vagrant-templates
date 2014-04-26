require 'rubygems'
require 'sinatra'
get('/') { open('website/index.html').read }
run Sinatra::Application
