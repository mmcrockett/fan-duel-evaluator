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
    raise "!ERROR: #{params}."
    @fan_duel_players = FanDuelPlayer.parse()

    respond_to do |format|
      if FanDuelPlayer.import(@fan_duel_players)
        format.json { head :no_content }
      else
        format.json { render json: @fan_duel_players.errors, status: :unprocessable_entity }
      end
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
