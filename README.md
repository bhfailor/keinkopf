# keinkopf

Run reports on course work for Developmental Math

This app is designed to scrape data from the wytheville.mylabsplus.com web site and produce a table useful for math instructors.  If you are not a developmental math instructor at Wytheville Community College in Wytheville, VA, it will not be of any value to you out of the box.

You may find some useful code snippets and algorithms that you could apply to your own projects, however.  I originally planned to only have phantomjs as a dependency, hoping to easily deploy it on heroku, but I could not get phantomjs to play nicely with the wytheville.mylabsplus.com site -- that site kept throwing an "expired session" exception.  The approach that worked was to use selenium-webkit, firefox, xvfb, and the headless ruby gem.  I source the provision.sh script from the app's parent directory to install firefox, xvfb and other dependencies.  I have successfully deployed the app and its dependencies on AWS using that script.

A full set of rspec tests are included, but some require valid credentials for wytheville.mylabsplus.com.  The tests should be executable via

```sh
bundle install
bundle exec rspec spec/
```
I plan to add more detail as time allows. 