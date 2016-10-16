#!/usr/bin/ruby

require 'net/http'
require 'optparse'
require 'json'

@options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: reddit_wall_grab.rb [options]"
  option_provided = false
  
  opts.on("-v", "Verbose output.") do
    @options[:verbose] = true
    option_privided = true
  end
  
  opts.on("-h", "Display this screen.") do
  	puts opts			
  	exit
  end
  
  opts.on("-t time", "Grab the top wallpapers with specified time (hour, day, month, year, all).") do |time|
  	@options[:top] = time
    option_privided = true
  end

  opts.on("-l N", "If We should limit how many 'pages' we traverse. Default is 20.") do |n|
  	@options[:limit] = n
    option_privided = true
  end  
  
  opts.on("-n", "Grab the newest wallpapers.") do
  	@options[:new] = true
    option_privided = true
  end
  
  opts.on("-i", "Use imgur image links only.") do
  	@options[:imgur_only] = true
    option_privided = true
  end
  
  opts.on("-d dir", "Directory to download wallpapers to. Default is ./wallpapers.") do |dir|
  	@options[:dir] = dir 
    option_privided = true
  end

  unless option_provided
    puts opts.banner
    exit
  end
end.parse!

def grab_wallpapers
	
	limit = nil #pages, starting from last link "fullname thing id" and default count.
	links = nil
	after = nil #"fullname thing id" for next page.
	
	if @options[:limit]
		limit = @options[:limit].to_i
	else
		limit = 50
	end
	
	for i in 1..limit
		wallj = nil
	    uri = nil

		if @options[:top]
			if i == 1
                uri = URI("https://api.reddit.com/r/wallpapers/top.json?sort=top&t=#{@options[:top]}")
			else
                uri = URI("https://api.reddit.com/r/wallpapers/top.json?sort=top&t=#{@options[:top]}&count=25&after=#{after}")
			end		
		elsif @options[:new]
			if i == 1
                uri = URI("https://api.reddit.com/r/wallpapers/top.json?sort=top&t=#{@options[:top]}")
			else
                uri = URI("https://api.reddit.com/r/wallpapers/new.json?count=25&after=#{after}")
			end	
		else
			puts "Please specify whether you'd like the new (-n) or top (-t) wallpapers."
			exit
		end

        req = Net::HTTP::Get.new(uri)
        req['User-Agent'] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.143 Safari/537.36"
        http = Net::HTTP.new(uri.hostname, uri.port)
        http.use_ssl = true
        wallj = http.request(req)
        wallj = wallj.body
		
		links = parse_links_json(wallj)
		puts "Wallpaper links parsed: #{links}" if $DEBUG
		after = parse_after_json(wallj)
		
		if after == nil
			puts "That's all folks!"
			break
		end
		
		download_images(links)
	end
					
end

def parse_links_json(wallj)
	links = []
	parsed = JSON.parse(wallj)
	
	parsed["data"]["children"].each do |link|
		links << link["data"]["url"]
	end
	
	links			
end

def parse_after_json(wallj)
	parsed = JSON.parse(wallj)
	after =	parsed["data"]["after"]
	
	after
end

def download_images(links)
	download_dir = get_download_dir	
	
	links.each do |link|
		if link.to_s.include? "imgur"
			if link =~ /\.jpg|\.jpeg|\.png|\.gif/
				puts "Downloading wallpaper from #{link.to_s} to #{download_dir}..."
				download_image(link, download_dir)
			else
				#TODO support non-direct links to imgur
			end
		else
			unless @options[:imgur_only]
				if link =~ /\.jpg|\.jpeg|\.png|\.gif/
					puts "Downloading wallpaper from #{link.to_s} to #{download_dir}..."
					download_image(link, download_dir)
				end
				
				puts "Not able to resolve images from other domains at this time..." if @options[:verbose]	
			end
		end
	end
end

def download_image(url, dir)
	filename = parse_fname(url)
	begin
		Net::HTTP.start(URI.parse(url).host) do |http|
			resp = http.get(URI.parse(url).request_uri)
		
			open("#{dir}/#{filename}", "wb") do |file|
				file.write(resp.body)
			end
		end
		puts "#{filename} downloaded!" if @options[:verbose]
	rescue
		puts "There was an error downloading this, skipping..."
	end
end

def parse_fname(url)
	url_arr = url.split("/")
	fname = url_arr[url_arr.length-1]
	
	fname
end

def get_download_dir
	download_dir = nil
	
	if @options[:dir]
		unless File.exist?(@options[:dir])
			puts "The specified directory #{@options[:dir]} doesn't exist..."
			exit
		end
		
		download_dir = @options[:dir]
	else
		unless File.exist? "wallpapers"
			Dir.mkdir("wallpapers")		
		end
	
		download_dir = "wallpapers"
	end
	
	download_dir
end

unless @options.empty?
	grab_wallpapers
	puts "Done!"
end
