class UsersController < ApplicationController
  before_action :logged_in_user, only: [:edit, :update, :show, :destroy]
  before_action :correct_user,   only: [:edit, :update,:show, :csv_dl]
  before_action :admin_user,     only: [:destroy, :edit_basic_info, :update_basic_info,:index, :working_now, :csv_import]
  before_action :except_admin,    only: [:show, :csv_dl, :overwork_request, :overwork_permit, :month_request_modal, :edit_request, :confirmation, :working_now]

  def index
    @users = User.paginate(page: params[:page])
  end
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = "ユーザーの新規作成に成功しました。"
      redirect_to @user
    else
      render 'new'
    end
  end
  
  def edit
    @user = User.find(params[:id])
    @first_day = first_day(params[:date])
    @last_day = @first_day.end_of_month
    @dates = user_attendances_month_date
  end

 def show
    @user = User.find(params[:id])
    @first_day = first_day(params[:first_day]).beginning_of_month
    @last_day = @first_day.end_of_month # @first_dayにend_of_monthを記述することで、末日を取得できる。
    (@first_day..@last_day).each do |day| #ブロック変数のdayオブジェクトは、Dateクラスから取得した日付データ。
      unless @user.attendances.any? {|attendance| attendance.worked_on == day} #@userに紐付いた、当月の初日から末日までのattendancesテーブルのレコードがあるか確認。
        record = @user.attendances.build(worked_on: day) #無い場合該当する日付をworked_onに代入。
        record.save #代入後保存
      end
    end
    @dates = user_attendances_month_date
    @worked_sum = @dates.where.not(started_at: nil).count
    
    @monthrequest = @user.monthrequests
    .where(req_date: @first_day)
    .where(user_id: params[:id])
    .order(req_date: :desc).limit(1)
    
    # 承認の確認していない項目について
    @boss_notice = Monthrequest.where('boss_id = ?', params[:id]).where.not(month_approval: ['承認','否認'])
    
    # 勤怠変更申請の確認していない項目について(全期間調べる必要あり)
    @time_change_notice = Attendance.where('conf_change = ?', params[:id])
    .where.not(edit_request_permit: ['承認','否認'])
    .order('worked_on')
    
    # 残業申請表示に必要
    @overtime_notice = Attendance.where('overwork_superior = ?', params[:id])
    .where.not(work_request_permit: ['承認','否認'])
    .order('worked_on')
    
    @all_user = User.where(superior: true).where.not(id: params[:id])
 end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = "ユーザー情報を更新しました。"
      redirect_to users_path
    else
      render 'edit'
    end
  end
  
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "削除しました。"
    redirect_to users_url
  end
  
  def csv_dl
    user = User.find(params[:id])
    first_day = first_day(params[:first_day]).beginning_of_month
    last_day = first_day.end_of_month
    @attendances = user.attendances.where('worked_on >= ? and worked_on <= ?', first_day, last_day).order('worked_on')
    
    respond_to do |format|
      # format.html do
      #     #html用の処理を書く
      # end 
      format.csv do
          send_data render_to_string, filename: "attendance.csv", type: :csv
      end
    end
  end
  
  def csv_import
    if params[:csv_file].blank?
      flash[:danger] = "読み込むCSVを選択してください。"
      redirect_to users_url
    elsif File.extname(params[:csv_file].original_filename) != ".csv"
      flash[:danger] = "csvファイルのみ読み込み可能です。"
      redirect_to users_url
    else
      # import_data
      # registered_count = import_data
      # flash[:success] = "#{registered_count}件登録しました。"
      msg = User.import(params[:csv_file])
      msg == "登録完了" ? flash[:success] = msg : flash[:danger] = msg
      redirect_to users_url
      # @users_data = User.all
      # render "index"
    end
  end
  
   #残業申請モーダル表示
  def overwork_request
    @attendance_id = params[:id] #idを取得し@attendance_idに代入
    @user = Attendance.find(params[:id]).user #userレコードからAttendanceモデルのidを取得し、@userに代入
    @first_day = first_day(params[:first_day]).beginning_of_month #first_day(date)の月初を@first_dayに代入
    @dates = @user.attendances.find(@attendance_id)
    @all_user = User.where(superior: true).where.not(id: @user.id) #superior: trueを全て取得。idが@user.id以外のユーザーを全て取得
  end
  
  #残業申請承認
  def overwork_permit #overtime_permit_modal（モーダル表示アクション）
  @user = User.find(params[:id]) #Userモデルからidを取得し、@userに代入
  #↓ ? 「プレースホルダ」値が入るまで（仮）一時保存、idが入ったらカラムに置き換えられる
  #↓第２引数がカラムに入った第１引数に当てはまるAttendanceモデルのレコードを全て取得し、@work_requestsに代入
  @work_requests = Attendance.where('overwork_superior = ?', params[:id])
  .where.not(work_request_permit: ['承認','否認'])#work_request_permitが'承認','否認'以外のAttendanceを全て取得
    .order('user_id').order('worked_on') #orderメソッドで取得データを並び替え
  end
  
  #勤怠変更申請、承認
  def edit_request
    @edit_requests = Attendance.where('conf_change = ?', params[:id])
    .where.not(edit_request_permit: ['承認','否認'])
    .order('user_id').order('worked_on')
    @user = User.find(params[:id])
  end
  
  #１ヶ月分の勤怠申請、承認
  def month_request_modal
     @user = User.find(params[:id])
     @month_requests = Monthrequest.where('boss_id = ?', params[:id])
    .where.not(month_approval: ['承認','否認'])
    .order('user_id').order('req_date')
  end
  
  def confirmation #残業申請（勤怠確認）
  @user = User.find(params[:id])
    @first_day = first_day(params[:date]).beginning_of_month
    @last_day = @first_day.end_of_month
    (@first_day..@last_day).each do |day|
      unless @user.attendances.any? {|attendance| attendance.worked_on == day}
        record = @user.attendances.build(worked_on: day)
        record.save
      end
    end
    @dates = user_attendances_month_date
    @worked_sum = @dates.where.not(started_at: nil).count
    # 月の申請
    @monthrequest = @user.monthrequests
    .where(req_date: @first_day)
    .where(user_id: params[:id])
    .order(req_date: :desc).limit(1)
  end
  
  def update_basic_info
  @user = User.find(params[:id])
   if @user.update_attributes(basic_info_params)
    flash[:success] = "基本情報を更新しました。"
    redirect_to @user   
   else
    render 'edit_basic_info'
   end
  end
  
  
  def edit_basic_info
    @user = User.find(params[:id])
    @first_day = Date.parse(params[:date])
    @last_day = @first_day.end_of_month
    @dates = @user.attendances.where('worked_on >= ? and worked_on <= ?', @first_day, @last_day).order('worked_on')
  end
  
  def working_now
    @users = User.all
  end


private
  def user_params
    params.require(:user).permit(:name, :email, :affiliation,:employee_number,:uid, :password, :password_confirmation,:basic_work_time,:designated_work_start_time,:work_finish_time)
  end

  def basic_info_params
    params.require(:user).permit(:basic_time, :designated_work_start_time)
  end
  
    # beforeアクション

    # ログイン済みユーザーか確認
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "ログインしてください。"
        redirect_to login_url
      end
    end

    # 正しいユーザーかどうか確認
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user) or current_user.admin?
    end
    
    def superior_user
      redirect_to(root_url) unless current_user.superior?
    end
    
    
    # 管理者かどうか確認
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
    
    def except_admin
     redirect_to users_url if current_user.admin?
    end
end