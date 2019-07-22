class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update,:show]
  before_action :correct_user,   only: [:edit, :update,:show]
  before_action :admin_user,     only: [:destroy, :edit_basic_info, :update_basic_info,:index]

  def index
    @users = User.paginate(page: params[:page])
  end

 def show
    @user = User.find(params[:id])
    @first_day = first_day(params[:first_day])
    @last_day = @first_day.end_of_month # @first_dayにend_of_monthを記述することで、末日を取得できる。
    (@first_day..@last_day).each do |day| #ブロック変数のdayオブジェクトは、Dateクラスから取得した日付データ。
      unless @user.attendances.any? {|attendance| attendance.worked_on == day} #@userに紐付いた、当月の初日から末日までのattendancesテーブルのレコードがあるか確認。
        record = @user.attendances.build(worked_on: day) #無い場合該当する日付をworked_onに代入。
        record.save #代入後保存
      end
    end
    @dates = user_attendances_month_date
    @worked_sum = @dates.where.not(started_at: nil).count
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

  def update
    if @user.update_attributes(user_params)
      flash[:success] = "ユーザー情報を更新しました。"
      redirect_to @user
    else
      render 'edit'
    end
  end
  
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "削除しました。"
    redirect_to users_url
  end
  
  
  def edit_basic_info
  @user = User.find(params[:id])
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
  
  def edit_overwork_request
    @day=Date.parse(params[:day])
    @youbi= (%w{日 月 火 水 木 金 土}[@day.wday])
  end
  
  def accordion
    @user = User.find(params[:id])
  end
  
  def update_accordion
    if @user.update_attributes(user_params)
      flash[:success] = "ユーザー情報を更新しました。"
      redirect_to @user
    else
      render 'edit'
    end
  end
  
  def working_now
    @users = User.all
  end


private
  def user_params
    params.require(:user).permit(:name, :email, :department, :password, :password_confirmation)
  end

  def basic_info_params
    params.require(:user).permit(:basic_time, :work_time)
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
    
    
    # 管理者かどうか確認
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end