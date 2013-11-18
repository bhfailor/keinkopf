class MteSession
  def initialize
    require 'pry'
#    require 'rubygems'
    require 'selenium-webdriver'
    require 'headless'
    myheadless = Headless.new
    myheadless.start
    driver = Selenium::WebDriver.for :firefox
    wait = Selenium::WebDriver::Wait.new(:timeout => 30) # seconds
    driver.navigate.to 'http://wytheville.mylabsplus.com'
    el = driver.find_element :name => "Username"
    el.send_keys "bhf2689@email.vccs.edu"
    el = driver.find_element :name => "Password"
    el.send_keys "073156"
    button = driver.find_elements(:class,"button_login")
    button[0].click # will work because array is returned for "...elements"
    the_link_css = "table.MainContentMainBg:nth-child(2) > tbody:nth-child(1) > tr:nth-child(1) > td:nth-child(1) > table:nth-child(1) > tbody:nth-child(1) > tr:nth-child(1) > td:nth-child(1) > table:nth-child(1) > tbody:nth-child(1) > tr:nth-child(6) > td:nth-child(1) > a:nth-child(3)"
    wait.until { driver.find_element(:css,the_link_css) }
    lnk = driver.find_element(:css,the_link_css)
    lnk.click
    select = driver.find_elements(:tag_name, "frame")
    select[0][:name]
    driver.switch_to.frame select[0] #  => ""
    wait.until { driver.find_element(:tag_name, "frame") }
    select2 = driver.find_elements(:tag_name, "frame")
    @tree = select2[1][:name] #  => "Tree"
    driver.switch_to.frame select2[1] #  => ""
    wait.until { driver.find_element(:id,'contentitem|html|357783773').displayed? }
    # binding.pry
    btn = driver.find_element(:id,'contentitem|html|357783773') # works!
    btn.click
    driver.title
    driver.switch_to.default_content
    select = driver.find_elements(:tag_name, "frame")
    select[0][:name]
    driver.switch_to.frame select[0] #  => ""
    select2 = driver.find_elements(:tag_name, "frame")
    select2[2][:name]
    driver.switch_to.frame select2[2] #  => ""
    
    the_link_css = "body > table:nth-child(7) > tbody:nth-child(1) > tr:nth-child(4) > td:nth-child(2) > font:nth-child(1) > a:nth-child(1)"
    wait.until { driver.find_element(:css,the_link_css) }
    lnk = driver.find_element(:css,the_link_css)
    lnk.click
    
    handles = driver.window_handles
    driver.switch_to.window handles[1]
    wait.until { driver.find_element(:id,'ctl00_MasterContent_DataList1_ctl00_Member') }
    @title = driver.title
    # binding.pry
    driver.quit
    myheadless.destroy
  end
  def tree
    @tree
  end
  def title
    @title
  end
end
