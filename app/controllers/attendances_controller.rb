class AttendancesController < ApplicationController
  
  before_action :logged_in_user,  only: [:create, :edit, :update, :change_log]
  before_action :correct_user,    only: [:edit, :update, :change_log]
    
def create
  @user = User.find(params[:user_id]) #createアクションに対応したURL/users/:user_id/attendancesの:user_idから、インスタンス変数@userを定義しています。
  @attendance = @user.attendances.find_by(worked_on: Date.today) #出勤時間を保存する為のレコードをattendancesテーブルから探し、インスタンス変数@attendanceに代入。
  if @attendance.started_at.nil?
    @attendance.update_attributes(started_at: current_time, origin_start: current_time)
    flash[:info] = 'おはようございます。'
  elsif @attendance.finished_at.nil?
    @attendance.update_attributes(finished_at: current_time,origin_fin: current_time)
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
    @all_user = User.where(superior: true).where.not(id: params[:id])
end

def update
    @user = User.find(params[:id])
    if attendances_invalid? #attendancesでバリデーションが通ればfalse、引っかかればtrue
      attendances_params.each do |id, item|
        data = Attendance.find(id)
        # 時間しかいらないが都合上日付を固定する
        item[:started_at] = "2000-01-01 #{item[:started_at]}" unless item[:started_at].blank?
        item[:finished_at] = "2000-01-01 #{item[:finished_at]}" unless item[:finished_at].blank?
        
        # 出勤・退勤がFormのみ[DBデータなし]に入力された状態から変更する場合
        if data.started_at.blank? || data.finished_at.blank?
          # 以下は変更されていたらtrue
          item[:nextday] = item[:nextday] == "true" ? true : false # 文字列で入ってくるので変換
          item[:conf_change] = item[:conf_change].blank? ? nil : item[:conf_change].to_i
        
          bool_next = data.nextday == item[:nextday]
          bool_boss = data.conf_change == item[:conf_change]
          
          # if !data.origin_start.blank? || !data.origin_fin.blank?
          #   item["edit_request_permit"] =  "申請中"
          #   item["permitdate"] =  ""
          # end
          # データ変更されていたなら
          unless bool_next && bool_boss
            item["edit_request_permit"] =  "申請中"
            item["permitdate"] =  ""
          end
        
        if item[:conf_change] = item[:conf_change].blank? ? nil : item[:conf_change].to_i
          data.update_attributes(item)
        end
          next
        end
        
        # 出勤・退勤がDB,Formどちらにも入力された状態から変更する場合
        if !data.started_at.blank? && !data.finished_at.blank? && !item[:started_at].blank? && !item[:finished_at].blank?
          # 以下は変更されていたらtrue
          bool_s = (data.started_at - data.started_at.beginning_of_day) == ((Time.parse(item[:started_at]) - Time.parse(item[:started_at]).beginning_of_day))    
          bool_e = (data.finished_at - data.finished_at.beginning_of_day) == ((Time.parse(item[:finished_at]) - Time.parse(item[:finished_at]).beginning_of_day))
        
          item[:nextday] = item[:nextday] == "true" ? true : false # 文字列で入ってくるので変換
          item[:conf_change] = item[:conf_change].blank? ? nil : item[:conf_change].to_i
          bool_next = data.nextday == item[:nextday]
          bool_boss = data.conf_change == item[:conf_change]
          
          # データ変更されていたなら
          unless bool_s && bool_e && bool_next && bool_boss
            item["edit_request_permit"] =  "申請中"
            item["permitdate"] =  ""
          end
        if item[:conf_change] = item[:conf_change].blank? ? nil : item[:conf_change].to_i
          data.update_attributes(item)
        end
        end
      end
      flash[:success] = "勤怠情報を更新しました。#{@i}"
      redirect_to user_url(@user, prams:{first_day: params[:date]})
    else
      flash[:danger] = '不正な入力がありました、再入力してください。'
      redirect_to edit_attendances_path(@user, params[:date])
    end
end

def update_overwork_request #work_request 残業申請モーダル表示、登録アクション
    user = User.find(params[:id])
    # 該当の日付の情報を更新
    attendance = Attendance.find(params[:attendance_id])
    permit_status = overwork_request_params
    blank_check = (!permit_status['overwork_finish'].blank? && !permit_status['overwork_superior'].blank?)
    
    if blank_check
      permit_status['work_request_permit'] = '申請中'
      attendance.update_attributes(permit_status)
      flash[:success] = '情報を更新しました。'
      redirect_to user
    elsif blank_check == false
      flash[:danger] = '終了時間と上長を入力してください。'
      redirect_to user
    else
      flash[:danger] = '不正な入力がありました、再入力して���ださい。'
      redirect_to user
    end
