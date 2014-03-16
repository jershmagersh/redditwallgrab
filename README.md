##Reddit Wallpaper Grabber

###Overview
Basically I was sick of downloading each awesome wallpaper I saw on the /r/wallpapers subreddit from imgur or whatever exteral website by hand so I wrote this script to address that.

###Running
* Start by saving, forking or cloning the script locally as a .rb file.
* Once saved you will be able to run it with your local ruby interpreter. Start by running the script with the command line argument -h:
```rocket:reddit_wallpaper_grabber jm$ ruby reddit_wall_grab.rb -h
Usage: reddit_wall_grab.rb [options]
    -v                               Verbose output.
    -h                               Display this screen.
    -t time                          Grab the top wallpapers with specified time (hour, day, month, year, all).
    -l N                             If We should limit how many 'pages' we traverse. Default is 20.
    -n                               Grab the newest wallpapers.
    -i                               Use imgur image links only.
    -d dir                           Directory to download wallpapers to. Default is ./wallpapers.``` 
