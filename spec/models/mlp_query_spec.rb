require 'spec_helper'
require 'pry'

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
      it "returns fake results"
    end
  end
end
