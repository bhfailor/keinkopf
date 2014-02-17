class MlpQueriesController < ApplicationController
  def cold_start
    MlpQuery.create!({ mlp_login_email: 'bhf2689@email.vccs.edu',
      section: 72,
      semester: 'FA13',
      class_stop:  Time.new(2013,12,17, 11,30,0),
      class_start: Time.new(2013,11,14,9,30,0),
      session: 'D' }) if MlpQuery.last == nil
    @mlp_query = MlpQuery.last
    @mlp_query.class_stop  = @mlp_query.class_stop.in_time_zone("Eastern Time (US & Canada)")
    @mlp_query.class_start = @mlp_query.class_start.in_time_zone("Eastern Time (US & Canada)")
    @results = 'Welcome - please change parameters as needed for your query!'
    render action: "edit"
  end

  # GET /mlp_queries
  # GET /mlp_queries.json
  def index
    @mlp_queries = MlpQuery.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @mlp_queries }
    end
  end

  # GET /mlp_queries/1
  # GET /mlp_queries/1.json
  def show
    @mlp_query = MlpQuery.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @mlp_query }
    end
  end

  # GET /mlp_queries/new
  # GET /mlp_queries/new.json
  def new
    @mlp_query = MlpQuery.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @mlp_query }
    end
  end

  # GET /mlp_queries/1/edit
  def edit
    @mlp_query = MlpQuery.find(params[:id])
  end

  # POST /mlp_queries
  # POST /mlp_queries.json
  def create
    @mlp_query = MlpQuery.new(params[:mlp_query])

    respond_to do |format|
      if @mlp_query.save
        format.html { redirect_to @mlp_query, notice: 'Mlp query was successfully created.' }
        format.json { render json: @mlp_query, status: :created, location: @mlp_query }
      else
        format.html { render action: "new" }
        format.json { render json: @mlp_query.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /mlp_queries/1
  # PUT /mlp_queries/1.json
  def update
    @mlp_query = MlpQuery.find(params[:id])

    respond_to do |format|
      if @mlp_query.update_attributes(params[:mlp_query])
        format.html { redirect_to @mlp_query, notice: 'MLP query was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @mlp_query.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /mlp_queries/1
  # DELETE /mlp_queries/1.json
  def destroy
    @mlp_query = MlpQuery.find(params[:id])
    @mlp_query.destroy

    respond_to do |format|
      format.html { redirect_to mlp_queries_url } # rake routes indicates mlp_queries => mlp_queries#index
      format.json { head :no_content }
    end
  end
  def request_table
    @mlp_query = MlpQuery.find(params[:id])
    @email = @mlp_query[:mlp_login_email]
  end
  def display_table
    @mlp_query = MlpQuery.find(params[:id])
    @password = params[:pswd]
    @results = @mlp_query.results(@password)
    if (@results == 'login failed - please confirm MLP login email and password') ||
       (@results == 'no mte matches - please confirm semester, section, and session') ||
       (@results == 'the MLP database query timed out - you may succeed if you try again')
      render action: "edit"
    end
    # default view generated
  end
  def sort_by_hw
    #require 'pry'
    #binding.pry
    @results = MlpQuery.sort_by_hw
    #binding.pry
    if (@results == 'login failed - please confirm MLP login email and password') ||
       (@results == 'no mte matches - please confirm semester, section, and session') ||
       (@results == 'the MLP database query timed out - you may succeed if you try again')
      render action: "edit"
    end
    # default view generated
  end
  def sort_by_mte
    #require 'pry'
    #binding.pry
    @results = MlpQuery.sort_default
    #binding.pry
    if (@results == 'login failed - please confirm MLP login email and password') ||
       (@results == 'no mte matches - please confirm semester, section, and session') ||
       (@results == 'the MLP database query timed out - you may succeed if you try again')
      render action: "edit"
    end
    # default view generated
  end
end
