class WeekDataController < ApplicationController
  before_action :set_week_datum, only: [:show, :edit, :update, :destroy]

  # GET /week_data
  # GET /week_data.json
  def index
    @week_data = WeekDatum.all
  end

  # GET /week_data/1
  # GET /week_data/1.json
  def show
  end

  # GET /week_data/new
  def new
    @week_datum = WeekDatum.new
  end

  # GET /week_data/1/edit
  def edit
  end

  # POST /week_data
  # POST /week_data.json
  def create
    @week_datum = WeekDatum.new(week_datum_params)

    respond_to do |format|
      if @week_datum.save
        format.html { redirect_to @week_datum, notice: 'Week datum was successfully created.' }
        format.json { render action: 'show', status: :created, location: @week_datum }
      else
        format.html { render action: 'new' }
        format.json { render json: @week_datum.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /week_data/1
  # PATCH/PUT /week_data/1.json
  def update
    respond_to do |format|
      if @week_datum.update(week_datum_params)
        format.html { redirect_to @week_datum, notice: 'Week datum was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @week_datum.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /week_data/1
  # DELETE /week_data/1.json
  def destroy
    @week_datum.destroy
    respond_to do |format|
      format.html { redirect_to week_data_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_week_datum
      @week_datum = WeekDatum.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def week_datum_params
      params.require(:week_datum).permit(:week, :fan_duel, :yahoo, :dvoa, :fftoday)
    end
end
