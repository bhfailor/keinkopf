class MlpQueriesController < ApplicationController
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
        format.html { redirect_to @mlp_query, notice: 'Mlp query was successfully updated.' }
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
      format.html { redirect_to mlp_queries_url }
      format.json { head :no_content }
    end
  end
end
