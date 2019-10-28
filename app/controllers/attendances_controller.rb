class AttendancesController < ApplicationController
    
def create
  @user = User.find(params[:user_id]) #createアクションに対応したURL/users/:user_id/attendancesの:user_idから、インスタンス変数@userを定義しています。
  @attendance = @user.attendances.find_by(worked_on: Date.today) #出勤時間を保存する為のレコードをattendancesテーブルから探し、インスタンス変数@attendanceに代入。
  if @attendance.started_at.nil?
    @attendance.update_attributes(started_at: current_time)
    flash[:info] = 'おはようございます。'
  elsif @attendance.finished_at.nil?
    @attendance.update_attributes(finished_at: current_time)
    flash[:info] = 'おつかれさまでした。'
  else
    flash[:danger] = 'トラブルがあり、登録出来ませんでした。'
  end
  redirect_to @user
end

def edit
    @user = User.find(params[:id])
    @first_day = Date.parse(params[:date])
    @last_day = @first_day.end_of_month
    @dates = @user.attendances.where('worked_on >= ? and worked_on <= ?', @first_day, @last_day).order('worked_on')
end

def update
    @user = User.find(params[:id])
    if attendances_invalid?
      attendances_params.each do |id, item|
        attendance = Attendance.find(id)
        attendance.update_attributes(item)
      end
      flash[:success] = '勤怠情報を更新しました。'
      redirect_to user_path(@user, params:{first_day: params[:date]})
    else
      flash[:danger] = "不正な時間入力がありました、再入力してください。"
      redirect_to edit_attendances_path(@user, params[:date])
    end
end

def update_overwork_request #work_request 残業申請モーダル表示、登録アクション
    user = User.find(params[:id])
    # 該当の日付の情報を更新
    attendance = Attendance.find(params[:attendance_id])
    permit_status = work_request_params
    blank_check = (!permit_status['overwork_finish'].blank? && !permit_status['overwork_note'].blank?)
    
    if blank_check
      permit_status['work_request_permit'] = '申請中'
      attendance.update_attributes(permit_status)
      flash[:success] = '情報を更新しました。'
      redirect_to user
    elsif blank_check == false
      flash[:danger] = '終了時間と上長を入力してください。'
      redirect_to user
    else
      flash[:danger] = '不正な入力がありました、再入力してください。'
      redirect_to user
    end
end
#残業申請承認
def overwork_permit #overtime_permit
end

def month_request
end

def edit_request
end
  
  private
  
    def attendances_params
      params.permit(attendances: [:started_at, :finished_at, :note])[:attendances]
    end
    
    def overwork_request_params #残業申請モーダル画面
      params.permit(attendances: [:overwork_finish, :overwork_note, :overwork_supervisor,:next_day])[:attendances]
    end
  
end