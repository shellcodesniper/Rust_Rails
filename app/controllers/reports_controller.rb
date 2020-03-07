class ReportsController < ApplicationController
  before_action :set_report, only: [:show, :edit, :update, :destroy]

  # GET /reports
  # GET /reports.json
  def index
    @reports = Report.all
  end

  # GET /reports/1
  # GET /reports/1.json
  def show
	if user_signed_in?
		if (current_user.id == @report.user.id)
			
		else
			redirect_to '/reports/', alert: "본인의 게시글만 확인할 수 있습니다."
			return
		end
	else
		redirect_to '/reports/', alert: "권한이 없습니다. 로그인 바랍니다."
		return
	end
  end

  # GET /reports/new
  def new
	if !user_signed_in?
		redirect_to '/reports/', alert: "권한이 없습니다. 로그인 바랍니다."
		return
	end
    @report = Report.new
  end

  # GET /reports/1/edit
  def edit
	if user_signed_in?
		if (current_user.id == @report.user.id)
			
		else
			redirect_to '/reports/'+@report.id.to_s, alert: "본인의 게시글만 수정할 수 있습니다."
			return
		end
	else
		redirect_to '/reports/'+@report.id.to_s, alert: "권한이 없습니다. 로그인 바랍니다."
		return
	end
  end

  # POST /reports
  # POST /reports.json
  def create
	@report = Report.new(report_params)
	if !user_signed_in? then return end
	@report.user_id = current_user.id

    respond_to do |format|
      if @report.save
        format.html { redirect_to @report, notice: 'Report was successfully created.' }
        format.json { render :show, status: :created, location: @report }
      else
        format.html { render :new }
        format.json { render json: @report.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /reports/1
  # PATCH/PUT /reports/1.json
  def update
    respond_to do |format|
      if @report.update(report_params)
        format.html { redirect_to @report, notice: 'Report was successfully updated.' }
        format.json { render :show, status: :ok, location: @report }
      else
        format.html { render :edit }
        format.json { render json: @report.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /reports/1
  # DELETE /reports/1.json
  def destroy
    @report.destroy
    respond_to do |format|
      format.html { redirect_to reports_url, notice: 'Report was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_report
      @report = Report.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def report_params
      params.require(:report).permit(:title, :reason, :content, :server_id, :player_id, :memo)
    end
end