end

#残業申請承認
 def overwork_permit #overtime_permit 変更チェック時（更新）のアクション
      user = User.find(params[:id])
    overwork_permit_params.each do |id, item|
      if item[:change]
        attendance = Attendance.find(id)
        attendance.update_attributes({:work_request_permit => item[:work_request_permit]})
        flash[:success] = "申請情報の変更完了しました。"
      end
    end
    redirect_to user
 end

def month_request
  user = User.find(params[:id])
    month_request_params.each do |id, item|
      if item[:change]
        # flash[:success] = item[:edit_request_permit]
        attendance = Monthrequest.find(id)
        attendance.update_attributes({:month_approval => item[:month_approval]})
        flash[:success] = "申請情報の変更完了しました。"
      end
    end
    redirect_to user
end

def edit_request
    user = User.find(params[:id])
    # attendances"=>{"1"=>{"edit_request_permit"=>" 申請中", "change"=>"true"}, "24"=>{"edit_request_permit"=>"承認", "change"=>"true"}, "32"=>{"edit_request_permit"=>"否認", "change"=>"true"}}

    nowdate = Date.current
    edit_request_params.each do |id, item|
      if item[:change]
        # flash[:success] = item[:edit_request_permit]
        attendance = Attendance.find(id)
        # 承認日も登録
        attendance.update_attributes({:edit_request_permit => item[:edit_request_permit], :permitdate => nowdate})
        flash[:success] = "勤怠変更申請を更新しました。"
      end
    end
    redirect_to user
end

 # 勤怠ログ
  def change_log
    @user = User.find(params[:id])
    @log_lists = @user.attendances.where(edit_request_permit: '承認').order('worked_on')
    # 年の終わり
    @to_year = Date.current.year
    @from_year = @user.attendances.order('updated_at').last.created_at.year
    
    # セレクト初期表示
    @sel_today = Date.current
    # テスト用
    @from_year = @from_year == 2019 ? 2017 : @from_year
  end
  
  # 勤怠ログ非同期通信
  def worktime_logs
    # Parameters: {"year"=>"2019", "month"=>"3"}
    # data = User.find(params["month"]).attendances.where.not(started_at: nil).where.not(finished_at: nil)
    
    id = session[:user_id]
    from_date = "#{params['year']}-#{params['month'].rjust(2, '0')}-01"
    to_date = Date.parse(from_date).end_of_month
    
    
    con = ActiveRecord::Base.connection
    data = con.select_all(
      "SELECT
        u.name, a.worked_on, a.started_at, a.finished_at, a.origin_start, a.origin_fin, a.conf_change, a.permitdate
      FROM ATTENDANCES AS a
      LEFT JOIN Users AS u
      ON a.conf_change = u.id
      WHERE a.worked_on BETWEEN '#{from_date}' AND '#{to_date}'
      AND a.user_id = #{id}
      AND a.edit_request_permit = '承認'
      "
      )
    # att = Attendance.where('worked_on >= ? and worked_on <= ?', '2019-04-01', '2019-04-30').order('worked_on')
    # data = Attendance.eager_load(:user).where('worked_on >= ? and worked_on <= ?', '2019-03-01', '2019-03-30').order('worked_on')
    render json: data
  end
  
  private
  
  def except_admin
    redirect_to users_url if current_user.admin?
  end
  
    def attendances_params
      params.permit(attendances: [:started_at, :finished_at, :note, :conf_change, :nextday,:origin_start,:origin_fin])[:attendances]
    end
    
    def overwork_request_params #残業申請モーダル画面
      params.permit(attendances: [:overwork_finish, :overwork_note, :overwork_superior,:next_day])[:attendances]
    end
    
    def overwork_permit_params
     params.permit(over_work: [:work_request_permit, :change])[:over_work]
    end
    
    # 勤怠変更strongparameter
    def edit_request_params
     params.permit(attendances: [:edit_request_permit, :change])[:attendances]
    end
    
    def month_request_params
     params.permit(month_requests: [:month_approval, :change])[:month_requests]
    end
    
    def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = "ログインしてください。"
      redirect_to login_url
    end
    end
  
  def correct_user
    @user = User.find(params[:id])
    # redirect_to(root_url) unless current_user?(@user) || current_user.admin?
    redirect_to "/users/#{session[:user_id]}" unless current_user?(@user) || current_user.admin?
  end
  
  def admin_user
    # redirect_to(root_url) unless current_user.admin?
    redirect_to "/users/#{session[:user_id]}" unless current_user.admin?
  end
  
end