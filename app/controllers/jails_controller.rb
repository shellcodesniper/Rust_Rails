class JailsController < ApplicationController
  before_action :set_jail, only: [:show, :edit, :update, :destroy]

  # GET /jails
  # GET /jails.json
  def index
    @jails = Jail.all
  end

  # GET /jails/1
  # GET /jails/1.json
  def show
  end

  # GET /jails/new
  def new
    @jail = Jail.new
  end

  # GET /jails/1/edit
  def edit
  end

  # POST /jails
  # POST /jails.json
  def create
    @jail = Jail.new(jail_params)

    respond_to do |format|
      if @jail.save
        format.html { redirect_to @jail, notice: 'Jail was successfully created.' }
        format.json { render :show, status: :created, location: @jail }
      else
        format.html { render :new }
        format.json { render json: @jail.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /jails/1
  # PATCH/PUT /jails/1.json
  def update
    respond_to do |format|
      if @jail.update(jail_params)
        format.html { redirect_to @jail, notice: 'Jail was successfully updated.' }
        format.json { render :show, status: :ok, location: @jail }
      else
        format.html { render :edit }
        format.json { render json: @jail.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /jails/1
  # DELETE /jails/1.json
  def destroy
    @jail.destroy
    respond_to do |format|
      format.html { redirect_to jails_url, notice: 'Jail was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_jail
      @jail = Jail.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def jail_params
      params.require(:jail).permit(:server,:jailtype, :title, :targetid, :reason, :start_date, :end_date, :judger)
    end
end
