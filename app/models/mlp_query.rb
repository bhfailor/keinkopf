class MlpQuery < ActiveRecord::Base
  attr_accessible :class_start, :class_stop, :mlp_login_email, :section, :semester, :session
  validates :mlp_login_email, presence: true
  validates :section, presence: true
  validates :semester, presence: true
  validates :session, presence: true

  def results(password)
    require 'pry'
    require 'selenium-webdriver'
    require 'headless'
    myheadless = Headless.new
    myheadless.start
    driver = Selenium::WebDriver.for :firefox
    wait = Selenium::WebDriver::Wait.new(:timeout => 30) # seconds
    # find the elapsed time percent
    percent_elapsed_time = (100.0*(Time.now()-class_start)/(class_stop-class_start)).to_i
    driver.navigate.to 'http://wytheville.mylabsplus.com'
    el = driver.find_element :name => "Username"
    el.send_keys self.mlp_login_email
    el = driver.find_element :name => "Password"
    el.send_keys password
    button = driver.find_elements(:class,"button_login")
    button[0].click # will work because array is returned for "...elements"
    wait.until { driver.title != "" }
    return 'login failed - please confirm MLP login email and password' unless driver.title == "Academics PSH"

    the_link_css = "table.MainContentMainBg:nth-child(2) > tbody:nth-child(1) > tr:nth-child(1) > td:nth-child(1) > table:nth-child(1) > tbody:nth-child(1) > tr:nth-child(1) > td:nth-child(1) > table:nth-child(1) > tbody:nth-child(1) > tr:nth-child(6) > td:nth-child(1) > a:nth-child(3)"
    wait.until { driver.find_element(:css,the_link_css) }
    lnk = driver.find_element(:css,the_link_css)
    lnk.click
    wait.until {driver.find_elements(:tag_name, "frame")}
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
    # collect the different courses in the gradebook listed as options of a select element
    options = driver.find_elements(:css,'option')
    mte_numbers = [] ; indices = []
    (0...options.count).each do |index|
      if options[index][:text] =~ /^Member: #{semester}MTE(\d)#{session}-#{section}/
        mte_numbers << $1
        indices << index
      end
    end
    return 'no mte matches - please confirm semester, section, and session' if indices.count == 0

    # traverse the mte courses that matched, creating the arrays to capture the info first
    homework_completed_percentage, estimated_hours_to_complete, name, mte_number, status = [], [], [], [], []
    last_assignment_worked_on, last_assignment_fraction_completed, last_logoff_datetime, email_prefix = [], [], [], []
    number_of_courses = indices.count
    (0...number_of_courses).each do |course_index|
      wait.until { driver.find_elements(:css,'option') }
      driver.find_elements(:css,'option')[indices[course_index]].click
      number_gradebook_entries_for_this_course = driver.find_elements(:css,'[id$="Member"]').count
      (0...number_gradebook_entries_for_this_course).each do |entry_index|
        wait.until { driver.find_elements(:css,'[id$="Member"]') }
        driver.find_elements(:css,'[id$="Member"]')[entry_index].click
