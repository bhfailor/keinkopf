require 'spec_helper'
require 'pry'

def calculated_status(homework_completed_percentage, percent_elapsed_time)
    if homework_completed_percentage == 100 then "complete" else
      (if  homework_completed_percentage >= percent_elapsed_time then "safe" else
         (if  homework_completed_percentage+13 >= percent_elapsed_time then "caution" else "danger" end) end) end
end

describe MlpQuery do
  it "is valid with an mlp_login_email, section, semester, and session" do
    an_mlp_query = MlpQuery.new(
      mlp_login_email: 'bhf2689@email.vccs.edu',
      section: 72,
      semester: 'FA13',
      class_stop:  Time.new(2013,12,17, 11,30,0),
      class_start: Time.new(2013,11,14,9,30,0),
      session: 'D')
    expect(an_mlp_query).to be_valid
  end
  it "is invalid without an mlp_login_email" do
    expect(MlpQuery.new(mlp_login_email: nil)).to have(1).errors_on(:mlp_login_email)
  end
  it "is invalid without a section" do
    expect(MlpQuery.new(section: nil)).to have(1).errors_on(:section)
  end
  it "is invalid without a semester" do
    expect(MlpQuery.new(semester: nil)).to have(1).errors_on(:semester)
  end
  it "is invalid without a session" do
    expect(MlpQuery.new(session: nil)).to have(1).errors_on(:session)
  end
  describe "#results" do
    context "with valid query parameters" do
      before(:all) do
        an_mlp_query = MlpQuery.create(
          mlp_login_email: 'bhf2689@email.vccs.edu',
          section: 72,
          semester: 'FA13',
          class_stop:  Time.new(2013,12,17,11,30,0),
          class_start: Time.new(2013,11,14,9,30,0),
          session: 'D')
        @some_results = an_mlp_query.results("073156")
      end

      it "captures the names of the customers" do
        expect(@some_results[:name]).to include "Emily Dye"
      end
      it "captures the mte course numbers" do
        expect(@some_results[:mte]).to include "4"
      end
      it "captures the assignments" do
        expect(@some_results[:assignment]).to include "SECTION 2.3 HOMEWORK"
      end
      it "captures the progress on the most recent module" do
        expect(@some_results[:fraction].join(" ")).to include( "/2" )
      end
      it "captures the percent complete" do
        expect(@some_results[:percent][0]).to be_within(50).of(50)
      end
      it "captures the instructor name" do
        expect(@some_results[:title]).to include "Bruce Failor"
      end
      it "captures the most recent logoff date and time" do
        expect(@some_results[:logoff][0]).to include("m" && ":")
      end
      it "calculates the estimated hours needed for completion" do
        expect(@some_results[:estimate][0]).to be_within(30.0).of(30.0)
      end
      it "calculates the status of an individual" do
        expect(@some_results[:status].join(" ")).to include("safe")
      end
      it "captures the email identifiers" do
        expect(@some_results[:email]).to include "ake2441"
      end
    end
    context "with invalid login or query parameters" do
      it "returns the status of an unsuccessfull MLP login" do
        an_mlp_query = MlpQuery.create(
          mlp_login_email: 'bhf2689@email.vccs.edu',
          section: 72,
          semester: 'FA13',
          class_stop:  Time.new(2013,12,17, 11,30,0),
          class_start: Time.new(2013,11,14,9,30,0),
          session: 'D')
        expect(an_mlp_query.results("wrong_password")).to eq 'login failed - please confirm MLP login email and password'
      end
      it "returns an error message if no courses match the query criteria" do
        an_mlp_query = MlpQuery.create(
          mlp_login_email: 'bhf2689@email.vccs.edu',
          section: 72,
          semester: 'FA13',
          class_stop:  Time.new(2013,12,17, 11,30,0),
          class_start: Time.new(2013,11,14,9,30,0),
          session: 'InvalidSessionID')
        expect(an_mlp_query.results("073156")).to eq 'no mte matches - please confirm semester, section, and session'
      end
    end
    context "with a password of :example", focus: true do
      before(:each) do
        @the_parameters = {
          mlp_login_email: 'bhf2689@email.vccs.edu',
          section: 72,
          semester: 'FA13',
          class_stop:  Time.new(2013,12,17, 11,30,0),
          class_start: Time.new(2013,11,14,9,30,0),
          session: 'D'
        }
        an_mlp_query = MlpQuery.new(@the_parameters)
        @table_example = an_mlp_query.results("example")
      end
      it "returns a hash with the appropriate keys" do
        @table_example.should include(:title, :email,:percent,:hours_to_go,:mte,:name,:logoff,:assignment,:fraction,:status,:elapsed_time_percent)
      end
      it "returns a valid :title" do
        @table_example[:title].should include("#{@the_parameters[:semester]}-#{@the_parameters[:section]}#{@the_parameters[:session]}")
      end
      it "returns a valid :email" do
        expect(@table_example[:email]  =~ /^[a-z]{3}\d{2,4}$/).to_not be nil
      end
      it "returns a valid :mte (number)" do
        expect(@table_example[:mte]  =~ /^[1-9]{1}$/).to_not be nil
      end
      it "returns a valid (customer) :name" do
        p @table_example[:name]
        expect(@table_example[:name]  =~ /^[A-Z]{1}[a-z]+ [A-Z]{1}['A-Za-z]+$/).to_not be nil
      end
      it "returns a valid :assignment (description)" do
        #p @table_example[:assignment]
        expect(@table_example[:assignment] =~ /^[S|C|U]\w{3,6} \d+\.?\d? [A-Z]/).to_not be nil
      end
      it "returns an :assignment (description) consistent with the mte" do
        #p @table_example[:assignment]
        expect(@table_example[:assignment] =~ /^(S|C|U)\w{3,6} (\d+)\.?\d? [A-Z]/).to_not be nil
        if $1 == "U"
          expect($2).to eq(@table_example[:mte])
        else
          expect(($2.to_i ==  2*(@table_example[:mte].to_i))   ||
                 ($2.to_i == (2*(@table_example[:mte].to_i)-1))).to be_true
        end
      end
      it "returns a valid :fraction (of assignment completed string)" do
        expect(@table_example[:fraction]  =~ /^(\d+)\/(\d+)$/).to_not be nil
        expect($1.to_i <= $2.to_i).to be_true
      end
      it "returns a valid :status" do
        expect((@table_example[:status] == "safe")     ||
               (@table_example[:status] == "complete") ||
               (@table_example[:status] == "caution")  ||
               (@table_example[:status] == "danger")).to be_true
      end
      it "returns the calculated :status" do
        expect(calculated_status(@table_example[:percent],@table_example[:elapsed_time_percent])).to eq(@table_example[:status])
      end
      it "returns a valid :hours_to_go (estimated to complete)" do
        @table_example[:hours_to_go].should be_within(0.5).of((100.0-@table_example[:percent].to_f)*30.0/100.0)
      end
      it "returns a valid :logoff (datetime)" do
        # should be between now and the beginning of the course, which is 2600000 seconds long
        # course beginning is found from the percent elapsed time
        this_moment = Time.now ; session_s = 2600000.0
        expect((@table_example[:logoff] <= this_moment) &&
               (@table_example[:logoff] >= this_moment-session_s*@table_example[:elapsed_time_percent].to_f/100.0)).to be_true
      end
    end
  end
end
