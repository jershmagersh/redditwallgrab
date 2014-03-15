#!/usr/bin/ruby

require 'net/http'
require 'optparse'
require 'json'

@options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: reddit_wallpaper_grabber.rb [options]"
  
  opts.on("-v", "Verbose output.") do
    @options[:verbose] = true
  end
  
  opts.on("-h", "Display this screen.") do
  	puts opts			
  	exit
  end
  
  opts.on("-t time", "Grab the top wallpapers with specified time (hour, day, month, year, all).") do |time|
  	@options[:top] = time
  end
  
  opts.on("-a", "Grab all wallpapers if top is specified.") do
  	@options[:all] = true
  end
  
  opts.on("-l N", "If We should limit how many 'pages' we traverse. Default is 20.") do |n|
  	@options[:limit] = n
  end  
  
  opts.on("-n", "Grab the newest wallpapers.") do
  	@options[:new] = true
  end
  
  opts.on("-i", "Use imgur image links only.") do
  	@options[:imgur_only] = true
  end
  
  opts.on("-d dir", "Directory to downloads wallpapers to. Default is ./wallpapers.") do |dir|
  	@options[:dir] = dir 
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
	
		if @options[:top]
			if i == 1
				wallj = Net::HTTP.get(URI.parse("http://api.reddit.com/r/wallpapers/top.json?sort=top&t=#{@options[:top]}"))
			else
				wallj = Net::HTTP.get(URI.parse("http://api.reddit.com/r/wallpapers/top.json?sort=top&t=#{@options[:top]}&count=25&after=#{after}"))
			end		
		elsif @options[:new]
			if i == 1
				wallj = Net::HTTP.get(URI.parse("http://api.reddit.com/r/wallpapers/new.json"))
			else
				wallj = Net::HTTP.get(URI.parse("http://api.reddit.com/r/wallpapers/new.json?count=25&after=#{after}"))
			end	
		else
			puts "Please specify whether you'd like the new (-n) or top (-t) wallpapers."
			exit
		end
		
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
	
	Net::HTTP.start(URI.parse(url).host) do |http|
		resp = http.get(URI.parse(url).request_uri)
		
		open("#{dir}/#{filename}", "wb") do |file|
			file.write(resp.body)
		end
	end
	
	puts "#{filename} downloaded!" if @options[:verbose]
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