#        binding.pry
        wait.until { driver.find_element(:css,'.grid > tbody:nth-child(1) > tr:nth-child(2) > td:nth-child(2)') }
        last_assignment_worked_on << driver.find_element(:css,'.grid > tbody:nth-child(1) > tr:nth-child(2) > td:nth-child(2)').text
        last_assignment_fraction_completed << driver.find_element(:css,'.grid > tbody:nth-child(1) > tr:nth-child(2) > td:nth-child(6)').text
        the_last_logoff_datetime = driver.find_element(:css,'.grid > tbody:nth-child(1) > tr:nth-child(2) > td:nth-child(9)').text
        the_last_logoff_datetime = "\n" if the_last_logoff_datetime == "" # edge case of no work done on mte so no logoff time
        #binding.pry
        last_logoff_datetime << (the_last_logoff_datetime["\n"] = " "; the_last_logoff_datetime) # replace new line with space
        name << driver.find_element(:css,'#PagerContainer > div:nth-child(3) > strong:nth-child(1)').text
        mte_number << mte_numbers[course_index]
        # go into details
        #binding.pry # confirm link is present
        driver.find_element(:css,'#ctl00_MasterContent_OverallDetailsLink > li:nth-child(1) > a:nth-child(1)').click
        wait.until { driver.find_element(:css,'#ctl00_MasterContent_OverallScoreGrid > tbody:nth-child(2) > tr:nth-child(1) > td:nth-child(8)') }
        time_worked_on_hw =
          driver.find_element(:css,'#ctl00_MasterContent_OverallScoreGrid > tbody:nth-child(2) > tr:nth-child(1) > td:nth-child(8)').text
        # assuming 3 possibilities: h and m, just m, and just h
        time_worked_decimal_hours =  if time_worked_on_hw.match(/(\d+)h (\d*)m/) then
                                       (time_worked_on_hw.match(/(\d+)h (\d*)m/).captures[1].to_f/60.0)+$1.to_f
                                     elsif (time_worked_on_hw.match(/(\d*)m/)) then
                                       (time_worked_on_hw.match(/(\d*)m/).captures[0].to_f/60.0)
                                     else
                                       (time_worked_on_hw.match(/(\d*)h/).captures[0].to_f)
                                     end
        # assume element is visible since the previous find_element call succeeded

        if driver.find_elements(:css,'#ctl00_MasterContent_TDHomework > span:nth-child(1) > a:nth-child(1) > div:nth-child(2) > div:nth-child(1)').count != 0
          style = driver.find_element(:css,'#ctl00_MasterContent_TDHomework > span:nth-child(1) > a:nth-child(1) > div:nth-child(2) > div:nth-child(1)')[:style]
          homework_completed_percentage << (style.match(/^height: (\d+)px/).captures[0].to_f/90.0*100.0).to_i
        else homework_completed_percentage << 0 end
        estimated_hours_to_complete << if homework_completed_percentage.last == 0 then "NA" else
          ((100-homework_completed_percentage.last).to_f*time_worked_decimal_hours/homework_completed_percentage.last.to_f).round(1) end
        # go into email
        #binding.pry
        driver.find_element(:css,'#ctl00_MasterContent_StudentPager1_EmailStudentLink').click
        driver.switch_to.window driver.window_handles.last # switch to most recenty opened window
        full_email_address = driver.find_element(:css,'#ctl00_MasterContent_TextBoxTo')[:value] # grab email address
        email_prefix <<  (full_email_address["@email.vccs.edu"] = ""; full_email_address) # remove domain information
        driver.find_element(:css,'#Math_NativeCancel_Normal').click # cancel email message - should close window as well
        driver.switch_to.window driver.window_handles.last
        #binding.pry # confirm can see the following link before clicking on it:
        status << if homework_completed_percentage.last == 100 then "complete" else (if  homework_completed_percentage.last >= percent_elapsed_time then "safe" else (if  homework_completed_percentage.last+13 >= percent_elapsed_time then "caution" else "danger" end) end) end
        driver.find_element(:css,'#ctl00_LnkBackGradebook').click
      end
    end
    # UTC is Universal Time Coordinated, up to 1972 Greenwich Mean Time (GMT)
    new_title = @title+' - '+Time.now.to_s+' (YYYY-MM-DD HH:MM:SS +/-UTC)'
    new_title["Gradebook -"] = "#{semester}-#{section}#{session}"
    results_hash = {:title => new_title,
      :email => email_prefix,
      :percent => homework_completed_percentage,
      :estimate => estimated_hours_to_complete,
      :mte => mte_number,
      :name => name,
      :logoff => last_logoff_datetime,
      :assignment => last_assignment_worked_on,
      :fraction => last_assignment_fraction_completed,
      :status => status
    }
    #binding.pry
    driver.quit
    myheadless.destroy
    results_hash
  end
end
