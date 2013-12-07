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

    if password == 'example' # TODO add more detail or variety using Faker output
      new_title = "Gradebook - #{fake_name_and_email_prefix(1)[:name][0]}"+' - '+Time.now.in_time_zone("Eastern Time (US & Canada)").to_s[0..15]
      new_title["Gradebook -"] = "#{semester}-#{section}#{session}"

      quantity = rand(12..22)
      credentials = fake_name_and_email_prefix(quantity)
      mlp_results = fake_mlp_results(quantity)
      progress = {
        :email => credentials[:email],
        :percent => mlp_results[:percent],
        :hours_to_go => mlp_results[:hours_to_go],
        :mte => mlp_results[:mte],
        :name => credentials[:name],
        :logoff => mlp_results[:logoff],
        :assignment => mlp_results[:assignment] ,
        :fraction => mlp_results[:fraction],
        :status => mlp_results[:status]
      }

      temp = hash_columns_to_rows(progress)
      progress = Hash[temp.sort_by {|k,v| if v[:percent].class != Fixnum then -1 else v[:percent] end}]

      new_title = new_title+" - Elapsed time percent: #{mlp_results[:elapsed_time_percent]}"
      return {:title => new_title,
        :progress => progress,
        :elapsed_time_percent => mlp_results[:elapsed_time_percent]}
    end

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
      wait.until { driver.find_elements(:css,'option')[indices[course_index]] }
      #binding.pry # this failed sporatically so added [indices[course_index]] to above line
      driver.find_elements(:css,'option')[indices[course_index]].click
      number_gradebook_entries_for_this_course = driver.find_elements(:css,'[id$="Member"]').count
      (0...number_gradebook_entries_for_this_course).each do |entry_index|
        wait.until { driver.find_elements(:css,'[id$="Member"]')[entry_index] }
        #binding.pry # this failed sporatically so added [entry_index] to the above line
        driver.find_elements(:css,'[id$="Member"]')[entry_index].click
        wait.until { driver.find_element(:css,'.grid > tbody:nth-child(1) > tr:nth-child(2) > td:nth-child(2)') }
        last_assignment_worked_on << driver.find_element(:css,'.grid > tbody:nth-child(1) > tr:nth-child(2) > td:nth-child(2)').text
        last_assignment_fraction_completed << driver.find_element(:css,'.grid > tbody:nth-child(1) > tr:nth-child(2) > td:nth-child(6)').text
        the_last_logoff_datetime = driver.find_element(:css,'.grid > tbody:nth-child(1) > tr:nth-child(2) > td:nth-child(9)').text
        #the_last_logoff_datetime = "\n" if the_last_logoff_datetime == "" # edge case of no work done on mte so no logoff time
        #binding.pry
        #last_logoff_datetime << (the_last_logoff_datetime["\n"] = " "; the_last_logoff_datetime) # replace new line with space
        # return a Time object
        last_logoff_datetime <<  if the_last_logoff_datetime == "" then self.class_start else mlp_time_to_Time_class(the_last_logoff_datetime) end
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
        #binding.pry
        wait.until { driver.find_element(:css,'#ctl00_MasterContent_TextBoxTo') }
        full_email_address = driver.find_element(:css,'#ctl00_MasterContent_TextBoxTo')[:value] # grab email address
        email_prefix <<  (full_email_address["@email.vccs.edu"] = ""; full_email_address) # remove domain information
        driver.find_element(:css,'#Math_NativeCancel_Normal').click # cancel email message - should close window as well
        driver.switch_to.window driver.window_handles.last
        #binding.pry # confirm can see the following link before clicking on it:
        status << calculated_status(homework_completed_percentage.last, percent_elapsed_time)
        driver.find_element(:css,'#ctl00_LnkBackGradebook').click
      end
    end
    # UTC is Universal Time Coordinated, up to 1972 Greenwich Mean Time (GMT)
    new_title = @title+' - '+Time.now.in_time_zone("Eastern Time (US & Canada)").to_s[0..15]
    new_title["Gradebook -"] = "#{semester}-#{section}#{session}"
    progress = {
      :email => email_prefix,
      :percent => homework_completed_percentage,
      :hours_to_go => estimated_hours_to_complete,
      :mte => mte_number,
      :name => name,
      :logoff => last_logoff_datetime,
      :assignment => last_assignment_worked_on,
      :fraction => last_assignment_fraction_completed,
      :status => status,
    }

      temp = hash_columns_to_rows(progress)
      progress = Hash[temp.sort_by {|k,v| if v[:percent].class != Fixnum then -1 else v[:percent] end}]

    new_title = new_title+" - Elapsed time percent: #{percent_elapsed_time}"
    results_hash = {:title => new_title,
      :progress => progress,
      :elapsed_time_percent => percent_elapsed_time
    }
    #binding.pry
    driver.quit
    myheadless.destroy
    results_hash
  end
  def fake_mlp_results(quantity)
    assignment_name = [
                  "SECTION 1.1 MEDIA ASSIGNMENT",
                  "SECTION 1.1 HOMEWORK",
                  "SECTION 1.2 MEDIA ASSIGNMENT",
                  "SECTION 1.2 HOMEWORK",
                  "SECTION 1.3 MEDIA ASSIGNMENT",
                  "SECTION 1.3 HOMEWORK",
                  "CHAPTER 1 MID CHAPTER QUIZ REVIEW",
                  "CHAPTER 1 MID CHAPTER QUIZ",
                  "SECTION 1.4 MEDIA ASSIGNMENT",
                  "SECTION 1.4 HOMEWORK",
                  "SECTION 1.5 MEDIA ASSIGNMENT",
                  "SECTION 1.5 HOMEWORK",
                  "SECTION 2.1 MEDIA ASSIGNMENT",
                  "SECTION 2.1 HOMEWORK",
                  "SECTION 2.2 MEDIA ASSIGNMENT",
                  "SECTION 2.2 HOMEWORK",
                  "SECTION 2.3 MEDIA ASSIGNMENT",
                  "SECTION 2.3 HOMEWORK",
                  "CHAPTER 2 MID CHAPTER QUIZ REVIEW",
                  "CHAPTER 2 MID CHAPTER QUIZ",
                  "SECTION 2.4 MEDIA ASSIGNMENT",
                  "SECTION 2.4 HOMEWORK",
                  "SECTION 2.5 MEDIA ASSIGNMENT",
                  "SECTION 2.5 HOMEWORK",
                  "SECTION 2.6 MEDIA ASSIGNMENT",
                  "SECTION 2.6 HOMEWORK",
                  "UNIT 1 EXAM REVIEW",
                  "UNIT 1 Exam Attempt #1",
                  "UNIT 1 Exam Attempt #2"
                 ]
    running_hw_percent = [
                        0,
                        4,
                        8,
                        12,
                        16,
                        20,
                        24,
                        28,
                        28,
                        32,
                        36,
                        40,
                        44,
                        48,
                        52,
                        56,
                        60,
                        64,
                        68,
                        72,
                        72,
                        76,
                        80,
                        84,
                        88,
                        92,
                        96,
                        100,
                        100
                        ]
    elapsed_time_percent = rand(25..75)

    # Switch over to returning an array rather than a single value for each hash value
    fraction, status, mte, assignment, dttm, hours_to_go, percent = [], [], [], [], [], [], []
    (0...quantity).each do |index|
      # Generate a number of points in the assignment [14,32]
      assignment_points = rand(14..32)
      # Generate the number of points completed [0,number of points in the assignment]
      completed_points = rand(0..assignment_points)
      # Generate the fraction
      fraction << "#{completed_points}/#{assignment_points}"

      mte << "123456789"[rand(0..8)]
      # Select an assignment name which includes a running hw percent value
      the_index = rand(0..28)
      an_assignment = assignment_name[the_index]
      hw_base_percent = running_hw_percent[the_index] # TODO does this need to be modified for the array case?
      # Update the assignment name based on the MTE number
      an_assignment =~ /^(S|C|U)\w{3,6} (\d+)\.?\d? [A-Z]/
      if $1 == "U"
        an_assignment = an_assignment.sub(/ 1/," #{mte.last}")
      else
        an_assignment = an_assignment.sub(/ #{$2}/," #{(mte.last.to_i-1)*2+($2.to_i)}")
      end
      assignment << an_assignment
      # If the assignment name include? "SECTION" or update the hw percent complete value based on fraction of the assignment completed
      #  each assignment is about 4% of the total homework in this approximation
      #binding.pry
      hw_completed_percent = hw_base_percent
      hw_completed_percent = hw_completed_percent + \
       (4.0*completed_points.to_f/assignment_points.to_f).round(0) if (an_assignment.include? "REVIEW") || (an_assignment.include? "SECTION")
      percent << hw_completed_percent
      # Generate hours to complete based on 30 hours total and percent of hw completed
      hours_to_go << 30.0*(100.0-hw_completed_percent)/100.0
      # Generate status relative to the time elapsed.
      status << calculated_status(hw_completed_percent, elapsed_time_percent)

      # Generate logoff scaled from now to class start based on elapsed_time_percent (about 2.6 million seconds in a session)
      dttm << Time.now() - elapsed_time_percent.to_f*2600000.0/100.0*rand #

    end
    # Return a hash that includes mte, assignment_name, assignment_completed_fraction, hw_completed_percent, elapsed_time_percent,
    #  status, logoff, and hours_to_go
    # p mte, assignment
    {mte: mte, elapsed_time_percent: elapsed_time_percent, fraction: fraction, assignment: assignment,
        percent: percent, status: status, logoff: dttm, hours_to_go: hours_to_go }
  end

  def fake_name_and_email_prefix(quantity)
    require 'faker'
    name, email_prefix = [], []
    (0...quantity).each do |index|
      first_name = Faker::Name.first_name
      last_name = Faker::Name.last_name
      middle_initial = Faker::Name.first_name[0]
      email_prefix << (first_name[0]+middle_initial+last_name[0]).downcase+(rand(10..9999).to_s)
      name << first_name+' '+last_name
    end
    {name: name, email: email_prefix}
  end
  def calculated_status(homework_completed_percentage, percent_elapsed_time)
    if homework_completed_percentage == 100 then "complete" else
      (if  homework_completed_percentage >= percent_elapsed_time then "safe" else
         (if  homework_completed_percentage+13 >= percent_elapsed_time then "caution" else "danger" end) end) end
  end
  def mlp_time_to_Time_class(mlp_time)
    mlp_time =~ /^(\d+)\/(\d+)\/(\d+)\W(\d+):(\d+)(a|p)m$/
    hour = $4.to_i + if $6 == "a" then 0 else 12 end # assume "p" if not "a"
    hour = hour - 12 if hour % 12 == 0 # edge cases of noon and midnight
    Time.new(2000+($3.to_i),$1.to_i,$2.to_i,hour,$5.to_i,0,"-05:00") # use "-05:00" for EST but actually want Eastern Time adjusted for DST so:
    #Time.new(2000+($3.to_i),$1.to_i,$2.to_i,hour,$5.to_i,0).in_time_zone("Eastern Time (US & Canada)")
  end
  def hash_columns_to_rows(a_hash)
    the_keys = a_hash.keys
    nels = a_hash[the_keys.first].count
    the_keys.each do |a_key|
      return "error:  value arrays are not all the same length!" unless nels == a_hash[a_key].count
    end
    x = {}
    (0...nels).each do |i|
      temp = {}
      (0...the_keys.count).each do |j|
        temp[the_keys[j]] = a_hash[the_keys[j]][i]
      end
      x[i] = temp
    end
    x
  end
end
