##Reddit Wallpaper Grabber

###Overview
Basically I was sick of downloading each awesome wallpaper I saw on the /r/wallpapers subreddit  by hand so I wrote this script to address that. It provides customizable options provided through command line arguments to choose from the top wallpapers based on a timeframe, and from the new wallpapers being posted. Ideally you could add this to a cron/launchd/scheduled task to download the best wallpapers to add to your desktop rotation :)

###Running
* Start by saving, forking or cloning the script locally as a .rb file.
* Once saved you will be able to run it with your local ruby interpreter. Start by running the script with the command line argument -h:

>rocket:reddit_wallpaper_grabber jm$ ruby reddit_wall_grab.rb -h
>Usage: reddit_wall_grab.rb [options]
>	-v                               Verbose output
>	-h                               Display this screen.
>	-t time                          Grab the top wallpapers with specified time (hour, day, month, year, all).
>	-l N                             If We should limit how many 'pages' we traverse. Default is 20.
>	-n                               Grab the newest wallpapers.
>	-i                               Use imgur image links only.
>	-d dir                           Directory to download wallpapers to. Default is ./wallpapers. 

Sweet, so now that you have the help output go ahead and provide command line arguments, for example if I wanted the top wallpapers of all time, and wanted the top 5000 of them I can do:
>joshs-mbp:reddit_wallpaper_grabber jr$ ruby reddit_wall_grab.rb -t all -l 200
>Downloading wallpaper from http://i.imgur.com/wvunc.jpg to wallpapers...
>Downloading wallpaper from http://ngm.nationalgeographic.com/your-shot/weekly-wrapper/2012/img/1012wallpaper-week-3-1_1600.jpg to wallpapers...
>Downloading wallpaper from http://imgur.com/HQSjesL.jpg to wallpapers...
>Downloading wallpaper from http://i.imgur.com/yWWV0.jpg to wallpapers...
>Downloading wallpaper from http://i.imgur.com/p5fLTnB.jpg to wallpapers...
>Downloading wallpaper from http://i.imgur.com/Nan6u5i.jpg to wallpapers...
>Downloading wallpaper from http://i.imgur.com/NfLI9W0.jpg to wallpapers...
>Downloading wallpaper from http://i.imgur.com/X7lsZet.jpg to wallpapers...
>Downloading wallpaper from http://i.imgur.com/3eEC52y.jpg to wallpapers...
>Downloading wallpaper from http://i.imgur.com/tOaYBJk.jpg to wallpapers...
>Downloading wallpaper from http://i.imgur.com/QQ3O6PO.jpg to wallpapers...
>--snip--

You're probably wondering why 5000 if I only gave a limit of 200? Well each page count by default is 25, so 25*200 = 5000 wallpapers!
