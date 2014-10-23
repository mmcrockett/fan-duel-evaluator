class FanDuelPlayerController < ApplicationController
  #before_action :set_week_datum, only: [:show, :edit, :update, :destroy]

  def index
  end

  def show
  end

  def new
  end

  def edit
  end

  def create
    week = params[:week]
    FanDuelPlayer.parse(params[:data], week)
    Dvoa.load(week)
    Yahoo.load(week)
    FfTodayPrediction.load(week)

    respond_to do |format|
      format.json { head :no_content }
    end
  end

  def update
  end

  def destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    #def set_week_datum
      #@week_datum = WeekDatum.find(params[:id])
    #end

    # Never trust parameters from the scary internet, only allow the white list through.
    #def week_datum_params
      #params.require(:week_datum).permit(:week, :fan_duel, :yahoo, :dvoa, :fftoday)
    #end
end
